// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import NukeUI

@available(iOS 14.0, *)
struct LazyImageDemoView: View {
    private let items = allItems
    @State private var listId = UUID()

    private let pipeline = ImagePipeline {
        $0.dataLoader = {
            let config = URLSessionConfiguration.default
            config.urlCache = nil
            return DataLoader(configuration: config)
        }()
    }

    var body: some View {
        List(items) { item in
            VStack(spacing: 16) {
                Text(item.title)
                    .font(.headline)
                    .padding(.top, 32)
                makeImage(url: item.url)
            }
        }
        .id(listId)
        .navigationBarItems(trailing: Button(action: {
            ImagePipeline.shared.cache.removeAll()
            self.listId = UUID()
        }, label: {
            Image(systemName: "arrow.clockwise")
        }))
    }

    // This is where the image view is created.
    func makeImage(url: URL) -> some View {
        LazyImage(source: url)
            .animation(.default)
            .pipeline(pipeline)
            .frame(height: 320)
    }
}

private struct Item: Identifiable {
    var id: String { title }
    let title: String
    let url: URL
}

private let allItems = [
    Item(title: "Baseline JPEG", url: URL(string: "https://user-images.githubusercontent.com/1567433/120257591-80e2e580-c25e-11eb-8032-54f3a966aedb.jpeg")!),
    Item(title: "Progressive JPEG", url: URL(string: "https://user-images.githubusercontent.com/1567433/120257587-7fb1b880-c25e-11eb-93d1-7e7df2b9f5ca.jpeg")!),
    Item(title: "Animated GIF", url: URL(string: "https://cloud.githubusercontent.com/assets/1567433/6505557/77ff05ac-c2e7-11e4-9a09-ce5b7995cad0.gif")!),
    Item(title: "MP4 (Video)", url: URL(string: "https://kean.github.io/videos/cat_video.mp4")!),
    Item(title: "WebP", url: URL(string: "https://kean.github.io/images/misc/4.webp")!)
]
