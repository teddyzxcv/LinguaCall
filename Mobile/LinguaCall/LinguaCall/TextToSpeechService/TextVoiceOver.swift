//
//  TextToSpeech.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 22.10.2024.
//

import SwiftUI
import Foundation
import AVFoundation

class TextVoiceOver: NSObject, ObservableObject {
    @Published var isSpeaking = false

    let speechSynthesizer = AVSpeechSynthesizer()

    // Function to start speaking the provided text
    func speak(text: String, localeIdentifier: LanguageLocale) {
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            print("Voice Name: \(voice.name), Identifier: \(voice.identifier), Language: \(voice.language), Quality: \(voice.quality)")
        }
        if isSpeaking {
            stopSpeaking()
        }
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: localeIdentifier.localeIdentifier)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate // Default speaking rate

        speechSynthesizer.delegate = self
        speechSynthesizer.speak(speechUtterance)

        self.isSpeaking = true
    }

    // Function to stop speaking
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        self.isSpeaking = false
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension TextVoiceOver: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.isSpeaking = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.isSpeaking = false
    }
}
