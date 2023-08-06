//
//  ContentView.swift
//  Lego Star Wars Character Classifier
//
//  Created by Stanislav Derpoliuk on 2023-08-05.
//

import SwiftUI

struct ContentView: View {
    @State private var showImagePicker = false
    @State private var image: UIImage?
    @State private var isPredicting = false
    @State private var predictionString = ""

    private let imagePredictor = ImagePredictor()

    var body: some View {
        VStack {
            if let image {
                ZStack(alignment: .bottomLeading) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                    if !predictionString.isEmpty {
                        Text(predictionString)
                            .foregroundColor(.white)
                            .background(.black)
                    }
                }
                .frame(maxHeight: .infinity)
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .frame(maxHeight: .infinity)
            }
            Spacer()
            VStack {
                Text(isPredicting ? "Predicting..." : "Capture image to predict character")
                    .padding()

                Button("Capture image") {
                    showImagePicker.toggle()
                }
            }
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .camera) { image in
                self.image = image
                DispatchQueue.global(qos: .userInitiated).async {
                    self.predictImage(image)
                }
            }
        }
    }

    private func predictImage(_ image: UIImage) {
        do {
            try imagePredictor.makePredictions(for: image, completionHandler: self.imagePredictionHandler)
        } catch {
            print("Failed to make prediction: \(error.localizedDescription)")
        }
    }

    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
        guard let predictions else {
            predictionString = "No predictions, check console log"
            return
        }

        let formatterPredictions = formatPredictions(predictions)
        let predictionsString = formatterPredictions.joined(separator: "\n")

        self.predictionString = predictionsString
    }

    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        // Vision sorts the classifications in descending confidence order.
        let topPredictions: [String] = predictions.prefix(2).map { prediction in
            var name = prediction.classification

            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

            return "\(name) - \(prediction.confidencePercentage)%"
        }

        return topPredictions
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
