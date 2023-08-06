//
//  ImageAnalyzer.swift
//  Lego Star Wars Character Classifier
//
//  Created by Stanislav Derpoliuk on 2023-08-05.
//

import Vision
import UIKit

final class ImagePredictor {
    static func createImageClassifier() -> VNCoreMLModel {
        let defaultConfig = MLModelConfiguration()
        let imageClassifier: Lego_Star_Wars_Character_Classifier_v2

        do {
            imageClassifier = try Lego_Star_Wars_Character_Classifier_v2(configuration: defaultConfig)
        } catch {
            fatalError("Unable to create an image classifier model instance: \(error.localizedDescription)")
        }

        let imageClassifierModel = imageClassifier.model

        let imageClassifierVisionModel: VNCoreMLModel

        do {
            imageClassifierVisionModel = try VNCoreMLModel(for: imageClassifierModel)
        } catch {
            fatalError("Unable to create a `VNCoreMLModel instance: \(error.localizedDescription)")
        }

        return imageClassifierVisionModel
    }

    private static let imageClassifier = createImageClassifier()

    struct Prediction {
        let classification: String
        let confidencePercentage: String
    }

    typealias ImagePredictionHandler = (_ predictions: [Prediction]?) -> Void
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()

    func makePredictions(for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        let orientation = CGImagePropertyOrientation(photo.imageOrientation)

        guard let photoImage = photo.cgImage else {
            fatalError("Photo doesn't have underlying CGImage")
        }

        let imageClassificationRequest = createImageClassificationRequest()
        predictionHandlers[imageClassificationRequest] = completionHandler

        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [imageClassificationRequest]

        // Start the image classification request.
        try handler.perform(requests)
    }

    private func createImageClassificationRequest() -> VNImageBasedRequest {
        let imageClassificationRequest = VNCoreMLRequest(
            model: ImagePredictor.imageClassifier,
            completionHandler: visionRequestHandler
        )
        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        #if targetEnvironment(simulator)
        // Workaround to fix the the issue on the Simulator: https://developer.apple.com/forums/thread/696714
        imageClassificationRequest.usesCPUOnly = true
        #endif
        return imageClassificationRequest
    }

    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler.")
        }

        var predictions: [Prediction]? = nil

        defer {
            predictionHandler(predictions)
        }

        if let error = error {
            print("Vision image classification error: \(error.localizedDescription)")
            return
        }

        if request.results == nil {
            print("Vision request has no results")
            return
        }

        guard let observations = request.results as? [VNClassificationObservation] else {
            print("VNRequest produced the wrong result type: \(type(of: request.results))")
            return
        }

        predictions = observations.map { observation in
            Prediction(
                classification: observation.identifier,
                confidencePercentage: observation.confidencePercentageString
            )
        }
    }
}

private extension VNClassificationObservation {
    /// Generates a string of the observation's confidence as a percentage.
    var confidencePercentageString: String {
        let percentage = confidence * 100

        switch percentage {
            case 100.0...:
                return "100"
            case 10.0..<100.0:
                return String(format: "%2.1f", percentage)
            case 1.0..<10.0:
                return String(format: "%2.1f", percentage)
            case ..<1.0:
                return String(format: "%1.2f", percentage)
            default:
                return String(format: "%2.1f", percentage)
        }
    }
}

private extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}
