//
//  ShareSheet.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-29.
//

import SwiftUI

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
