//
//  ShareSheet.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-29.
//

import SwiftUI

// NO LONGER BEING USED AS EXPERT SHARING FEATURE HAS BEEN REMOVED. LEAVING IN FOR REFERENCE

/**
 A SwiftUI wrapper for UIKit UIActivityViewController
 */
struct ShareSheet: UIViewControllerRepresentable {
    
    typealias CompletionHandler = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let completion: CompletionHandler?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let viewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        viewController.excludedActivityTypes = excludedActivityTypes
        viewController.completionWithItemsHandler = completion
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
