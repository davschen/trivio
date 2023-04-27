//
//  CustomSetModels.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/19/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// A set that a user has built
struct CustomSet: Decodable, Hashable, Identifiable, Encodable {
    @DocumentID var id: String?
    var jCategoryIDs: [String]
    var djCategoryIDs: [String]
    var categoryNames: [String]
    var title: String
    var titleKeywords: [String]
    var fjCategory: String
    var fjClue: String
    var fjResponse: String
    var dateCreated: Date
    var jeopardyDailyDoubles: [Int]
    var djDailyDoubles1: [Int]
    var djDailyDoubles2: [Int]
    var userID: String
    var isPublic: Bool
    var tags: [String]
    var plays: Int
    var rating: Double
    var numRatings: Int
    var numclues: Int
    var averageScore: Double
    var jRoundLen: Int
    var djRoundLen: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(id: String? = nil, jCategoryIDs: [String] = [], djCategoryIDs: [String] = [], categoryNames: [String] = [], title: String = "", titleKeywords: [String] = [], fjCategory: String = "", fjClue: String = "", fjResponse: String = "", dateCreated: Date = Date(), jeopardyDailyDoubles: [Int] = [], djDailyDoubles1: [Int] = [], djDailyDoubles2: [Int] = [], userID: String = "", isPublic: Bool = false, tags: [String] = [], plays: Int = 0, rating: Double = 0.0, numRatings: Int = 0, numclues: Int = 0, averageScore: Double = 0.0, jRoundLen: Int = 6, djRoundLen: Int = 6) {
        self.id = id
        self.jCategoryIDs = jCategoryIDs
        self.djCategoryIDs = djCategoryIDs
        self.categoryNames = categoryNames
        self.title = title
        self.titleKeywords = titleKeywords
        self.fjCategory = fjCategory
        self.fjClue = fjClue
        self.fjResponse = fjResponse
        self.dateCreated = dateCreated
        self.jeopardyDailyDoubles = jeopardyDailyDoubles
        self.djDailyDoubles1 = djDailyDoubles1
        self.djDailyDoubles2 = djDailyDoubles2
        self.userID = userID
        self.isPublic = isPublic
        self.tags = tags
        self.plays = plays
        self.rating = rating
        self.numRatings = numRatings
        self.numclues = numclues
        self.averageScore = averageScore
        self.jRoundLen = jRoundLen
        self.djRoundLen = djRoundLen
    }
}

// MARK: - Custom Set Durian (v4)
// So, it figures that I enjoy serializing this way.
// It's painless and doesn't need me to rewrite objects in the db.
struct CustomSetDurian: Decodable, Hashable, Identifiable, Encodable {
    @DocumentID var id: String?
    var round1Clues: [Int: [String]] = [:]
    var round2Clues: [Int: [String]] = [:]
    var round1Responses: [Int: [String]] = [:]
    var round2Responses: [Int: [String]] = [:]
    var round1CategoryNames: [String] = []
    var round2CategoryNames: [String] = []
    var title: String = ""
    var titleKeywords: [String] = []
    var description: String = ""
    var finalCat: String = ""
    var finalClue: String = ""
    var finalResponse: String = ""
    var dateCreated: Date = Date()
    var dateLastModified: Date = Date()
    var roundOneDaily: [Int] = []
    var roundTwoDaily1: [Int] = []
    var roundTwoDaily2: [Int] = []
    var userID: String = ""
    var plays: Int = 0
    var numLikes: Int = 0
    var numClues: Int = 0
    var round1Len: Int = 0
    var round2Len: Int = 0
    var hasTwoRounds: Bool = true
    var isDraft: Bool = false
    var isPublic: Bool = false

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init() {
        // Leave the default values if empty init
    }

    init(customSet: CustomSetCherry, round1CatIDs: [String], round2CatIDs: [String], categories: [String: (name: String, clues: [String], responses: [String])]) {
        self.id = customSet.id
        self.title = customSet.title
        self.titleKeywords = customSet.titleKeywords
        self.finalCat = customSet.finalCat
        self.finalClue = customSet.finalClue
        self.finalResponse = customSet.finalResponse
        self.dateCreated = customSet.dateCreated
        self.dateLastModified = customSet.dateCreated
        self.roundOneDaily = customSet.roundOneDaily
        self.roundTwoDaily1 = customSet.roundTwoDaily1
        self.roundTwoDaily2 = customSet.roundTwoDaily2
        self.userID = customSet.userID
        self.plays = customSet.plays
        self.numClues = customSet.numClues
        self.round1Len = customSet.round1Len
        self.round2Len = customSet.round2Len
        self.isPublic = customSet.isPublic
        self.hasTwoRounds = customSet.hasTwoRounds
        self.isDraft = customSet.isDraft

        for (index, catID) in round1CatIDs.enumerated() {
            if let category = categories[catID] {
                round1Clues[index] = category.clues
                round1Responses[index] = category.responses
                round1CategoryNames.append(category.name)
            }
        }

        for (index, catID) in round2CatIDs.enumerated() {
            if let category = categories[catID] {
                round2Clues[index] = category.clues
                round2Responses[index] = category.responses
                round2CategoryNames.append(category.name)
            }
        }
    }
}


// MARK: - Custom Set Cherry (v3)

struct CustomSetCherry: Decodable, Hashable, Identifiable, Encodable {
    @DocumentID var id: String?
    var round1CatIDs: [String] = []
    var round2CatIDs: [String] = []
    var categoryNames: [String] = []
    var title: String = ""
    var titleKeywords: [String] = []
    var description: String = ""
    var finalCat: String = ""
    var finalClue: String = ""
    var finalResponse: String = ""
    var dateCreated: Date = Date()
    var dateLastModified: Date = Date()
    var roundOneDaily: [Int] = []
    var roundTwoDaily1: [Int] = []
    var roundTwoDaily2: [Int] = []
    var userID: String = ""
    var tags: [String] = []
    var plays: Int = 0
    var rating: Double = 0.0
    var numRatings: Int = 0
    var numClues: Int = 0
    var round1Len: Int = 0
    var round2Len: Int = 0
    var hasTwoRounds: Bool = true
    var isDraft: Bool = false
    var isPublic: Bool = false

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init() {
        // Leave the default values if empty init
    }

    init(customSet: CustomSet) {
        self.id = customSet.id
        self.round1CatIDs = customSet.jCategoryIDs
        self.round2CatIDs = customSet.djCategoryIDs
        self.categoryNames = customSet.categoryNames
        self.title = customSet.title
        self.titleKeywords = customSet.titleKeywords
        self.finalCat = customSet.fjCategory
        self.finalClue = customSet.fjClue
        self.finalResponse = customSet.fjResponse
        self.dateCreated = customSet.dateCreated
        self.dateLastModified = customSet.dateCreated
        self.roundOneDaily = customSet.jeopardyDailyDoubles
        self.roundTwoDaily1 = customSet.djDailyDoubles1
        self.roundTwoDaily2 = customSet.djDailyDoubles2
        self.userID = customSet.userID
        self.tags = customSet.tags
        self.plays = customSet.plays
        self.rating = customSet.rating
        self.numRatings = customSet.numRatings
        self.numClues = customSet.numclues
        self.round1Len = customSet.jRoundLen
        self.round2Len = customSet.djRoundLen
        self.isPublic = customSet.isPublic
        self.hasTwoRounds = true
        self.isDraft = false
    }
}
