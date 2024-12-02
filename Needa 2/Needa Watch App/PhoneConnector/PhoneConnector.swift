//
//  PhoneConnector.swift
//  Needa Watch App
//
//  Created by Qazi Ammar Arshad on 08/10/2024.
//

import Foundation
import WatchConnectivity

class PhoneConnector: NSObject, ObservableObject {
    static let shared = PhoneConnector()
    @Published var name = ""
    
    public let session = WCSession.default
    
     override init() {
        super.init()
        if WCSession.isSupported() {
            debugPrint("PhoneConnector Constructor called")
            session.delegate = self
            session.activate()
        }
    }
}

extension PhoneConnector: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("session activation failed with error: \(error.localizedDescription)")
            return
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
                dataReceivedFromPhone(userInfo)
    }
    
    // MARK: use this for testing in simulator
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
                dataReceivedFromPhone(message)
    }
    
}

// MARK: - send data to phone
extension PhoneConnector {
    
    public func sendDataToPhone(_ message: [String: Any]) {
        if !isPhoneReachable() {
            print("Phone is not reachable")
            return
        }

        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message to phone: \(error.localizedDescription)")
        }
        debugPrint("Data sent from watch to phone: \(message)")
    }

}

// MARK: - receive data
extension PhoneConnector {
    
    public func dataReceivedFromPhone(_ info:[String:Any]) {
        debugPrint(info)
    }
    
    // MARK: - receive data
    public func dataReceivedFromWatch(_ info: [String: Any]) {
        debugPrint("Received data from watch: \(info)")
    }
    
    public func isPhoneReachable() -> Bool {
        return session.isReachable
    }
}
