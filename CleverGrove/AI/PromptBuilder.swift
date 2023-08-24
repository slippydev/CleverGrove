//
//  PromptBuilder.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-17.
//

import Foundation
import OpenAIKit

enum CommunicationStyle: String, CaseIterable {
    
    case formal = "Formal"
    case empathetic = "Empathetic"
    case activeListener = "Active Listener"
    case assertive = "Assertive"
    case storyteller = "Storyteller"
    case humorous = "Humorous"
    case impatient = "Impatient"
    case passiveAggressive = "Passive Aggressive"
    case pirate = "Pirate"
    case wizard = "Wizard"
    
    
    var description: String {
        switch self {
        case .assertive:
            return "You express your thoughts and feelings confidently, while respecting others' opinions. You're direct and clear in your communication."
        case .passiveAggressive:
            return "You indirectly express your dissatisfaction or frustration, often through sarcasm or subtle jabs. You avoid direct confrontation."
        case .empathetic:
            return "You actively listen and seek to understand others' perspectives. You show genuine concern for their feelings and experiences."
        case .activeListener:
            return "You focus on what others are saying, asking questions to clarify and understand better. You provide thoughtful responses and validation."
        case .storyteller:
            return "You use narratives and anecdotes to convey your ideas and connect with others on a personal level. You often frame information within a storytelling context."
        case .humorous:
            return "You use humor and wit to engage others and lighten the mood in conversations. You often employ jokes and anecdotes to connect with people."
        case .formal:
            return "You maintain a professional and polished demeanor in your interactions. You use formal language and adhere to etiquette and protocols."
        case .pirate:
            return "Arrr, matey! Ye speak with a salty tongue, full o' nautical slang and hearty laughter. Yer words be bold, fearless, and colorful as a pirate's flag, makin' every conversation an adventure on the high seas."
        case .wizard:
            return "You converse in enigmatic riddles and arcane phrases, like a keeper of ancient secrets. Your words weave a tapestry of mystery, inviting others to unravel the hidden meanings and embark on a quest for wisdom and knowledge."
        case .impatient:
            return "You're in a constant hurry, always cutting to the chase. Your words are short, direct, and you often finish sentences for others. There's little time for small talk, and you expect answers quickly, making every conversation brisk and to the point."
        }
    }
}

struct PromptBuilder {
    
    func context(relevantChunks: [CDTextChunk], expert: CDExpert) -> [AIMessage] {
        var aiMessages = [AIMessage]()
        aiMessages.append(instructions(expert: expert, relevantChunks: relevantChunks))
        aiMessages.append(contentsOf: chatHistory(expert: expert))
        return aiMessages
    }
    
    func introduction(name: String, expertise: String, style: CommunicationStyle, training: [String]) -> String {
        var intro: String
        let hasTraining = training.count > 0
        if hasTraining {
            intro = "Your name is \(name), and you are an expert at \(expertise). Introduce yourself and offer to answer any questions about your area of expertise. Your introduction should be 100 words or less. List some of these files you've been trained but don't include the file extensions:\n"
            for document in training {
                intro += "\(document)\n"
            }
            intro += "Your Communication Style: " + "\(style.description) \n"
        } else {
            intro = "Your name is \(name), and you are an expert at \(expertise). You haven't been trained yet, so introduce yourself and suggest the user add some training documents to you before you can actually help them by answering questions. Your response should be 100 words or less. Explain that to add training documents they need to swipe on your entry in the Expert List and tap 'Edit' and then add documents. You currently support PDF and Text files."
        }
        return intro
    }
    
    private func instructions(expert: CDExpert, relevantChunks: [CDTextChunk]) -> AIMessage {
        
        let description = "Your name is \(expert.name ?? "") and you are an expert on the following topic(s): \(expert.desc ?? "Use the information provided below").\n"
        let introduction = "\nOnly answer questions relevant to your area of expertise, and keep the answers to 100 words or less if possible. If you don't know the answer, write \"I could not find an answer.\"\n"
        let style = "Your Communication Style: " + "\(expert.communicationStyle.description) \n"
        var relevantText = ""
        for chunk in relevantChunks {
            if let text = chunk.text {
                relevantText += "\nRelevant Text:\n\(text)\n"
            }
        }
        let message = description + style + introduction + relevantText
        return AIMessage(role: .system, content:message)
    }
    
    private func chatHistory(expert: CDExpert, messageCount: Int = 5) -> [AIMessage] {
        let exchanges = expert.chatExchanges(in: 0..<messageCount)
        var messages = [AIMessage]()
        for exchange in exchanges {
            if let query = exchange.query {
                messages.append(AIMessage(role: .user, content: query))
            }
            if let response = exchange.response {
                messages.append(AIMessage(role: .assistant, content: response))
            }
        }
        return messages
    }
    
//    func documentTone(text: String) -> String {
////        let instruction = "Analyze the following piece of text. Give advice to someone else about how to reproduce the tone and voice of the author of that text, in 100 words or less?\n\n"
//        let instruction =
//"""
//Analyze the following piece of text. Give advice to yourself in the second person to reproduce the personality of the author of that text, in 50 words or less?
//
//"""
//        let content = instruction + text
//        return content
//    }
    
}
