//
//  CGLogger.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-09-07.
//

import Foundation
import OSLog
import Firebase

enum AnalyticsEvent: String {
    case showNewExpert = "show_new_expert"
    case openURL = "open_url"
    case chatExchange = "chat_exchange"
}

enum AnalyticsParams: String {
    case code = "code"
    case message = "message"
    case tokenCount = "token_count"
}

protocol Loggable {
    func log(_ event: String, params: [String: Any]?)
}

struct CGLogger: Loggable {
    
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
        guard let errorInfo = (error as NSError).userInfo["error"] as? [String:Any] else { return }
        if let code = errorInfo["code"] as? String, let message = errorInfo["message"] as? String {
            Logger().error("\(code) - \(message)")
            Analytics.logEvent("error", parameters: [AnalyticsParams.code.rawValue: code,
                                                     AnalyticsParams.message.rawValue: message])
        }
    }
    
    func logRelatedness(relatedness: [Double]) {
        Logger().info("Logging Relatedness values")
        for value in relatedness {
            Logger().info("Relatedness Value: \(value)")
        }
    }
    
    func log(_ event: AnalyticsEvent, params: [String: Any]? = nil) {
        Analytics.logEvent(event.rawValue, parameters: params)
    }
    
    func log(_ event: String, params: [String: Any]? = nil) {
        Analytics.logEvent(event, parameters: params)
    }
    
}
