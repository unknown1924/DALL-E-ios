//
//  ContentView.swift
//  DALL-E
//
//  Created by 10683830 on 24/12/22.
//

import SwiftUI
import OpenAIKit

final class ViewModel: ObservableObject {
    private var openai: OpenAI?
    
    func setup() {
        openai = OpenAI(Configuration(
            organization: "Personal",
            apiKey: "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"
        ))
    }
    
    func generateImage(promt: String)  async -> UIImage? {
        guard let openai = openai else {
            return nil
        }
        
        do {
            let params = ImageParameters(prompt: promt, resolution: .medium, responseFormat: .base64Json)
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
        } catch {
            print(String(describing: error))
            return nil
        }

    }
}

struct ContentView: View {
    @State private var isImageLoading: Bool = false
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if let image = image {
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300)
                    } else {
                        if !isImageLoading {
                            Text("Type promt to generate image!")
                        }
                    }
                    VStack {
                        
                        Spacer()
                        if isImageLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(2)
                    }
                        Spacer()
                    }
                }
                Spacer()
                TextField("Type something here...", text: $text)
                    .padding()
                
                Button("Generate!") {
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        isImageLoading = true
                        Task {
                            let result = await viewModel.generateImage(promt: text)
                            if result == nil {
                                print("Failed to get image")
                            }
                            self.isImageLoading = false
                            self.image = result
                        }
                    }
                }
            }
            .navigationTitle("DALL-E")
            .onAppear {
                viewModel.setup()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
