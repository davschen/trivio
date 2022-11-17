//
//  Build.swift
//  Trivio!
//
//  Created by David Chen on 10/28/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum BuildPhaseType {
    case rounds1and2, ddSelections
}

var BuildStageValueDict: [BuildStage:Int] {
    return [
        .details : 0,
        .trivioRound : 1,
        .trivioRoundDD : 2,
        .dtRound : 3,
        .dtRoundDD : 4,
        .finalTrivio: 5
    ]
}

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
}

struct CustomSetCherry: Decodable, Hashable, Identifiable, Encodable {
    @DocumentID var id: String?
    var round1CatIDs: [String]
    var round2CatIDs: [String]
    var categoryNames: [String]
    var title: String
    var titleKeywords: [String]
    var description: String
    var finalCat: String
    var finalClue: String
    var finalResponse: String
    var dateCreated: Date
    var dateLastModified: Date
    var roundOneDaily: [Int]
    var roundTwoDaily1: [Int]
    var roundTwoDaily2: [Int]
    var creatorUserID: String
    var tags: [String]
    var plays: Int
    var rating: Double
    var numRatings: Int
    var numClues: Int
    var jRoundLen: Int
    var djRoundLen: Int
    var hasTwoRounds: Bool
    var isDraft: Bool
    var isPublic: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    
}
