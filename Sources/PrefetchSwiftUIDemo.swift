// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import Foundation
import SwiftUI
import ScrollViewPrefetcher
import Nuke

// MARK: - View

@available(iOS 14.0, *)
struct PrefetchDemoView: View {
    @StateObject var model = PrefetchDemoViewModel()

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                let side = geometry.size.width / 4
                let item = GridItem(.fixed(side), spacing: 2)
                LazyVGrid(columns: Array(repeating: item, count: 4), spacing: 2) {
                    ForEach(demoPhotosURLs.indices) { index in
                        ImageView(url: demoPhotosURLs[index])
                            .frame(width: side, height: side)
                            .clipped()
                            .onAppear { model.onAppear(index) }
                            .onDisappear { model.onDisappear(index) }
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
                .aspectRatio(contentMode: .fill)
                .clipped()
        }
        .onAppear { image.load(url) }
        .onDisappear(perform: image.reset)
    }
}

// MARK: - ViewModel

final class PrefetchDemoViewModel: ObservableObject, ScrollViewPrefetcherDelegate {
    private let imagePrefetcher: ImagePrefetcher
    private let scrollViewPrefetcer: ScrollViewPrefetcher
    let urls: [URL]

    init() {
        self.imagePrefetcher = ImagePrefetcher()
        self.scrollViewPrefetcer = ScrollViewPrefetcher()
        self.urls = demoPhotosURLs

        self.scrollViewPrefetcer.delegate = self
    }

    func onAppear(_ index: Int) {
        scrollViewPrefetcer.onAppear(index)
    }

    func onDisappear(_ index: Int) {
        scrollViewPrefetcer.onDisappear(index)
    }

    // MARK: ScrollViewPrefetcherDelegate

    func getAllIndicesForPrefetcher(_ prefetcher: ScrollViewPrefetcher) -> Range<Int> {
        urls.indices
    }

    func prefetcher(_ prefetcher: ScrollViewPrefetcher, prefetchItemsAt indices: [Int]) {
        imagePrefetcher.startPrefetching(with: indices.map { urls[$0] })
    }

    func prefetcher(_ prefetcher: ScrollViewPrefetcher, cancelPrefechingForItemAt indices: [Int]) {
        imagePrefetcher.stopPrefetching(with: indices.map { urls[$0] })
    }
}
