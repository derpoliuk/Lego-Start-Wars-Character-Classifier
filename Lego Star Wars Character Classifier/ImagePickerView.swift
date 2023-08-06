//
//  ImagePickerView.swift
//  Lego Star Wars Character Classifier
//
//  Created by Stanislav Derpoliuk on 2023-08-05.
//

import SwiftUI

// Inspired by https://github.com/ralfebert/ImagePickerView
struct ImagePickerView: UIViewControllerRepresentable {
    private let sourceType: UIImagePickerController.SourceType
    private let onImagePicked: (UIImage) -> Void

    @Environment(\.presentationMode) private var presentationMode

    init(sourceType: UIImagePickerController.SourceType, onImagePicked: @escaping (UIImage) -> Void) {
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: { self.presentationMode.wrappedValue.dismiss() }, onImagePicked: self.onImagePicked)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void

        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                onImagePicked(image)
            } else if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            onDismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onDismiss()
        }
    }
}
