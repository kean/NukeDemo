// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).

import UIKit
import Nuke
import NukeUI
import NukeVideo
import AVFoundation

final class AnimatedImageUsingVideoViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let pipeline = ImagePipeline {
        $0.makeImageDecoder = {
            ImageDecoders.Video(context: $0)

            // Use ImageDecoderRegistory to add the decoder to the
            // ImageDecoderRegistry.shared.register(ImageDecoders.Video.init)
        }
    }

    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.register(VideoCell.self, forCellWithReuseIdentifier: imageCellReuseID)
        collectionView.backgroundColor = UIColor.systemBackground

        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumInteritemSpacing = 8
    }

    // MARK: Collection View

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellReuseID, for: indexPath) as! VideoCell
        cell.imageView.pipeline = pipeline
        cell.setVideo(with: imageURLs[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = view.bounds.size.width - layout.sectionInset.left - layout.sectionInset.right
        return CGSize(width: width, height: width)
    }
}

private let imageCellReuseID = "imageCellReuseID"

private let imageURLs = [
    URL(string: "https://kean.github.io/videos/cat_video.mp4")!
]

// MARK: - VideoCell

/// - warning: This is proof of concept, please don't use in production.
private final class VideoCell: UICollectionViewCell {
    let imageView = LazyImageView()

    deinit {
        prepareForReuse()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(white: 235.0 / 255.0, alpha: 1.0)

        imageView.makeImageView = { container in
            if let type = container.type, type.isVideo, let asset = container.userInfo[.videoAssetKey] as? AVAsset {
                let view = VideoPlayerView()
                view.asset = asset
                view.play()
                return view
            }
            return nil
        }

        contentView.addSubview(imageView)
        imageView.pinToSuperview()

        imageView.placeholderView = UIActivityIndicatorView(style: .medium)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.reset()
    }

    func setVideo(with url: URL) {
        imageView.url = url
    }
}
