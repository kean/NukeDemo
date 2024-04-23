// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).

import UIKit
import Nuke

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        window?.tintColor = UIColor.systemPink
        ImagePipeline.Configuration.isSignpostLoggingEnabled = true

        if #available(iOS 16, *) {
            print(URL.cachesDirectory)
        }
    }
}
