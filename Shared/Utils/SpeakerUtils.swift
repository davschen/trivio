//
//  SpeakerUtils.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/17/22.
//

import Foundation
import AVFoundation
import SwiftUI

internal class Speaker: NSObject, ObservableObject {
    internal var errorDescription: String? = nil
    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking: Bool = false
    @Published var isShowingSpeakingErrorAlert: Bool = false
    @Published var audioPlayer: AVAudioPlayer?
    @Published var volume: Float = 0.5
    
    private var speechGender: SpeechGender {
        return SpeechGender(rawValue: UserDefaults.standard.string(forKey: "speechGender") ?? "male") ?? .male
    }
    
    private var speechLanguage: SpeechLanguage {
        return SpeechLanguage(rawValue: UserDefaults.standard.string(forKey: "speechLanguage") ?? "britishEnglish") ?? .britishEnglish
    }
    
    private var speechSpeed: Float {
        return UserDefaults.standard.value(forKey: "speechSpeed") as? Float ?? 0.5
    }
    
    override init() {
        super.init()
        self.synthesizer.delegate = self
    }

    internal func speak(_ text: String) {
        if volume == 0 { return }
        do {
            // print(AVSpeechSynthesisVoice.speechVoices())
            let utterance = AVSpeechUtterance(string: text)
            var speechIdentifier = ""
            if speechGender == .male {
                if speechLanguage == .americanEnglish {
                    speechIdentifier = "com.apple.ttsbundle.siri_male_en-US_compact"
                } else {
                    speechIdentifier = "com.apple.ttsbundle.Daniel-compact"
                }
            } else {
                if speechLanguage == .americanEnglish {
                    speechIdentifier = "com.apple.ttsbundle.Samantha-compact"
                } else {
                    speechIdentifier = "com.apple.ttsbundle.siri_female_en-GB_compact"
                }
            }
            utterance.voice = AVSpeechSynthesisVoice(identifier: speechIdentifier)
            utterance.rate = speechSpeed
            utterance.volume = volume
            
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            self.synthesizer.speak(utterance)
        } catch let error {
            self.errorDescription = error.localizedDescription
            isShowingSpeakingErrorAlert.toggle()
        }
    }
    
    internal func stop() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        self.synthesizer.stopSpeaking(at: .immediate)
    }
    
    internal func updateVolume(value: Float) {
        withAnimation(Animation.linear(duration: 0.1)) {
            volume = value
        }
    }
}

extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.isSpeaking = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.isSpeaking = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.isSpeaking = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func playSounds(_ soundFileName : String) {
        guard let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: nil) else {
            return//fatalError("Unable to find \(soundFileName) in bundle")
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print(error.localizedDescription)
        }
        
        audioPlayer?.play()
    }
}

enum SpeechGender: String {
    case male = "male"
    case female = "female"
}

enum SpeechLanguage: String {
    case britishEnglish = "britishEnglish"
    case americanEnglish = "americanEnglish"
}

enum SpeechSpeed: Float {
    case slow = 0.45
    case medium = 0.5
    case fast = 0.55
}
