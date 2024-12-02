
// navigationmanager.swift
//NeedaApp

// Created by Ruba Kef on 29/10/1445 AH.


import Foundation
import CoreLocation

// we defined SharedViewModel that conforms to ObservableObject for data binding

class SharedViewModel: ObservableObject {
    @Published var selectedLocations: [IdentifiableLocation] = [] // A published array to store the selected locations, allowing views to react to changes
    @Published var isActiveStates: [Bool] = [] // A published array to track the active states of multiple navigation items, allowing views to react to changes
    @Published var needaRecords: [String] = [] // A published array to store multiple needa records for the needa call

}

import Combine

class NeedaStatusTracker: ObservableObject {
    static let shared = NeedaStatusTracker()
    @Published var status: Int = 0
    @Published var statusDetails: [String: String] = [:]


    func reset() {
        DispatchQueue.main.async {
            self.status = 0
            self.statusDetails.removeAll()
        }
    }
}

