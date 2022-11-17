//
//  Live.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/17/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct LiveGameCustomSet: Decodable, Hashable, Identifiable, Encodable {
    @DocumentID var id: String?
    var hostUsername, hostName, userSetID, hostCode, playerCode, title, finalCat, finalClue, finalResponse: String
    var hostHasJoined, gameHasBegun, hasTwoRounds: Bool
    var numSubmitted, numClues, round1Len, round2Len: Int
    var roundOneDaily, roundTwoDaily1, roundTwoDaily2: [Int]
    var round1CategoryNames, round2CategoryNames: [String]
    var round1Clues, round1Responses, round2Clues, round2Responses : [Int:[String]]
    
    init(hostUsername: String, hostName: String, userSetId: String, hostCode: String, playerCode: String, tidyCustomSet: TidyCustomSet, customSet: CustomSetCherry, hostHasJoined: Bool = false, gameHasBegun: Bool = false, numSubmitted: Int = 0) {
        self.hostUsername = hostUsername
        self.hostName = hostName
        self.userSetID = userSetId
        self.hostCode = hostCode
        self.playerCode = playerCode
        self.hostHasJoined = hostHasJoined
        self.gameHasBegun = gameHasBegun
        self.numSubmitted = numSubmitted
        self.round1CategoryNames = tidyCustomSet.round1Cats
        self.round2CategoryNames = tidyCustomSet.round2Cats
        self.round1Clues = MasterHandler().nestedStringArrayToDict(tidyCustomSet.round1Clues)
        self.round1Responses = MasterHandler().nestedStringArrayToDict(tidyCustomSet.round1Responses)
        self.round2Clues = MasterHandler().nestedStringArrayToDict(tidyCustomSet.round2Clues)
        self.round2Responses = MasterHandler().nestedStringArrayToDict(tidyCustomSet.round2Responses)
        self.title = customSet.title
        self.finalCat = customSet.finalCat
        self.finalClue = customSet.finalClue
        self.finalResponse = customSet.finalResponse
        self.roundOneDaily = customSet.roundOneDaily
        self.roundTwoDaily1 = customSet.roundTwoDaily1
        self.roundTwoDaily2 = customSet.roundTwoDaily2
        self.numClues = customSet.numClues
        self.round1Len = customSet.round1Len
        self.round2Len = customSet.round2Len
        self.hasTwoRounds = customSet.hasTwoRounds
    }
}

extension LiveGameCustomSet {
    init(hostUsername: String = "", hostName: String = "", userSetID: String = "", hostCode: String = "", playerCode: String = "", title: String = "", finalCat: String = "", finalClue: String = "", finalResponse: String = "", hostHasJoined: Bool = false, gameHasBegun: Bool = false, hasTwoRounds: Bool = false, numSubmitted: Int = 0, numClues: Int = 0, round1Len: Int = 0, round2Len: Int = 0, roundOneDaily: [Int] = [], roundTwoDaily1: [Int] = [], roundTwoDaily2: [Int] = [], round1CategoryNames: [String] = [], round2CategoryNames: [String] = [], round1Clues: [[String]] = [], round1Responses: [[String]] = [], round2Clues: [[String]] = [], round2Responses: [[String]] = []) {
        self.hostUsername = hostUsername
        self.hostName = hostName
        self.userSetID = userSetID
        self.hostCode = hostCode
        self.playerCode = playerCode
        self.hostHasJoined = hostHasJoined
        self.gameHasBegun = gameHasBegun
        self.numSubmitted = numSubmitted
        self.round1CategoryNames = round1CategoryNames
        self.round2CategoryNames = round2CategoryNames
        self.round1Clues = MasterHandler().nestedStringArrayToDict(round1Clues)
        self.round1Responses = MasterHandler().nestedStringArrayToDict(round1Responses)
        self.round2Clues = MasterHandler().nestedStringArrayToDict(round2Clues)
        self.round2Responses = MasterHandler().nestedStringArrayToDict(round2Responses)
        self.title = title
        self.finalCat = finalCat
        self.finalClue = finalClue
        self.finalResponse = finalResponse
        self.roundOneDaily = roundOneDaily
        self.roundTwoDaily1 = roundTwoDaily1
        self.roundTwoDaily2 = roundTwoDaily2
        self.numClues = numClues
        self.round1Len = round1Len
        self.round2Len = round2Len
        self.hasTwoRounds = hasTwoRounds
    }
}
