//
//  WatchConnector.swift
//  Needa
//
//  Created by Qazi Ammar Arshad on 08/10/2024.
//

import Foundation
import WatchConnectivity

class WatchConnector: NSObject, ObservableObject {
    static let shared = WatchConnector()
    
    public let session = WCSession.default
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            debugPrint("WatchConnector Constructor called")
            session.delegate = self
            session.activate() // Activate session
        }
    }
}

extension WatchConnector: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint("Session became inactive")
        // Handle session inactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        debugPrint("Session deactivated, reactivating")
        session.activate() // Reactivate session if needed
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Session activation failed with error: \(error.localizedDescription)")
            return
        }
        debugPrint("Session activated with state: \(activationState.rawValue)")
    }
    
    // Handle receiving messages from the watch
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        FirebaseManager.shared.sendEmergencyCall()
        handleMessage(message)
    }

    private func handleMessage(_ message: [String: Any]) {
        
        // Check if the message contains the correct command
        if let action = message["action"] as? String, action == "triggerSound" {
            DispatchQueue.main.async {
                // Trigger sound on the iOS app
                print("yes reached here")
                FirebaseManager.shared.triggerSound()
            }
        }
    }
}

// MARK: - Transverse
extension WatchConnector {
    
    // MARK: - send data to watch
    public func sendDataToWatch() {
        if !isWatchPaired() {
            print("Watch is not paired")
        }
        
        if !isWatchReachable() {
            print("Watch is not reachable")
        }
        
        let dict = ["isUserConnected": "Data from iPhone"]
        session.sendMessage(dict, replyHandler: nil) { error in
            print("Error sending message to watch: \(error.localizedDescription)")
        }
        
        debugPrint("Data is sent from iPhone to Watch")
    }
    
    // MARK: - receive data
    public func dataReceivedFromWatch(_ info: [String: Any]) {
        debugPrint("Received data from watch: \(info)")
        
        // This function triggers a notification to Firebase once data is received from the watch.
        // If your current implementation is correctly set up, the emergency call process will be initiated.
       
        
        FirebaseManager.shared.sendEmergencyCall()
    }
    
    public func isWatchReachable() -> Bool {
        return session.isReachable
    }
    
    public func isWatchPaired() -> Bool {
        return session.isPaired
    }
}
