//
//  ContentView.swift
//  mlfilterimage
//
//  Created by Johann Petzold on 14/05/2025.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var isPickerLoading: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var isLoadingFilter: Bool = false
    @State private var filteredImage: UIImage? = nil
    @State private var stretchImage: Bool = false
    
    var body: some View {
        VStack {
            
            VStack(spacing: 8) {
                
                VStack(spacing: 4) {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                        
                        Text("\(String(format: "%.0f", selectedImage.size.width))x\(String(format: "%.0f", selectedImage.size.height))")
                    } else {
                        Text("Original Image")
                            .bold()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                
                Divider()
                
                VStack(spacing: 4) {
                    if let filteredImage {
                        Image(uiImage: filteredImage)
                            .resizable()
                            .scaledToFit()
                        
                        Text("\(String(format: "%.0f", filteredImage.size.width))x\(String(format: "%.0f", filteredImage.size.height))")
                    } else {
                        Text("Result Image")
                            .bold()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.secondary.opacity(0.25))
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
            
            VStack(spacing: 4) {
                
                HStack {
                    
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        HStack(spacing: 8) {
                            if isPickerLoading {
                                ProgressView()
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            
                            Text("Choose an image")
                                .font(.headline)
                                .bold()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .fixedSize()
                    }
                    .disabled(isPickerLoading)
                    .onChange(of: selectedItem) { oldItem, newItem in
                        if let newItem {
                            filterImage(from: newItem)
                        }
                    }
                    
                    Toggle(isOn: $stretchImage) {
                        Text("Original Size")
                    }
                    
                }
                .padding(.horizontal, 16)
                
                Button(action: onTapSaveFilteredImage) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("Save Image")
                            .font(.headline)
                            .bold()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
                .disabled(filteredImage == nil)
                
            }
            
        }
    }
    
    private func filterImage(from selectedItem: PhotosPickerItem) {
        isPickerLoading = true
        Task.detached(priority: .userInitiated) {
            guard let data = try? await selectedItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data),
                  let downsizedImage = uiImage.downsizeImage(maxDimension: 1920)?.cgImage,
                  let model = try? AbstractFilter(configuration: .init()).model,
                  let resultImage = await model.applyFilter(to: downsizedImage, originalImage: uiImage, stretchToOriginalSize: stretchImage)
            else {
                await MainActor.run {
                    isPickerLoading = false
                }
                return
            }
            await MainActor.run {
                filteredImage = resultImage
                selectedImage = uiImage
                isPickerLoading = false
            }
        }
    }
    
    private func onTapSaveFilteredImage() {
        guard let filteredImage else { return }
        UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, nil)
    }
}

#Preview {
    ContentView()
}
