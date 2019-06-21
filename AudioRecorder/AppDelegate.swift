//
//  AppDelegate.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: CoordinatorType?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        coordinator = Coordinator(window: window)
        coordinator?.start()
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coordinator?.handleAppTerminate()
    }
}
