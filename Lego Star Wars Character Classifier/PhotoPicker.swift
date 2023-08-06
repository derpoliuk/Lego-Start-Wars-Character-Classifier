//
//  PhotoPicker.swift
//  Lego Star Wars Character Classifier
//
//  Created by Stanislav Derpoliuk on 2023-08-05.
//

import PhotosUI
import SwiftUI

struct PhotoPickerView: UIViewControllerRepresentable {
    private let onImagePicked: (UIImage) -> Void

    @Environment(\.presentationMode) private var presentationMode

    init(onImagePicked: @escaping (UIImage) -> Void) {
        self.onImagePicked = onImagePicked
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images

        let photoPicker = PHPickerViewController(configuration: config)
        photoPicker.delegate = context.coordinator

        return photoPicker
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: { self.presentationMode.wrappedValue.dismiss() }, onImagePicked: self.onImagePicked)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void

        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            onDismiss()

            guard let result = results.first else {
                return
            }

            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let error {
                    print("Photo picker failed with error: \(error.localizedDescription)")
                    return
                }

                guard let photo = object as? UIImage else {
                    print("Photo picker's image has a wrong type: \(type(of: object))")
                    return
                }
                self.onImagePicked(photo)
            }
        }
    }
}
