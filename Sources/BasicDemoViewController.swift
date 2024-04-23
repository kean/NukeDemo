// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).

import UIKit
import Nuke
import NukeExtensions

/// A base view controller.
class BasicDemoViewController: UICollectionViewController, ImagePipelineSettingsViewControllerDelegate {
    var photos: [URL] = []
    var pipeline = ImagePipeline.shared
    var itemsPerRow: Int = 4

    init(collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()) {
        super.init(collectionViewLayout: collectionViewLayout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        photos = demoPhotosURLs

        collectionView?.backgroundColor = UIColor.systemBackground
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellReuseID)

        collectionView?.refreshControl = UIRefreshControl()
        collectionView?.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Configuration", style: .plain, target: self, action: #selector(buttonShowSettingsTapped))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateItemSize()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateItemSize()
    }

    func updateItemSize() {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 2.0
        layout.minimumInteritemSpacing = 2.0
        let side = (Double(view.bounds.size.width) - Double(itemsPerRow - 1) * 2.0) / Double(itemsPerRow)
        layout.itemSize = CGSize(width: side, height: side)
    }

    // MARK: UICollectionView

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseID, for: indexPath)
        cell.backgroundColor = UIColor.secondarySystemBackground

        let imageView = imageViewForCell(cell)
        let request = makeRequest(with: photos[indexPath.row], cellSize: cell.bounds.size)
        var options = makeImageLoadingOptions()
        options.pipeline = self.pipeline
        NukeExtensions.loadImage(with: request, options: options, into: imageView)

        return cell
    }

    func makeRequest(with url: URL, cellSize: CGSize) -> ImageRequest {
        ImageRequest(url: url)
    }

    func makeImageLoadingOptions() -> ImageLoadingOptions {
        ImageLoadingOptions(transition: .fadeIn(duration: 0.25))
    }

    func imageViewForCell(_ cell: UICollectionViewCell) -> UIImageView {
        var imageView: UIImageView! = cell.viewWithTag(15) as? UIImageView
        if imageView == nil {
            imageView = UIImageView()
            imageView.tag = 15
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            cell.addSubview(imageView)
            imageView.pinToSuperview()
        }
        return imageView!
    }

    // MARK: - Actions

    @objc func refreshControlValueChanged() {
        collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }

    @objc func buttonShowSettingsTapped() {
        ImagePipelineSettingsViewController.show(from: self, pipeline: pipeline)
    }

    // MARK: - ImagePipelineSettingsViewControllerDelegate

    func imagePipelineSettingsViewController(_ vc: ImagePipelineSettingsViewController, didFinishWithConfiguration configuration: ImagePipeline.Configuration) {
        self.pipeline = ImagePipeline(configuration: configuration)
        vc.dismiss(animated: true) {}
    }
}

private let cellReuseID = "reuseID"
