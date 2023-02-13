//
//  AppDelegate.swift
//  SQLayout
//
//  Created by Vince Lee on 2/5/23.
//

import UIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create main window
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window;
        window.backgroundColor = UIColor.white

        // Create tab bar
        let viewController = MainViewController()
        self.window?.rootViewController = viewController
        self.window?.isHidden = false

        self.window?.makeKeyAndVisible()
        return true
    }
}
