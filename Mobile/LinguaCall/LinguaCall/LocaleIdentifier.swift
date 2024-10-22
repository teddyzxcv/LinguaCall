//
//  LocaleIdentifier.swift
//  LinguaCall
//
//  Created by Zhengwu Pan on 22.10.2024.
//

import Foundation

enum LanguageLocale: String {
    case russian = "ru-RU"     // Russian
    case chinese = "zh-CN"     // Chinese (Simplified)
    case english = "en-US"     // English (US)

    var localeIdentifier: String {
        return self.rawValue
    }

    // Optionally, you can add a method to get a human-readable name
    var displayName: String {
        switch self {
        case .russian:
            return "Russian"
        case .chinese:
            return "Chinese"
        case .english:
            return "English"
        }
    }
}
