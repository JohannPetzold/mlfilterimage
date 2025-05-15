//
//  UIImage+Extension.swift
//  mlfilterimage
//
//  Created by Johann Petzold on 14/05/2025.
//

import UIKit

extension UIImage {
    
    func downsizeImage(maxDimension: CGFloat) -> UIImage? {
        let width = self.size.width
        let height = self.size.height
        
        guard max(width, height) > maxDimension else {
            return self
        }
        
        let aspectRatio = width / height
        
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if aspectRatio > 1 {
            newWidth = maxDimension
            newHeight = maxDimension / aspectRatio
        } else {
            newWidth = maxDimension * aspectRatio
            newHeight = maxDimension
        }
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
