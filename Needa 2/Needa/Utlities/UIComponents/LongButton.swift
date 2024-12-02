//
//  LongButton.swift
//  Needa
//
//  Created by Qazi Ammar Arshad on 09/10/2024.
//

import SwiftUI

struct LongButton: View {
    
    var text: String
    var action: () -> Void
    
    var body: some View {
        
        Button(action: {
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .foregroundStyle(Color("button"))
                    .frame(height: 48)
                
                HStack {
                    Text(text)
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    LongButton(text: "إنشاء حساب مستخدم", action: {})
}
