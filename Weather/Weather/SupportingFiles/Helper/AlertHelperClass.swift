//
//  AlertHelperClass.swift
//  Weather
//
//  Created by Suresh Reddy on 8/12/24.
//

import Foundation

import UIKit

class AlertHelperClass {
    static func showAlert(in viewController: UIViewController?,
                          title: String = "",
                          message: String,
                          preferredStyle: UIAlertController.Style = .alert,
                          buttonTitles: [String],
                          completion: @escaping (Int) -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        for (index, title) in buttonTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default) { _ in
                completion(index)
            }
            alertController.addAction(action)
        }
        
        if let viewController = viewController, viewController.view.window != nil {
            // If the provided viewController is valid and currently in the view hierarchy, present the alert on it.
            viewController.present(alertController, animated: true, completion: nil)
        } else {
            // If the provided viewController is nil or not in the view hierarchy, use the root view controller of the key window.
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
