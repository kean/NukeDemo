// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import Foundation
import SwiftUI
import FetchImage

@available(iOS 14.0, *)
struct PrefetchDemoView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                let side = geometry.size.width / 4
                let item = GridItem(.fixed(side), spacing: 2)
                LazyVGrid(columns: Array(repeating: item, count: 4), spacing: 2) {
                    ForEach(demoPhotosURLs.indices) {
                        ImageView(url: demoPhotosURLs[$0])
                            .frame(width: side, height: side)
                            .clipped()
                    }
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct ImageView: View {
    let url: URL

    @StateObject private var image = FetchImage()

    var body: some View {
        ZStack {
            Rectangle().fill(Color.gray)
            image.view?
                .resizable()
                .scaledToFill()

        }
        .onAppear { image.load(url) }
        .onDisappear(perform: image.reset)
    }
}
