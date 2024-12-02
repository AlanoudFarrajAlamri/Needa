//
//  FirebaseManager.swift
//  Needa
//
//  Created by Qazi Ammar Arshad on 09/10/2024.
//

import CloudKit
import Foundation
import FirebaseFunctions
import AVFAudio

class FirebaseManager {
    
    var callerlocationManager = LocationManager.shared
    static let shared = FirebaseManager()
    
    // MARK: - Public Methods
    
    func sendEmergencyCall() {
        debugPrint("Send Emergency Call is triggerd")
        fetchCloseHealthcareProviders { tokens in
            guard !tokens.isEmpty else {
                print("No nearby tokens received or error occurred.")
                return
            }
            
            self.sendNeedaWithRecord(tokens: tokens)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchCloseHealthcareProviders(completion: @escaping ([String]) -> Void) {
        var nearbyProviders: [String: CLLocation] = [:]
        var tokens: [String] = []
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found in UserDefaults.")
            completion([])
            return
        }
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Fetch user record to determine nearby healthcare providers
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            guard error == nil else {
                print("Error fetching user record: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            // You need to write a proper location manager to get the user's location.
             guard let userLocation = self.callerlocationManager.userLocation else {
                 print("User location not found.")
                 completion([])
                 return
             }
            
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "HCP", predicate: predicate)
            
            privateDatabase.perform(query, inZoneWith: nil) { records, error in
                guard error == nil, let records = records else {
                    print("CloudKit Query Error: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                for record in records {
                    if let location = record["location"] as? CLLocation,
                       let reference = record["UserID"] as? CKRecord.Reference {
                        let recordName = reference.recordID.recordName
                        
                        // Filter out the user's own location and check distance
                        if recordName != userRecordIDString {
                            nearbyProviders[recordName] = location
                        }
                    }
                }
                
                if nearbyProviders.isEmpty {
                    print("No nearby locations found.")
                    DispatchQueue.main.async {
//                        self.alertMessage = "لا يوجد ممارسين صحيين بالقرب منك"
//                        self.showingAlert = true
                    }
                    completion([])
                    return
                }
                
                // Fetch tokens for each nearby provider
                let group = DispatchGroup()
                for (recordName, _) in nearbyProviders {
                    group.enter()
                    let recordID = CKRecord.ID(recordName: recordName)
                    privateDatabase.fetch(withRecordID: recordID) { record, error in
                        if let error = error {
                            print("Failed to fetch token for \(recordName): \(error.localizedDescription)")
                        } else if let record = record, let token = record["token"] as? String {
                            tokens.append(token)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    print("Tokens fetched for nearby locations: \(tokens)")
                    completion(tokens)
                }
            }
        }
    }
    
    private func sendNeedaWithRecord(tokens: [String], hcpResponse: String? = nil) {
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found.")
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        let needaRecord = CKRecord(recordType: "NeedaCall")
        
        // You need to write a proper location manager to get the user's location.
        needaRecord["UserLocation"] = callerlocationManager.userLocation
        
        needaRecord["UserID"] = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
        if let response = hcpResponse {
            needaRecord["HCPResponse"] = response
        }
        
        // Save the needa record
        privateDatabase.save(needaRecord) { [weak self] _, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit Save Error: \(error.localizedDescription)")
                    return
                }
                
                let needaRecordName = needaRecord.recordID.recordName
                print("Needa Record saved: \(needaRecordName)")
                
                let validTokens = tokens.compactMap { $0 }
                guard !validTokens.isEmpty else {
                    print("No valid tokens to send notifications.")
                    return
                }
                
                for token in validTokens{
                    self.sendNotification(token: token, needaRecordId: needaRecordName, title: "هناك نداء بانتظارك", body: "اقبل الطلب لتتمكن من استعراض معلومات النداء")}
            }
        }
    }
    
     func sendNotification(token: String, needaRecordId: String, title: String, body: String) {
        guard let url = URL(string: "https://us-central1-needa-efd17.cloudfunctions.net/sendNotificationV3") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "token": token,
            "needaRecordId": needaRecordId,
            "title": title,
            "body": body
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending request: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                let responseData = String(data: data, encoding: .utf8)
                print("Response Data: \(responseData ?? "No Data")")
            }
        }
        
        task.resume()
    }
    
    
    
    var audioPlayer: AVAudioPlayer?

    func triggerSound() {
        print("here 22")

        if let soundURL = Bundle.main.url(forResource: "emergencysound", withExtension: "mp3") {
            do {
                print("here 33")
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Unable to play sound: \(error)")
            }
        }
    }


}

