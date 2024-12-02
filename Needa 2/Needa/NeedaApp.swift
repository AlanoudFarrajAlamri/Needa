//
//  NeedaApp.swift
//  Needa
//
//  Created by Qazi Ammar Arshad on 08/10/2024.
//

import SwiftUI

@main
struct NeedaApp: App {
    // Link the custom AppDelegate with SwiftUI.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var statusTracker = NeedaStatusTracker.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environmentObject(appDelegate.sharedViewModel)
               
            }
        }
    }
}
