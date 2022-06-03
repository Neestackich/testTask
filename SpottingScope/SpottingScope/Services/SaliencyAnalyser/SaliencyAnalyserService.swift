//
//  SaliencyAnalyserService.swift
//  SpottingScope
//
//  Created by Vittcal Neestackich on 2.06.22.
//

import UIKit
import Vision

final class SaliencyAnalyserService: SaliencyAnalyserServiceProtocol {

}

// MARK: - Public

extension SaliencyAnalyserService {

    func getSaliencyCoordinates(for image: UIImage) -> SaliencyCoordinates {
        guard let cgImage = image.cgImage else {
            return SaliencyCoordinates(topLeft: CGPoint.zero, topRight: CGPoint.zero, bottomRight: CGPoint.zero, bottomLeft: CGPoint.zero)
        }

        let salientObjects = getSalientObjects(for: cgImage)
        let imageWithBorderedSaliency = computeSaliencyCoordinates(for: image, with: salientObjects)

        return imageWithBorderedSaliency
    }


}

// MARK: - Private

private extension SaliencyAnalyserService {

    private func getSalientObjects(for cgImage: CGImage) -> VNRectangleObservation {
        let saliencyRequest = VNGenerateAttentionBasedSaliencyImageRequest(completionHandler: nil)
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try requestHandler.perform([saliencyRequest])
        } catch {
            return VNRectangleObservation()
        }

        guard let result = saliencyRequest.results?.last, let observation = result.salientObjects?.last else {
            return VNRectangleObservation()
        }

        return observation
    }

    private func computeSaliencyCoordinates(for image: UIImage, with observation: VNRectangleObservation) -> SaliencyCoordinates {
        var topLeft = CGPoint(
            x: observation.bottomLeft.x * image.size.width,
            y: observation.bottomLeft.y * image.size.height
        )
        var topRight = CGPoint(
            x: observation.bottomRight.x * image.size.width,
            y: observation.bottomRight.y * image.size.height
        )
        var bottomRight = CGPoint(
            x: observation.topRight.x * image.size.width,
            y: observation.topRight.y * image.size.height
        )
        var bottomLeft = CGPoint(
            x: observation.topLeft.x * image.size.width,
            y: observation.topLeft.y * image.size.height
        )

        let invertedTopLeft = image.size.height - bottomLeft.y
        let invertedBottomLeft = image.size.height - topLeft.y
        topLeft.y = invertedTopLeft
        bottomLeft.y = invertedBottomLeft
        topRight.y = topLeft.y
        bottomRight.y = bottomLeft.y

        let saliencyCoordinates = SaliencyCoordinates(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        return saliencyCoordinates
    }

}
