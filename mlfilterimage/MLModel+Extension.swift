//
//  MLModel+Extension.swift
//  mlfilterimage
//
//  Created by Johann Petzold on 14/05/2025.
//

import UIKit
import CoreML
import CoreImage
import Vision

extension MLModel {
    
    func applyFilter(to inputCG: CGImage, originalImage: UIImage, stretchToOriginalSize: Bool) -> UIImage? {
        // Define how the image should be scaled and cropped before feeding it into the model
        let imageOptions: [MLFeatureValue.ImageOption: Any] = [
            .cropAndScale: VNImageCropAndScaleOption.scaleFit.rawValue
        ]
        
        let inputName = "image"
        let outputName = "stylizedImage"
        
        // Retrieve the image input constraints from the model's input description
        guard let imageConstraint = self.modelDescription.inputDescriptionsByName[inputName]?.imageConstraint else {
            print("Error getting image constraint")
            return nil
        }
        
        do {
            // Convert the input CGImage into a format compatible with Core ML
            let inputFeatureValue = try MLFeatureValue(cgImage: inputCG, constraint: imageConstraint, options: imageOptions)
            let inputFeatures = try MLDictionaryFeatureProvider(dictionary: [inputName: inputFeatureValue])
            
            // Perform prediction with the model
            let prediction = try self.prediction(from: inputFeatures)
            
            // Retrieve the resulting image as a pixel buffer
            guard let imgBuffer = prediction.featureValue(for: outputName)?.imageBufferValue else {
                print("Error getting image buffer")
                return nil
            }
            
            // Convert the pixel buffer to a CIImage
            let outputCIImage = CIImage(cvImageBuffer: imgBuffer)
            
            guard stretchToOriginalSize else {
                // Return the downsized filtered image
                let context = CIContext()
                guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
                    return nil
                }
                return UIImage(cgImage: outputCGImage)
            }
            
            // Calculate scaling to match the original image's dimensions
            let inputWidth = CGFloat(originalImage.size.width)
            let inputHeight = CGFloat(originalImage.size.height)
            let outputExtent = outputCIImage.extent
            let scaleX = inputWidth / outputExtent.width
            let scaleY = inputHeight / outputExtent.height
            let scale = min(scaleX, scaleY)
            
            // Scale the stylized CIImage to fit within the original image dimensions
            let scaledCIImage = outputCIImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            
            // Center the scaled image within the original image frame
            let newExtent = scaledCIImage.extent
            let dx = (inputWidth - newExtent.width) / 2
            let dy = (inputHeight - newExtent.height) / 2
            let centeredCIImage = scaledCIImage.transformed(by: CGAffineTransform(translationX: dx, y: dy))
            
            // Create a final UIImage from the CIImage
            let context = CIContext()
            guard let originalCGImage = originalImage.cgImage else {
                print("Error getting cgImage from original image")
                return nil
            }
            let originalCIImage = CIImage(cgImage: originalCGImage)
            
            // Composite the centered stylized image over the original image's extent
            guard let outputCGImage = context.createCGImage(centeredCIImage, from: originalCIImage.extent) else {
                return nil
            }
            
            return UIImage(cgImage: outputCGImage)
        } catch {
            print("Error getting stylized image: \(error.localizedDescription)")
            return nil
        }
    }
}
