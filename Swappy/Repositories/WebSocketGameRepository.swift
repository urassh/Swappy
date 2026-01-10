//
//  WebSocketGameRepository.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/10.
//

import Foundation

class WebSocketGameRepository: NSObject, GameRepositoryProtocol, URLSessionWebSocketDelegate {
    
    // MARK: - Constants
    private let baseURL = "http://localhost:8000"
    private let wsBaseURL = "ws://localhost:8000"
    
    // MARK: - Properties
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private var roomId: String?
    
    // MARK: - Event Handlers
    private var onUsersChanged: (([User]) -> Void)?
    private var onUserLeft: ((String) -> Void)?
    private var onGameStarted: (() -> Void)?
    private var onRolesAssigned: (([User]) -> Void)?
    private var onAnswerSubmitted: ((String, String) -> Void)?
    private var onGameReset: (() -> Void)?
    private var onError: ((String) -> Void)?
    
    // MARK: - Initialization
    override init() {
        super.init()
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    // MARK: - GameRepositoryProtocol Implementation
    
    func setEventHandlers(
        onUsersChanged: @escaping ([User]) -> Void,
        onUserLeft: @escaping (String) -> Void,
        onGameStarted: @escaping () -> Void,
        onRolesAssigned: @escaping ([User]) -> Void,
        onAnswerSubmitted: @escaping (String, String) -> Void,
        onGameReset: @escaping () -> Void,
        onError: @escaping (String) -> Void
    ) {
        self.onUsersChanged = onUsersChanged
        self.onUserLeft = onUserLeft
        self.onGameStarted = onGameStarted
        self.onRolesAssigned = onRolesAssigned
        self.onAnswerSubmitted = onAnswerSubmitted
        self.onGameReset = onGameReset
        self.onError = onError
    }
    
    func joinRoom(keyword: String, me: User) {
        Task {
            do {
                // 1. ルームを作成または取得
                let roomId = try await createRoom(keyword: keyword)
                self.roomId = roomId
                
                // 2. WebSocketに接続
                try await connectWebSocket(roomId: roomId)
                
                // 3. ユーザーをルームに参加させる
                try await addUserToRoom(roomId: roomId, user: me)
                
            } catch {
                onError?("ルーム参加エラー: \(error.localizedDescription)")
            }
        }
    }
    
    func leaveRoom(me: User) {
        guard let roomId = roomId else {
            onError?("ルームIDが設定されていません")
            return
        }
        
        Task {
            do {
                try await removeUserFromRoom(roomId: roomId, userId: me.userId)
                disconnectWebSocket()
                self.roomId = nil
            } catch {
                onError?("ルーム退出エラー: \(error.localizedDescription)")
            }
        }
    }
    
    func completeCallReady(me: User) {
        guard let roomId = roomId else {
            onError?("ルームIDが設定されていません")
            return
        }
        
        Task {
            do {
                try await updateReadyState(roomId: roomId, userId: me.userId, isReady: true)
            } catch {
                onError?("準備状態更新エラー: \(error.localizedDescription)")
            }
        }
    }
    
    func startGame() {
        guard let roomId = roomId else {
            onError?("ルームIDが設定されていません")
            return
        }
        
        Task {
            do {
                try await startGameRequest(roomId: roomId)
            } catch {
                onError?("ゲーム開始エラー: \(error.localizedDescription)")
            }
        }
    }
    
    func toggleMute(me: User, isMuted: Bool) {
        guard let roomId = roomId else {
            onError?("ルームIDが設定されていません")
            return
        }
        
        Task {
            do {
                try await updateMuteState(roomId: roomId, userId: me.userId, isMuted: isMuted)
            } catch {
                onError?("ミュート状態更新エラー: \(error.localizedDescription)")
            }
        }
    }
    
    func submitAnswer(me: User, selectedUser: User) {
        guard let roomId = roomId else {
            onError?("ルームIDが設定されていません")
            return
        }
        
        Task {
            do {
                try await sendAnswer(roomId: roomId, userId: me.userId, answerUserId: selectedUser.userId)
            } catch {
                onError?("回答送信エラー: \(error.localizedDescription)")
            }
        }
    }
    
    func resetGame() {
        guard let roomId = roomId else {
            onError?("ルームIDが設定されていません")
            return
        }
        
        Task {
            do {
                try await resetGameRequest(roomId: roomId)
            } catch {
                onError?("ゲームリセットエラー: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - REST API Methods
    
    private func createRoom(keyword: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/rooms/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["keyword": keyword]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let roomId = json?["room_id"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        return roomId
    }
    
    private func addUserToRoom(roomId: String, user: User) async throws {
        guard let url = URL(string: "\(baseURL)/rooms/\(roomId)/users") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_id": user.userId,
            "name": user.name
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    private func removeUserFromRoom(roomId: String, userId: String) async throws {
        guard let url = URL(string: "\(baseURL)/rooms/\(roomId)/users/\(userId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    private func updateReadyState(roomId: String, userId: String, isReady: Bool) async throws {
        guard let url = URL(string: "\(baseURL)/rooms/\(roomId)/users/\(userId)/ready") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["is_ready": isReady]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    private func updateMuteState(roomId: String, userId: String, isMuted: Bool) async throws {
        guard let url = URL(string: "\(baseURL)/rooms/\(roomId)/users/\(userId)/mute") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["is_muted": isMuted]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    private func startGameRequest(roomId: String) async throws {
        guard let url = URL(string: "\(baseURL)/rooms/\(roomId)/start") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    private func sendAnswer(roomId: String, userId: String, answerUserId: String) async throws {
        guard let url = URL(string: "\(baseURL)/answers/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "room_id": roomId,
            "user_id": userId,
            "answer_user_id": answerUserId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    private func resetGameRequest(roomId: String) async throws {
        guard let url = URL(string: "\(baseURL)/rooms/\(roomId)/reset") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - WebSocket Methods
    
    private func connectWebSocket(roomId: String) async throws {
        guard let url = URL(string: "\(wsBaseURL)/ws/rooms/\(roomId)") else {
            throw URLError(.badURL)
        }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // メッセージ受信を開始
        receiveMessages()
    }
    
    private func disconnectWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.handleWebSocketMessage(message)
                // 次のメッセージを受信するために再帰的に呼び出す
                self.receiveMessages()
                
            case .failure(let error):
                self.onError?("WebSocketエラー: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleWebSocketMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let type = json["type"] as? String else {
                return
            }
            
            handleWebSocketEvent(type: type, json: json)
            
        case .data(let data):
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let type = json["type"] as? String else {
                return
            }
            
            handleWebSocketEvent(type: type, json: json)
            
        @unknown default:
            break
        }
    }
    
    private func handleWebSocketEvent(type: String, json: [String: Any]) {
        switch type {
        case "USER_JOINED":
            handleUserJoined(json: json)
            
        case "USER_LEFT":
            handleUserLeft(json: json)
            
        case "USERS_CHANGED":
            handleUsersChanged(json: json)
            
        case "STATE_CHANGE":
            handleStateChange(json: json)
            
        case "ROLE_ASSIGNED":
            handleRoleAssigned(json: json)
            
        case "ANSWER_SUBMITTED":
            handleAnswerSubmitted(json: json)
            
        case "GAME_RESET":
            handleGameReset()
            
        case "RTC_SIGNAL":
            // WebRTC関連は別途実装
            break
            
        default:
            print("未知のイベント: \(type)")
        }
    }
    
    // MARK: - WebSocket Event Handlers
    
    private func handleUserJoined(json: [String: Any]) {
        guard let userDict = json["user"] as? [String: Any],
              let users = parseUsers(from: [userDict]) else {
            return
        }
        
        // USERS_CHANGEDイベントが来るので、ここでは特に何もしない
        // または、必要に応じてonUsersChangedを呼び出す
    }
    
    private func handleUserLeft(json: [String: Any]) {
        guard let userId = json["user_id"] as? String else {
            return
        }
        
        // user_idをそのまま渡す
        onUserLeft?(userId)
    }
    
    private func handleUsersChanged(json: [String: Any]) {
        guard let usersArray = json["users"] as? [[String: Any]],
              let users = parseUsers(from: usersArray) else {
            return
        }
        
        onUsersChanged?(users)
    }
    
    private func handleStateChange(json: [String: Any]) {
        guard let state = json["state"] as? String else {
            return
        }
        
        if state == "IN_GAME" {
            onGameStarted?()
        }
    }
    
    private func handleRoleAssigned(json: [String: Any]) {
        guard let usersArray = json["users"] as? [[String: Any]],
              let users = parseUsers(from: usersArray) else {
            return
        }
        
        onRolesAssigned?(users)
    }
    
    private func handleAnswerSubmitted(json: [String: Any]) {
        guard let playerAnswerDict = json["player_answer"] as? [String: Any],
              let userId = playerAnswerDict["user_id"] as? String,
              let answerUserId = playerAnswerDict["answer_user_id"] as? String else {
            return
        }
        
        // user_idとanswer_user_idをそのまま渡す
        onAnswerSubmitted?(userId, answerUserId)
    }
    
    private func handleGameReset() {
        print("ゲームがリセットされました")
        onGameReset?()
    }
    
    // MARK: - Helper Methods
    
    private func parseUsers(from array: [[String: Any]]) -> [User]? {
        var users: [User] = []
        
        for userDict in array {
            guard let userId = userDict["user_id"] as? String,
                  let name = userDict["name"] as? String else {
                continue
            }
            
            let isMuted = userDict["is_muted"] as? Bool ?? false
            let isReady = userDict["is_ready"] as? Bool ?? false
            let roleString = userDict["role"] as? String
            
            let role: Role
            if let roleString = roleString {
                switch roleString {
                case "WEREWOLF":
                    role = .werewolf
                case "VILLAGER":
                    role = .villager
                default:
                    role = .undefined
                }
            } else {
                role = .undefined
            }
            
            let user = User(userId: userId, name: name, isMuted: isMuted, isReady: isReady, role: role)
            users.append(user)
        }
        
        return users.isEmpty ? nil : users
    }
    
    // MARK: - URLSessionWebSocketDelegate
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket接続が確立されました")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket接続が閉じられました")
    }
}
