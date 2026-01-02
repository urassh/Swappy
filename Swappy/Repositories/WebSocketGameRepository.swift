//
//  WebSocketGameRepository.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation
import Combine

/// WebSocket経由でBackendと通信するGameRepository実装
class WebSocketGameRepository: NSObject, GameRepositoryProtocol {
    
    // MARK: - Properties
    
    private let eventSubject = PassthroughSubject<GameEvent, Never>()
    var eventPublisher: AnyPublisher<GameEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let baseURL: String
    private var currentUserId: String?
    private var currentKeyword: String?
    
    // MARK: - Initialization
    
    init(baseURL: String = "ws://localhost:8080") {
        self.baseURL = baseURL
        super.init()
    }
    
    // MARK: - GameRepositoryProtocol
    
    func joinRoom(keyword: String, userName: String) async throws {
        self.currentKeyword = keyword
        
        // WebSocket接続を確立
        guard let url = URL(string: "\(baseURL)/game/\(keyword)") else {
            throw GameRepositoryError.invalidURL
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // メッセージ受信を開始
        receiveMessage()
        
        // 参加メッセージを送信
        let joinMessage: [String: Any] = [
            "type": "join",
            "userName": userName
        ]
        try await sendMessage(joinMessage)
    }
    
    func leaveRoom() async throws {
        let leaveMessage: [String: Any] = [
            "type": "leave"
        ]
        try await sendMessage(leaveMessage)
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    func toggleReady() async throws {
        let readyMessage: [String: Any] = [
            "type": "toggleReady"
        ]
        try await sendMessage(readyMessage)
    }
    
    func toggleMute(isMuted: Bool) async throws {
        let muteMessage: [String: Any] = [
            "type": "toggleMute",
            "isMuted": isMuted
        ]
        try await sendMessage(muteMessage)
    }
    
    func submitAnswer(userId: String) async throws {
        let answerMessage: [String: Any] = [
            "type": "submitAnswer",
            "selectedUserId": userId
        ]
        try await sendMessage(answerMessage)
    }
    
    func resetGame() async throws {
        let resetMessage: [String: Any] = [
            "type": "reset"
        ]
        try await sendMessage(resetMessage)
    }
    
    // MARK: - Private Methods
    
    private func sendMessage(_ message: [String: Any]) async throws {
        guard let webSocketTask = webSocketTask else {
            throw GameRepositoryError.notConnected
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: message)
        let message = URLSessionWebSocketTask.Message.data(jsonData)
        
        try await webSocketTask.send(message)
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                // 次のメッセージを受信
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self?.eventSubject.send(.error(message: error.localizedDescription))
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            parseEvent(from: data)
            
        case .string(let text):
            if let data = text.data(using: .utf8) {
                parseEvent(from: data)
            }
            
        @unknown default:
            break
        }
    }
    
    private func parseEvent(from data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let type = json["type"] as? String else {
                return
            }
            
            let event: GameEvent? = switch type {
            case "userJoined":
                parseUserJoined(from: json)
                
            case "userLeft":
                parseUserLeft(from: json)
                
            case "userReadyStateChanged":
                parseUserReadyStateChanged(from: json)
                
            case "userMuteStateChanged":
                parseUserMuteStateChanged(from: json)
                
            case "rolesAssigned":
                parseRolesAssigned(from: json)
                
            case "videoCallStarted":
                .videoCallStarted
                
            case "videoCallCountdown":
                parseVideoCallCountdown(from: json)
                
            case "answerPhaseStarted":
                .answerPhaseStarted
                
            case "answerSubmitted":
                parseAnswerSubmitted(from: json)
                
            case "answerRevealed":
                parseAnswerRevealed(from: json)
                
            case "gameReset":
                .gameReset
                
            case "error":
                parseError(from: json)
                
            default:
                nil
            }
            
            if let event = event {
                eventSubject.send(event)
            }
            
        } catch {
            print("Failed to parse event: \(error)")
        }
    }
    
