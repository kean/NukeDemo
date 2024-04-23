// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).

import UIKit
import Nuke

private let cellReuseID = "reuseID"
private var loggingEnabled = true

final class PrefetchingDemoViewController: BasicDemoViewController, UICollectionViewDataSourcePrefetching {
    let prefetcher = ImagePrefetcher()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.isPrefetchingEnabled = true
        collectionView?.prefetchDataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        prefetcher.isPaused = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        prefetcher.isPaused = true
    }

    // MARK: UICollectionViewDataSourcePrefetching

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map { photos[$0.row] }
        prefetcher.startPrefetching(with: urls)
        if loggingEnabled {
            print("prefetchItemsAt: \(stringForIndexPaths(indexPaths))")
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.map { photos[$0.row] }
        prefetcher.stopPrefetching(with: urls)
        if loggingEnabled {
            print("cancelPrefetchingForItemsAt: \(stringForIndexPaths(indexPaths))")
        }
    }
}

private func stringForIndexPaths(_ indexPaths: [IndexPath]) -> String {
    guard indexPaths.count > 0 else {
        return "[]"
    }
    let items = indexPaths
        .map { return "\(($0 as NSIndexPath).item)" }
        .joined(separator: " ")
    return "[\(items)]"
}
