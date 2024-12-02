//
//  ImagePicker.swift
//  Needa
//
//  Created by shouq on 24/04/1446 AH.
//

import SwiftUI
import UIKit
import Vision

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool // To manage the visibility of the picker
    @Binding var selectedImage: UIImage? // To store the selected image
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image // Set the selected image
            }
            parent.isPresented = false // Dismiss the picker
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false // Dismiss the picker if canceled
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self) // Create and return a Coordinator instance
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator // Assign the coordinator as the delegate
        picker.sourceType = .camera // Set the source type to camera
        picker.allowsEditing = false // Disable editing
        return picker // Return the configured image picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
}