    // MARK: - Parsing Methods
    
    private func parseUserJoined(from json: [String: Any]) -> GameEvent? {
        guard let userData = json["user"] as? [String: Any],
              let id = userData["id"] as? String,
              let name = userData["name"] as? String else {
            return nil
        }
        
        let isMuted = userData["isMuted"] as? Bool ?? false
        let isReady = userData["isReady"] as? Bool ?? false
        
        let user = User(id: id, name: name, isMuted: isMuted, isReady: isReady)
        return .userJoined(user)
    }
    
    private func parseUserLeft(from json: [String: Any]) -> GameEvent? {
        guard let userId = json["userId"] as? String else {
            return nil
        }
        return .userLeft(userId: userId)
    }
    
    private func parseUserReadyStateChanged(from json: [String: Any]) -> GameEvent? {
        guard let userId = json["userId"] as? String,
              let isReady = json["isReady"] as? Bool else {
            return nil
        }
        return .userReadyStateChanged(userId: userId, isReady: isReady)
    }
    
    private func parseUserMuteStateChanged(from json: [String: Any]) -> GameEvent? {
        guard let userId = json["userId"] as? String,
              let isMuted = json["isMuted"] as? Bool else {
            return nil
        }
        return .userMuteStateChanged(userId: userId, isMuted: isMuted)
    }
    
    private func parseRolesAssigned(from json: [String: Any]) -> GameEvent? {
        guard let usersData = json["users"] as? [[String: Any]],
              let swappedUserId = json["swappedUserId"] as? String else {
            return nil
        }
        
        let users = usersData.compactMap { userData -> User? in
            guard let id = userData["id"] as? String,
                  let name = userData["name"] as? String,
                  let roleString = userData["role"] as? String else {
                return nil
            }
            
            let role: Role = roleString == "werewolf" ? .werewolf : .villager
            let isMuted = userData["isMuted"] as? Bool ?? false
            let isReady = userData["isReady"] as? Bool ?? false
            
            return User(id: id, name: name, isMuted: isMuted, isReady: isReady, role: role)
        }
        
        return .rolesAssigned(users: users, swappedUserId: swappedUserId)
    }
    
    private func parseVideoCallCountdown(from json: [String: Any]) -> GameEvent? {
        guard let timeRemaining = json["timeRemaining"] as? Int else {
            return nil
        }
        return .videoCallCountdown(timeRemaining: timeRemaining)
    }
    
    private func parseAnswerSubmitted(from json: [String: Any]) -> GameEvent? {
        guard let userId = json["userId"] as? String,
              let selectedUserId = json["selectedUserId"] as? String else {
            return nil
        }
        return .answerSubmitted(userId: userId, selectedUserId: selectedUserId)
    }
    
    private func parseAnswerRevealed(from json: [String: Any]) -> GameEvent? {
        guard let answersData = json["answers"] as? [[String: Any]],
              let swappedUserId = json["swappedUserId"] as? String else {
            return nil
        }
        
        let answers = answersData.compactMap { answerData -> PlayerAnswer? in
            guard let id = answerData["id"] as? String,
                  let playerName = answerData["playerName"] as? String,
                  let isCorrect = answerData["isCorrect"] as? Bool else {
                return nil
            }
            
            let selectedUserId = answerData["selectedUserId"] as? String
            return PlayerAnswer(id: id, playerName: playerName, selectedUserId: selectedUserId, isCorrect: isCorrect)
        }
        
        return .answerRevealed(answers: answers, swappedUserId: swappedUserId)
    }
    
    private func parseError(from json: [String: Any]) -> GameEvent? {
        guard let message = json["message"] as? String else {
            return nil
        }
        return .error(message: message)
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketGameRepository: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket connected")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket disconnected: \(closeCode)")
    }
}

// MARK: - Errors

enum GameRepositoryError: Error {
    case invalidURL
    case notConnected
    case encodingError
    case decodingError
}
