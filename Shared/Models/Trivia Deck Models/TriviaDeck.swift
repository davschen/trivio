//
//  TriviaDeck.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/21/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct TriviaDeck: Encodable, Decodable, Hashable, Identifiable {
    @DocumentID var id: String?
    var title: String = ""
    var description: String = ""
    var categories: [String] = [String]()
}

struct TriviaDeckClue: Encodable, Decodable, Hashable, Identifiable {
    @DocumentID var id: String?
    var triviaDeckTitle: String = ""
    var category: String = ""
    var clue: String = ""
    var response: String = ""
    var releasedDate: Date = Date()
    var authorID: String = ""
    var authorUsername: String = ""
    var totalSubmissions: Int = 0
    var correctSubmissions: Int = 0
    var isAdminApproved: Bool = false
    var needsAdminReview: Bool = true
    var adminFeedback: String = ""
    var submittedDate: Date = Date()
    var secondsCountsBins: [Int] = Array(repeating: 0, count: 61)
    var attemptsCountsBins: [Int] = Array(repeating: 0, count: 6)
    
    mutating func setCategory(newCategory: String?) {
        if let newCategory = newCategory {
            category = newCategory
        }
    }
}

struct TriviaDeckClueViewState {
    var triviaDeckDisplayMode: TriviaDeckDisplayMode = .triviaDeckClue
    
    var isTypingResponse: Bool = true
    var revealedIndices: [Int] = []
    var hasSolvedClue: Bool = false
    var currentClueNumAttempts: Int = 1
    
    mutating func resetToDefaults() {
        hasSolvedClue = false
        revealedIndices.removeAll()
        currentClueNumAttempts = 1
    }
}

struct PlayedTriviaDeckClueLog: Encodable, Decodable, Hashable, Identifiable {
    @DocumentID var id: String?
    var triviaDeckPath: String = ""
    var secondsFloat: Float = 0.0
    var numAttempts: Int = 0
    var datePlayed: Date = Date()
    var didSkipClue: Bool = false
}
