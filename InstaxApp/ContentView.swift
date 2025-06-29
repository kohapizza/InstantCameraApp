//
//  ContentView.swift
//  InstaxApp
//
//  Created by 佐伯小遥 on 2025/06/29.
//

import SwiftUI
import PhotosUI

// スタンプのモデル
struct Stamp: Identifiable {
    let id = UUID()
    var emoji: String
    var position: CGPoint
    var scale: CGFloat = 1.0
    var angle: Angle = .zero
}

struct ContentView: View {
    @State var selectedItem: PhotosPickerItem?
    @State var selectedImage: Image? = nil
    @State var text: String = ""
    @State private var showAlert: Bool = false
    @State var stamps: [Stamp] = []

    var body: some View {
        VStack(spacing: 20) {
            imageWithFrame
            
            TextField("テキストを入力", text: $text)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button {
                    stamps.append(Stamp(emoji: "❤️", position: CGPoint(x: 175, y: 260)))
                } label: {
                    Text("❤️")
                        .font(.largeTitle)
                }.disabled(selectedImage == nil)
                
                Button {
                    stamps.append(Stamp(emoji: "⭐️", position: CGPoint(x: 175, y: 260)))
                } label: {
                    Text("⭐️")
                        .font(.largeTitle)
                }.disabled(selectedImage == nil)
                
                Button {
                    stamps.append(Stamp(emoji: "🎧", position: CGPoint(x: 175, y: 260)))
                } label: {
                    Text("🎧")
                        .font(.largeTitle)
                }.disabled(selectedImage == nil)
                
                Button {
                    stamps.append(Stamp(emoji: "🥰", position: CGPoint(x: 175, y: 260)))
                } label: {
                    Text("🥰")
                        .font(.largeTitle)
                }.disabled(selectedImage == nil)
            }
            
            Button {
                savedEditedImage()
            } label: {
                HStack {
                    Text("保存する")
                    Image(systemName: "square.and.arrow.down")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .disabled(selectedImage == nil)
        }
        .onChange(of: selectedItem, initial: true) {
            loadImage()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("保存完了"),
                message: Text("画像がフォトライブラリに保存されました。"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    var imageWithFrame: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: 350, height: 520)
            .shadow(radius: 10)
            .overlay {
                ZStack {
                    VStack {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 300, height: 400)
                            .overlay {
                                if let displayImage = selectedImage {
                                    displayImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 300, height: 400)
                                        .clipped()
                                } else {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .padding(20)
                                        .background(Color.gray.opacity(0.7))
                                        .clipShape(.circle)
                                }
                            }
                        
                        Text(text)
                            .font(.custom("yosugara ver12", size: 40))
                            .foregroundStyle(.black)
                            .frame(height: 40)
                    }
                    
                    // スタンプ配置
                    ForEach($stamps) { $stamp in
                        Text(stamp.emoji)
                            .font(.system(size: 60))
                            .scaleEffect(stamp.scale)
                            .rotationEffect(stamp.angle)
                            .position(stamp.position)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        stamp.position = value.location
                                    }
                            )
                            .simultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        stamp.scale = value
                                    }
                            )
                            .simultaneousGesture(
                                RotationGesture()
                                    .onChanged { value in
                                        stamp.angle = value
                                    }
                            )
                    }

                    
                    // 写真選択
                    if selectedImage == nil {
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Color.clear
                                .contentShape(.rect)
                        }
                    }
                }
            }
    }

    private func loadImage() {
        guard let item = selectedItem else { return }
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let uiImage = UIImage(data: data) {
                    selectedImage = Image(uiImage: uiImage)
                }
            case .failure(let error):
                print("写真の読み込みに失敗しました: \(error.localizedDescription)")
            }
        }
    }

    private func savedEditedImage() {
        let renderer = ImageRenderer(content: imageWithFrame)
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            showAlert = true
            selectedImage = nil
            selectedItem = nil
            text = ""
            stamps = []
        }
    }
}

#Preview {
    ContentView()
}
