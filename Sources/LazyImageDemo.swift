// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import NukeUI

// MARK: - View

/// LazyImage is available on iOS 13! Grid isn't.
@available(iOS 14.0, *)
struct LazyImageDemoView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                let side = geometry.size.width / 4
                let item = GridItem(.fixed(side), spacing: 2)
                LazyVGrid(columns: Array(repeating: item, count: 4), spacing: 2) {
                    ForEach(demoPhotosURLs.indices) { index in
                        LazyImage(source: demoPhotosURLs[index])
                            .transition(.fadeIn(duration: 0.33))
                            .frame(width: side, height: side)
                    }
                }
            }
        }
    }
}
