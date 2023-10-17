# CleverGrove

![CleverGrove Logo](app_images/CleverGrove.png)

An iOS app to train experts on your own personal data. Train experts in seconds with your own PDFs, DocX and Text files, and then have conversations with your expert about the documents.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Description](#description)
- [Usage](#usage)
- [Installation](#installation)
- [Contact](#contact)


## Description
CleverGrove is an app for training LLM powered experts using documents. Specifically, it relies Text Embeddings to "train" experts by breaking the documents into chunks and retrieving text embeddings from OpenAI for each text chunk. A Messages-like chat interface allows users to chat with their expert. Embeddings are calculated for each chat message and the most relevant text chunks from the training documents are included in the context sent to GPT-3, which then provides a response.

## Usage
#### Training an Expert
Train an expert on PDF, DocX, or Txt files. Choose files from your iCloud storage, or "share" a document with CleverGrove to either train a new expert or add a document to an existing expert.

![Training an Expert](/app_images/trainExpert.jpeg)

You can customize an expert's name, image and personality. The expert's personality will affect how they interact with you. 

##### Personality Options
**Formal**: "Expert will maintain a professional and polished demeanor in your interactions. Expert will use formal language and adhere to etiquette and protocols."
        
**Active Listener**: "Expert will actively listen and seek to understand others' perspectives. Expert will show genuine concern for their feelings and experiences. Expert will focus on what others are saying, asking questions to clarify and understand better. Expert will mirror questions to ensure you understand."
        
**Humorous**: "Expert will use humor and wit to engage others and lighten the mood in conversations. Expert will often employ jokes and anecdotes to connect with people."
        
**Simple**: "Expert will use simple words, short sentences, and everyday examples to explain complex ideas. The goal is to make information easy to understand for everyone, regardless of their education or background. Expert will avoid jargon and technical terms, opting for relatable comparisons and straightforward explanations that anyone can grasp."
        
**Sarcastic**: "Expert will express your thoughts with a heavy dose of sarcasm. Every sentence drips with irony, and the expert will often say the opposite of what it means. Their words are laced with dry humor and mocking tones, leaving others guessing about its true intentions. It's a real blast talking to this expert."
        
**Academic**:  "Expert will employ a vast lexicon of big words and indulge in labyrinthine sentence structures. Its goal is to elucidate concepts with precision and profundity, even if it means occasionally bewildering its interlocutors. Eschewing simplicity, it will embrace erudition, crafting dialogues that border on the sesquipedalian, invoking intellectual grandeur in every discourse."
        
**Passive Aggressive**: "Expert will indirectly express dissatisfaction or frustration, often through sarcasm or subtle jabs. Expert will avoid direct confrontation."
        
**Youthful**: "Expert will talk with a blend of youthful enthusiasm and Gen Z slang. Its conversations are filled with emojis, abbreviations, and references to pop culture. Expert is not afraid to express emotion, often using exaggeration, hyperbole and sarcasm."
        
**Bardic**: "Expert will communicate using poetic language and rhymes. Use Shakespeare and the King James Bible as references for language use."
        
**Pirate**: "Arrr, matey! Ye expert speaks with a salty tongue, full o' nautical slang and hearty laughter. Their words be bold, fearless, and colorful as a pirate's flag, makin' every conversation an adventure on the high seas."
        
**Wizard**: "Expert will converse in enigmatic riddles and arcane phrases, like a keeper of ancient secrets. Its words weave a tapestry of mystery, inviting others to unravel the hidden meanings and embark on a quest for wisdom and knowledge."

#### Chatting with an Expert

Chat with your expert using a familiar Messages-style interface.

![Chat with an Expert](/app_images/expertChat.jpeg)

## Installation
1. Install Xcode
2. Clone this repository
3. Add an OpenAI-Info.plist to your the project
4. Add "api_key" as a key and your OpenAI api key as the string value to the PLIST file
5. Add the new plist file to your .gitignore list
6. Optionally add your OpenAI Org Key with key name "org_key" if you are using it

#### Your OpenAI-Info.plist should look like this:

```
<plist version="1.0">
<dict>
  <key>api_key</key>
  <string>YOUR-OPENAI-API-KEY</string>
</dict>
</plist>
```

## Contact
To contact the author of this code email Derek Gour at derekgour@gmail.com 

