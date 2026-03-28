// The MIT License (MIT)
//
// Copyright (c) 2015-2026 Alexander Grebenyuk (github.com/kean).

import UIKit
import Nuke

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        window?.tintColor = UIColor.systemPink
        ImagePipeline.Configuration.isSignpostLoggingEnabled = true
        
        ImageDecoderRegistry.shared.register(ImageDecoders.Video.init)

        if #available(iOS 16, *) {
            print(URL.cachesDirectory)
        }
    }
}
