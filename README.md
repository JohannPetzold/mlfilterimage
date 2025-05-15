# 🖼️ mlfilterimage

**mlfilterimage** is a minimal iOS demo app that applies an **artistic filter** to a selected image using a **Core ML Style Transfer model**.

## 🚀 Main Feature

- Load an image from the photo library  
- Apply a custom visual style using a Core ML model trained with [Create ML](https://developer.apple.com/documentation/createml)  
- Display the stylized result in a smooth SwiftUI interface

## 🧠 Model

The app uses a Core ML model generated with the **Style Transfer** template from Create ML.  
It has been modified using `coremltools` to support custom input and output image sizes.

## 🛠️ Technologies

- SwiftUI  
- Core ML  
- Vision  
- Core Image

## 📦 Installation

Clone the repository, open `mlfilterimage.xcodeproj` in Xcode, and run the app on a simulator or real device.  

## 📄 License

This project is open source and available under the MIT License.
