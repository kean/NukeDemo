// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).

import AVFoundation
import NukeVideo
import SwiftUI

struct VideoView: UIViewRepresentable {
    
    let asset: AVAsset
    
    func makeUIView(context: Context) -> VideoPlayerView {
        let videoView = VideoPlayerView()
        return videoView
    }
    
    func updateUIView(_ videoView: VideoPlayerView, context: Context) {
        videoView.asset = asset
        videoView.play()
    }
}
