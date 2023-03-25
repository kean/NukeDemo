// The MIT License (MIT)
//
// Copyright (c) 2015-2022 Alexander Grebenyuk (github.com/kean).

import UIKit
import Nuke
import SwiftUI
import Pulse
import PulseUI

final class MenuViewController: UITableViewController {
    private var sections = [MenuSection]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Network Logs", style: .plain, target: self, action: #selector(showNetworkLogs))

        sections = [generalSection, integrationSection, advancedSection]

        (ImagePipeline.shared.configuration.dataLoader as? DataLoader)?.delegate = URLSessionProxyDelegate()
    }

    private var generalSection: MenuSection {
        var items = [
            MenuItem(
                title: "Image Pipeline",
                subtitle: "The default pipeline, configurable at runtime",
                action: { [weak self] in self?.push(BasicDemoViewController(), $0) }
            ),
            MenuItem(
                title: "Image Processing",
                subtitle: "Showcases some of the built-in image processors",
                action: { [weak self] in self?.push(ImageProcessingDemoViewController(), $0) }
            ),
            MenuItem(
                title: "Disk Cache",
                subtitle: "Aggressive disk caching enabled",
                action: { [weak self] in self?.push(DataCachingDemoViewController(), $0) }
            )
        ]
        items.append(MenuItem(
            title: "LazyImage",
            subtitle: "NukeUI package demo (SwiftUI)",
            action: { [weak self] in self?.push(UIHostingController(rootView: LazyImageDemoView()), $0) }
        ))
        return MenuSection(title: "General", items: items)
    }

    private var integrationSection:  MenuSection {
        MenuSection(title: "Integrations", items: [
            MenuItem(
                title: "Alamofire",
                subtitle: "Custom networking stack",
                action: { [weak self] in self?.push(AlamofireIntegrationDemoViewController(), $0) }
            ),
            MenuItem(
                title: "Gifu",
                subtitle: "Display animated GIFs",
                action: { [weak self] in self?.push(GifuDemoViewController(), $0) }
            ),
            MenuItem(
                title: "SwiftSVG",
                subtitle: "Render vector images",
                action: { [weak self] in self?.push(SwiftSVGDemoViewController(), $0) }
            )
        ])
    }

    private var advancedSection: MenuSection {
        var items = [
            MenuItem(
                title: "Prefetch (UIKit)",
                subtitle: "UICollectionView Prefetching",
                action: { [weak self] in self?.push(PrefetchingDemoViewController(), $0) }
            )
        ]
        items.append(MenuItem(
            title: "Prefetch (SwiftUI)",
            subtitle: "LazyVGrid and FetchImage",
            action: { [weak self] in self?.push(UIHostingController(rootView: PrefetchDemoView()), $0) }
        ))
        items += [
            MenuItem(
                title: "Progressive JPEG",
                subtitle: "Progressive vs baseline JPEG",
                action: { [weak self] in self?.push(ProgressiveDecodingDemoViewController(), $0) }
            ),
            MenuItem(
                title: "Rate Limiter",
                subtitle: "Infinite scroll, highlights rate limiter performance",
                action: { [weak self] in self?.push(RateLimiterDemoViewController(), $0) }
            ),
            MenuItem(
                title: "MP4 (Experimental)",
                subtitle: "Replaces GIFs with MP4",
                action: { [weak self] in self?.push(AnimatedImageUsingVideoViewController(), $0)
            })
        ]

        return MenuSection(title: "Advanced", items: items)
    }

    private func push(_ controller: UIViewController, _ item: MenuItem) {
        controller.title = item.title
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func showNetworkLogs() {
        present(MainViewController(), animated: true)
    }

    // MARK: Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        item.action?(item)
    }
}

// MARK - MenuItem

private struct MenuItem {
    typealias Action = ((MenuItem) -> Void)

    var title: String?
    var subtitle: String?
    var action: Action?

    init(title: String?, subtitle: String? = nil, action: Action?) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
}

private struct MenuSection {
    var title: String
    var items: [MenuItem]

    init(title: String, items: [MenuItem]) {
        self.title = title
        self.items = items
    }
}
