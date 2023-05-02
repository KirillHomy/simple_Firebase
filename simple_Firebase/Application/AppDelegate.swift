//
//  AppDelegate.swift
//  simple_Firebase
//
//  Created by Kirill Khomytsevych on 30.04.2023.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        return true
    }

}

