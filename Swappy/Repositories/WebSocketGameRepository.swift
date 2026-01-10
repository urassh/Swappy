////
////  WebSocketGameRepository.swift
////  Swappy
////
////  Created by 浦山秀斗 on 2026/01/02.
////
//
//import Foundation
//import Combine
//
///// WebSocket経由でBackendと通信するGameRepository実装
//class WebSocketGameRepository: NSObject, GameRepositoryProtocol {
//    
//    // MARK: - Properties
//    
//    // イベントハンドラ
//    private var onUserJoined: ((User) -> Void)?
//    private var onUserLeft: ((User) -> Void)?
//    private var onUserReadyStateChanged: ((User, Bool) -> Void)?
//    private var onUserMuteStateChanged: ((String, Bool) -> Void)?
//    private var onRolesAssigned: (([String: Role], String) -> Void)?
//    private var onAnswerRevealed: (([PlayerAnswer]) -> Void)?
//    private var onError: ((String) -> Void)?
//    
//    private var webSocketTask: URLSessionWebSocketTask?
//    private let baseURL: String
//    private var currentUserId: String?
//    private var currentKeyword: String?
//    
//    // MARK: - Initialization
//    
//    init(baseURL: String = "wss://fastapi-for-swappy.onrender.com") {
//        self.baseURL = baseURL
//        super.init()
//    }
//    
//    // MARK: - GameRepositoryProtocol
//    
//    func setEventHandlers(
//        onUserJoined: @escaping (User) -> Void,
//        onUserLeft: @escaping (User) -> Void,
//        onUserReadyStateChanged: @escaping (User, Bool) -> Void,
//        onUserMuteStateChanged: @escaping (String, Bool) -> Void,
//        onRolesAssigned: @escaping ([String: Role], String) -> Void,
//        onAnswerRevealed: @escaping ([PlayerAnswer]) -> Void,
//        onError: @escaping (String) -> Void
//    ) {
//        self.onUserJoined = onUserJoined
//        self.onUserLeft = onUserLeft
//        self.onUserReadyStateChanged = onUserReadyStateChanged
//        self.onUserMuteStateChanged = onUserMuteStateChanged
//        self.onRolesAssigned = onRolesAssigned
//        self.onAnswerRevealed = onAnswerRevealed
//        self.onError = onError
//    }
//    
//    func joinRoom(keyword: String, me: User) async throws {
//        self.currentKeyword = keyword
//        self.currentUserId = me.id
//        
//        // WebSocket接続を確立
//        guard let url = URL(string: "\(baseURL)/ws/rooms/\(keyword)") else {
//            throw GameRepositoryError.invalidURL
//        }
//        
//        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//        webSocketTask = session.webSocketTask(with: url)
//        webSocketTask?.resume()
//        
//        // メッセージ受信を開始
//        receiveMessage()
//        
//        // 参加メッセージを送信
//        let joinMessage: [String: Any] = [
//            "type": "join",
//            "user": [
//                "id": me.id,
//                "name": me.name,
//                "isReady": me.isReady,
//                "isMuted": me.isMuted
//            ]
//        ]
//        try await sendMessage(joinMessage)
//    }
//    
//    func leaveRoom() async throws {
//        let leaveMessage: [String: Any] = [
//            "type": "leave"
//        ]
//        try await sendMessage(leaveMessage)
//        
//        webSocketTask?.cancel(with: .goingAway, reason: nil)
//        webSocketTask = nil
//    }
//    
//    func toggleReady() async throws {
//        let readyMessage: [String: Any] = [
//            "type": "toggleReady"
//        ]
//        try await sendMessage(readyMessage)
//    }
//    
//    func toggleMute(isMuted: Bool) async throws {
//        let muteMessage: [String: Any] = [
//            "type": "toggleMute",
//            "isMuted": isMuted
//        ]
//        try await sendMessage(muteMessage)
//    }
//    
//    func submitAnswer(userId: String) async throws {
//        let answerMessage: [String: Any] = [
//            "type": "submitAnswer",
//            "selectedUserId": userId
//        ]
//        try await sendMessage(answerMessage)
//    }
//    
//    func resetGame() async throws {
//        let resetMessage: [String: Any] = [
//            "type": "reset"
//        ]
//        try await sendMessage(resetMessage)
//    }
//    
//    // MARK: - Private Methods
//    
//    private func sendMessage(_ message: [String: Any]) async throws {
//        guard let webSocketTask = webSocketTask else {
//            throw GameRepositoryError.notConnected
//        }
//        
//        let jsonData = try JSONSerialization.data(withJSONObject: message)
//        let message = URLSessionWebSocketTask.Message.data(jsonData)
//        
//        try await webSocketTask.send(message)
//    }
//    
//    private func receiveMessage() {
//        webSocketTask?.receive { [weak self] result in
//            switch result {
//            case .success(let message):
//                self?.handleMessage(message)
//                // 次のメッセージを受信
//                self?.receiveMessage()
//                
//            case .failure(let error):
//                print("WebSocket receive error: \(error)")
//                self?.onError?(error.localizedDescription)
//            }
//        }
//    }
//    
//    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
//        switch message {
//        case .data(let data):
//            parseEvent(from: data)
//            
//        case .string(let text):
//            if let data = text.data(using: .utf8) {
//                parseEvent(from: data)
//            }
//            
//        @unknown default:
//            break
//        }
//    }
//    
//    private func parseEvent(from data: Data) {
//        do {
//            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                  let type = json["type"] as? String else {
//                return
//            }
//            
//            switch type {
//            case "userJoined":
//                if let user = parseUserJoined(from: json) {
//                    onUserJoined?(user)
//                }
//                
//            case "userLeft":
//                if let user = parseUserLeft(from: json) {
//                    onUserLeft?(user)
//                }
//                
//            case "userReadyStateChanged":
//                if let (user, isReady) = parseUserReadyStateChanged(from: json) {
//                    onUserReadyStateChanged?(user, isReady)
//                }
//                
//            case "userMuteStateChanged":
//                if let (userId, isMuted) = parseUserMuteStateChanged(from: json) {
//                    onUserMuteStateChanged?(userId, isMuted)
//                }
//                
//            case "rolesAssigned":
//                if let (userRoles, swappedUserId) = parseRolesAssigned(from: json) {
//                    onRolesAssigned?(userRoles, swappedUserId)
//                }
//                
//            case "answerRevealed":
//                if let answers = parseAnswerRevealed(from: json) {
//                    onAnswerRevealed?(answers)
//                }
//                
//            case "error":
//                if let message = parseError(from: json) {
//                    onError?(message)
//                }
//                
//            default:
//                break
//            }
//            
//        } catch {
//            print("Failed to parse event: \(error)")
//        }
//    }
//    
//    // MARK: - Parsing Methods
//    
//    private func parseUserJoined(from json: [String: Any]) -> User? {
//        guard let userData = json["user"] as? [String: Any],
//              let id = userData["id"] as? String,
//              let name = userData["name"] as? String else {
//            return nil
//        }
//        
//        let isMuted = userData["isMuted"] as? Bool ?? false
//        let isReady = userData["isReady"] as? Bool ?? false
//        
//        return User(id: id, name: name, isMuted: isMuted, isReady: isReady)
//    }
//    
//    private func parseUserLeft(from json: [String: Any]) -> User? {
//        guard let userData = json["user"] as? [String: Any],
//              let id = userData["id"] as? String,
//              let name = userData["name"] as? String else {
//            return nil
//        }
//        
//        let isMuted = userData["isMuted"] as? Bool ?? false
//        let isReady = userData["isReady"] as? Bool ?? false
//        
//        return User(id: id, name: name, isMuted: isMuted, isReady: isReady)
//    }
//    
//    private func parseUserReadyStateChanged(from json: [String: Any]) -> (User, Bool)? {
//        guard let userData = json["user"] as? [String: Any],
//              let id = userData["id"] as? String,
//              let name = userData["name"] as? String,
//              let isReady = userData["isReady"] as? Bool else {
//            return nil
//        }
//        
//        let isMuted = userData["isMuted"] as? Bool ?? false
//        let user = User(id: id, name: name, isMuted: isMuted, isReady: isReady)
//        
//        return (user, isReady)
//    }
//    
//    private func parseUserMuteStateChanged(from json: [String: Any]) -> (String, Bool)? {
//        guard let userId = json["userId"] as? String,
//              let isMuted = json["isMuted"] as? Bool else {
//            return nil
//        }
//        return (userId, isMuted)
//    }
//    
//    private func parseRolesAssigned(from json: [String: Any]) -> ([String: Role], String)? {
//        guard let rolesData = json["roles"] as? [String: String],
//              let swappedUserId = json["swappedUserId"] as? String else {
//            return nil
//        }
//        
//        var userRoles: [String: Role] = [:]
//        for (userId, roleString) in rolesData {
//            let role: Role = roleString == "werewolf" ? .werewolf : .villager
//            userRoles[userId] = role
//        }
//        
//        return (userRoles, swappedUserId)
//    }
//    
//
//    private func parseAnswerRevealed(from json: [String: Any]) -> [PlayerAnswer]? {
//        guard let answersData = json["answers"] as? [[String: Any]] else {
//            return nil
//        }
//        
//        let answers = answersData.compactMap { answerData -> PlayerAnswer? in
//            guard let id = answerData["id"] as? String,
//                  let playerName = answerData["playerName"] as? String,
//                  let isCorrect = answerData["isCorrect"] as? Bool else {
//                return nil
//            }
//            
//            let selectedUserId = answerData["selectedUserId"] as? String
//            return PlayerAnswer(id: id, playerName: playerName, selectedUserId: selectedUserId, isCorrect: isCorrect)
//        }
//        
//        return answers
//    }
//    
//    private func parseError(from json: [String: Any]) -> String? {
//        return json["message"] as? String
//    }
//}
//
//// MARK: - URLSessionWebSocketDelegate
//
//extension WebSocketGameRepository: URLSessionWebSocketDelegate {
//    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
//        print("✅ WebSocket connected")
//    }
//    
//    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
//        print("WebSocket disconnected: \(closeCode)")
//    }
//}
//
//// MARK: - Errors
//
//enum GameRepositoryError: Error {
//    case invalidURL
//    case notConnected
//    case encodingError
//    case decodingError
//}
