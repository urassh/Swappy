//
//  RoleRevealViewModel.swift
//  Swappy
//
//  Created by 浦山秀斗 on 2026/01/02.
//

import Foundation

/// 役職表示画面のViewModel
@Observable
class RoleRevealViewModel {
    var countdown: Int = 5
    
    private let myRole: Role?
    private let onStartVideoCall: () -> Void
    private var timer: Timer?
    
    init(myRole: Role?, onStartVideoCall: @escaping () -> Void) {
        self.myRole = myRole
        self.onStartVideoCall = onStartVideoCall
        startCountdown()
    }
    
    var role: Role? {
        myRole
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                self.onStartVideoCall()
            }
        }
    }
    
    func skipToVideoCall() {
        timer?.invalidate()
        timer = nil
        onStartVideoCall()
    }
    
    deinit {
        timer?.invalidate()
    }
}
