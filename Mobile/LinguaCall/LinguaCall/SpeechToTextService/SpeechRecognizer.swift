//
//  SpeechRecognizer.swift
//  LinguaCall
//
//  Created by Sergey Abrosov on 20.10.2024.
//

import SwiftUI
import Foundation
import Speech

class SpeechRecognizer: ObservableObject {
    @Published var recognizedText = ""
    @Published private(set) var isRunning = false
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU")) // Use Russian
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    func start() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.startRecognition()
            }
        }
    }
    
    func startRecognition() {
        do {
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }

          let inputNode = audioEngine.inputNode
          let recordingFormat = inputNode.inputFormat(forBus: 0)

          guard recordingFormat.sampleRate > 0 && recordingFormat.channelCount > 0 else {
              print("Invalid format or no microphone access")
              return
          }

          inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { buffer, _ in
              self.recognitionRequest?.append(buffer)
          }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            self.recognizedText = "Слушаю..."
            self.isRunning = true
        }
        
        catch {
            
        }
    }
    
    func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        self.isRunning = false
    }
}

