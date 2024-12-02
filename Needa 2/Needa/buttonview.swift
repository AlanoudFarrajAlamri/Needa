//
//  buttonview.swift
//  NeedaApp
//
//  Created by Reham  on 02/09/1445 AH.
//

import SwiftUI  // Import SwiftUI to use for building the user interface

struct InfoButtonView: View {
    @Binding var isBubbleVisible: Bool //Binding to a boolean that determines if the informational bubble is visible
    @Binding var bubbleText: String // Binding to the text to be displayed inside the bubble
    
    var body: some View {
        Image(systemName: "info.circle") // we use a system image of an info circle
            .resizable()
            .frame(width: 20, height: 20)
            .onTapGesture {
                isBubbleVisible.toggle() // Toggle visibility of the bubble when the image is tapped
            }
            .overlay(
                Group {
                    if isBubbleVisible {
                        BubbleView(text: $bubbleText)
                    }
                }
            )
        
    }
}

struct BubbleView: View {
    @Binding var text: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 1.0, green: 0.388, blue: 0.278))
            .frame(width: 250, height: 110)
            .overlay(
                Text(text)
                    .foregroundColor(.white)
                    .padding()
            )
            .offset(x:-130, y:-50)
    }
}
