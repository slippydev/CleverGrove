//
//  PromptBuilder.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-17.
//

import Foundation

/// Utility class for building prompts for OpenAI chat completions.
struct PromptBuilder {
    
    /**
     Create a context for chat completions with relevant messages.
     
     - Parameters:
     - relevantChunks: An array of relevant text chunks.
     - expert: An instance of CDExpert representing the expert.
     - chatHistoryCount: The number of chat history messages to include.
     
     - Returns: An array of AIMessage objects representing the context.
     */
    func context(relevantChunks: [CDTextChunk], expert: CDExpert, chatHistoryCount: Int) -> [AIMessage] {
        var aiMessages = [AIMessage]()
        aiMessages.append(instructions(expert: expert, relevantChunks: relevantChunks))
        if chatHistoryCount > 0 {
            aiMessages.append(contentsOf: chatHistory(expert: expert, messageCount: chatHistoryCount))
        }
        return aiMessages
    }
    
    /**
     Create an introduction message.
     
     - Parameters:
        - name: The expert's name.
        - expertise: The area of expertise.
        - style: The communication style.
        - training: An array of training documents.
     
     - Returns: An introduction message as a string.
     */
    func introduction(name: String, expertise: String, style: CommunicationStyle, training: [String]) -> String {
        var intro: String
        let hasTraining = training.count > 0
        if hasTraining {
            intro = "Your name is \(name), and you can answer questions about \(expertise). Introduce yourself and offer to answer any questions about your area of expertise. Your introduction should be 100 words or less. List some of these files you've been trained but don't include the file extensions:\n"
            for document in training {
                intro += "\(document)\n"
            }
            intro += "Your Communication Style: " + "\(style.description) \n"
        } else {
            intro = "Your name is \(name), and you are an expert at \(expertise). You haven't been trained yet, so introduce yourself and suggest the user add some training documents to you before you can actually help them by answering questions. Your response should be 100 words or less. Explain that you support PDF, Docx and Text files, and they need to tap on your name above the chat and then add a document for you to be trained on."
        }
        return intro
    }
 
    /**
     Create instructions for the expert.
     
     - Parameters:
     - expert: An instance of CDExpert representing the expert.
     - relevantChunks: An array of relevant text chunks.
     
     - Returns: An AIMessage with instructions for the expert.
     */
    private func instructions(expert: CDExpert, relevantChunks: [CDTextChunk]) -> AIMessage {
        
        let description = "Your name is \(expert.name ?? "") and you are an expert in this topic: \(expert.expertise ?? "Use the information provided below").\n"
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
    
    /**
     Retrieve chat history messages.
     
     - Parameters:
     - expert: An instance of CDExpert representing the expert.
     - messageCount: The number of chat history messages to retrieve.
     
     - Returns: An array of AIMessage objects representing chat history.
     */
    private func chatHistory(expert: CDExpert, messageCount: Int = 3) -> [AIMessage] {
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

    /**
     Create a message to request expertise information from a document.
     
     - Parameter referenceText: The reference text for the request.
     
     - Returns: An AIMessage with the expertise request.
     */
    func documentExpertiseArea(referenceText: String) -> AIMessage {
        let instructions =
        """
        I want two pieces of information about this document, outputed into JSON.
            1. Title
            2. A consise one sentence summary of what this document contains, with a maximum of 20 words.
        
        Example 1
        1. Chess Game Rules
        2. The rules of Chess
        
        Example 2
        1. An investigation into the nature of dark matter
        2. A research paper investigating the physics of dark matter
        
        JSON Format
        {
            "title": "The title of the document",
            "expertise": "summary of document"
        }
        """

        let message = instructions + referenceText
        return AIMessage(role: .system, content:message)
    }
}
