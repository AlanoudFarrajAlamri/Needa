//
//  ContentView.swift
//  Needa Watch App
//
//  Created by shouq on 08/10/2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var phoneConnector = PhoneConnector()
    @State private var showAlert = false

    var body: some View {
        
        ZStack {
            Color("backgroundColor").ignoresSafeArea(.all)

            VStack {
                Button(action: {
                    // Send message to trigger sound on the iOS app
                    showAlert = true

                }) {
                    Text("نداء")
                        .font(.system(size: 28, weight: .bold))
                        .frame(width: 160, height: 160) // Size for the circular button
                        .background(Color.button)
                        .foregroundColor(.white)
                        .clipShape(Circle()) // Make the button circular
                        .overlay(Circle().stroke(Color.white, lineWidth: 5)) // border
                }.alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("تأكيد النداء"),
                        message: Text("هل أنت متأكد أنك تريد إرسال نداء الحاجة؟"),
                        primaryButton: .destructive(Text("نعم")) {
                            let message = ["action": "triggerSound"]
                            phoneConnector.sendDataToPhone(message)},
                        secondaryButton: .cancel(Text("إلغاء"))
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
