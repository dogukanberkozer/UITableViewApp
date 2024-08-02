//
//  UIApplicationExtension.swift
//  ScorpSSListApp
//
//  Created by Dogukan Berk Ozer on 28.04.2024.
//

import UIKit

public extension UIApplication {
    
    class func topMostViewController() -> UIViewController? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        guard let window = appDelegate.window else { return nil }
        let rootViewController = window.rootViewController
        return rootViewController?.topMostViewController()
    }
}
