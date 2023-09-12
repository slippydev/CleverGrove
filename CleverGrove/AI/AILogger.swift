//
//  AILogger.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-09-07.
//

import Foundation
import OSLog
import OpenAIKit
import Firebase

enum AnalyticsEvent: String {
    case showNewExpert = "show_new_expert"
    case openURL = "open_url"
}

struct AILogger {
    
    func logChat(context: [AIMessage], question: String) {
        for section in context {
            Logger().info("[\(section.role.rawValue)]:")
            Logger().info("\(section.content)\n")
        }
        Logger().info("Question: \(question)\n")
    }
    
    func logIntro(instructions: String) {
        Logger().info("Introduction Instructions: \(instructions)\n")
    }
    
    func logError(_ error: Error) {
        let errorInfo = (error as NSError).userInfo["error"]! as! [String:Any]
        if let code = errorInfo["code"] as? String, let message = errorInfo["message"] as? String {
            Logger().error("\(code) - \(message)")
            Analytics.logEvent("error", parameters: ["code": code, "message": message])
        }
    }
    
    func logRelatedness(relatedness: [Double]) {
        Logger().info("Logging Relatedness values")
        for value in relatedness {
            Logger().info("Relatedness Value: \(value)")
        }
    }
    
    func log(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.rawValue, parameters: nil)
    }
    
}
