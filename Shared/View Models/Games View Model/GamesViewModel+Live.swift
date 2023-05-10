//
//  GamesViewModel+Live.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/17/22.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

extension GamesViewModel {
    public func startLiveGame(hostUsername: String, hostName: String) {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        createLiveGameDocument(hostUsername: hostUsername, hostName: hostName)
        listenToLiveGameDocument(liveGameCustomSetId: myUID)
        listenToLiveGamePlayers(liveGameCustomSetId: myUID)
    }
    
    public func startLiveJeopardyGame(hostUsername: String, hostName: String) {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        createLiveJeopardyGameDocument(hostUsername: hostUsername, hostName: hostName)
        listenToLiveGameDocument(liveGameCustomSetId: myUID)
        listenToLiveGamePlayers(liveGameCustomSetId: myUID)
    }
    
    public func createLiveGameDocument(hostUsername: String, hostName: String) {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        
        let hostCode = String(randomNumberWith(digits: 6))
        let playerCode = String(randomNumberWith(digits: 6))
        
        guard let customSetID = self.customSet.id else { return }
        self.liveGameCustomSet = LiveGameCustomSet(hostUsername: hostUsername, hostName: hostName, userSetId: customSetID, hostCode: hostCode, playerCode: playerCode, customSet: self.customSet)
        
        // the document ID is myUID because I don't want one user to be making multiple live games
        do {
            try self.db.collection("liveGames").document(myUID).setData(from: self.liveGameCustomSet)
        } catch let error {
            print("Error writing live game custom set: \(error.localizedDescription)")
        }
    }
    
    public func createLiveJeopardyGameDocument(hostUsername: String, hostName: String) {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        
        let hostCode = String(randomNumberWith(digits: 6))
        let playerCode = String(randomNumberWith(digits: 6))
        
        guard let jeopardySetID = self.customSet.id else {
            print("Error getting jeopardy set id")
            return
        }
        self.liveGameCustomSet = LiveGameCustomSet(hostUsername: hostUsername, hostName: hostName, userSetId: jeopardySetID, hostCode: hostCode, playerCode: playerCode, customSet: self.customSet, jeopardySet: self.jeopardySet)
        do {
            try self.db.collection("liveGames").document(myUID).setData(from: self.liveGameCustomSet)
        } catch let error {
            print("Error writing live game custom set: \(error.localizedDescription)")
        }
    }

    public func randomNumberWith(digits:Int) -> Int {
        let min = Int(pow(Double(10), Double(digits-1))) - 1
        let max = Int(pow(Double(10), Double(digits))) - 1
        return Int(Range(uncheckedBounds: (min, max)))
    }
    
    func listenToLiveGameDocument(liveGameCustomSetId: String) {
        let liveGameRef = db.collection("liveGames").document(liveGameCustomSetId)

        listener = liveGameRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error listening for live game document updates: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                self.liveGameCustomSet = try! snapshot.data(as: LiveGameCustomSet.self)!
            }
        }
    }
    
    func listenToLiveGamePlayers(liveGameCustomSetId: String) {
        let playersRef = db.collection("liveGames")
            .document(liveGameCustomSetId)
            .collection("players")
            .order(by: "currentScore", descending: true)

        listener = playersRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error listening for live game players updates: \(error.localizedDescription)")
                return
            }

            self.liveGamePlayers = snapshot?.documents.compactMap { document in
                return try? document.data(as: LiveGamePlayer.self)
            } ?? []
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func setLiveCurrentSelectedClue(categoryIndex: Int, clueIndex: Int) {
        liveGameCustomSet.currentCategoryIndex = categoryIndex
        liveGameCustomSet.currentClueIndex = clueIndex
        liveGameCustomSet.buzzersEnabled = false
        
        if Clue(liveGameCustomSet: liveGameCustomSet).isWVC {
            liveGameCustomSet.currentGameDisplay = "preWVC"
        } else {
            liveGameCustomSet.currentGameDisplay = "clue"
        }
        
        clueMechanics.setTimeElapsed(newValue: 0)
        
        modifyFinishedClues2D(categoryIndex: categoryIndex, clueIndex: clueIndex)
        currentCategoryIndex = categoryIndex
        
        updateLiveGameCustomSet()
    }

    func getRandomIncompleteClue() -> (categoryIndex: Int, clueIndex: Int)? {
        var n = 0
        var selected: (categoryIndex: Int, clueIndex: Int)? = nil
        
        for categoryIndex in 0..<finishedClues2D.count {
            for clueIndex in 0..<finishedClues2D[categoryIndex].count {
                if finishedClues2D[categoryIndex][clueIndex] == .incomplete {
                    n += 1
                    if Int.random(in: 0..<n) == 0 {
                        selected = (categoryIndex, clueIndex)
                    }
                }
            }
        }
        return selected
    }
    
    func updateLiveGameCustomSet() {
        guard let liveGameCustomSetID = self.liveGameCustomSet.id else {
            print("Error: liveGameCustomSet ID not found")
            return
        }

        let documentReference = db.collection("liveGames").document(liveGameCustomSetID)

        do {
            let data = try Firestore.Encoder().encode(liveGameCustomSet)
            documentReference.updateData(data) { error in
                if let error = error {
                    print("Error updating liveGameCustomSet: \(error)")
                } else {
                    print("liveGameCustomSet successfully updated")
                }
            }
        } catch let error {
            print("Error encoding liveGameCustomSet: \(error)")
        }
    }
    
    func clearLiveBuzzers() {
        guard let liveGameCustomSetID = self.liveGameCustomSet.id else {
            return
        }

        let liveGamesRef = db.collection("liveGames").document(liveGameCustomSetID)
        let playersRef = liveGamesRef.collection("players")

        playersRef.whereField("inBuzzerRace", isEqualTo: true).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    document.reference.updateData([
                        "inBuzzerRace": false
                    ])
                }
            }
        }

        liveGamesRef.updateData([
            "buzzerWinnerId": "",
            "buzzersEnabledDateTime": Date()
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func clearLiveBuzzersSideRail() {
        setCurrentPlayer(buzzerWinnerId: liveGameCustomSet.buzzerWinnerId)
        
        liveGameCustomSet.buzzerWinnerId.removeAll()
        liveGameCustomSet.buzzersEnabled = false
        
        guard let liveGameCustomSetID = self.liveGameCustomSet.id else {
            return
        }

        let liveGamesRef = db.collection("liveGames").document(liveGameCustomSetID)
        let playersRef = liveGamesRef.collection("players")

        playersRef.whereField("inBuzzerRace", isEqualTo: true).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    document.reference.updateData([
                        "inBuzzerRace": false,
                        "responseSubmitted": false,
                        "currentResponse": "",
                        "wager": 0
                    ])
                }
            }
        }
    }
    
    func updateLivePlayerScore(previousResponseStatus: LiveGameResponseStatus, responseStatus: LiveGameResponseStatus) {
        guard let liveGameCustomSetID = liveGameCustomSet.id else { return }
        
        let playerRef = db.collection("liveGames").document(liveGameCustomSetID)
            .collection("players").document(liveGameCustomSet.buzzerWinnerId)
        
        var currentPointValueInt = Clue(liveGameCustomSet: liveGameCustomSet).pointValueInt
        
        guard let buzzedPlayer = liveGamePlayers.first(where: { $0.id == liveGameCustomSet.buzzerWinnerId }) else { return }
        currentPointValueInt = buzzedPlayer.currentWager > 0 ? buzzedPlayer.currentWager : currentPointValueInt
        
        func scoreAdjustment(for status: LiveGameResponseStatus) -> Int {
            switch status {
            case .correct:
                return currentPointValueInt
            case .incorrect:
                return -currentPointValueInt
            default:
                return 0
            }
        }
        
        let toAdd = -scoreAdjustment(for: previousResponseStatus)
        let newScore = scoreAdjustment(for: responseStatus)
        
        playerRef.getDocument { document, error in
            if let document = document, document.exists, let currentScore = document.get("currentScore") as? Int {
                playerRef.updateData([
                    "currentScore": currentScore + toAdd + newScore,
                    "previousScore": currentScore + toAdd
                ])
            }
        }
    }
    
    func deleteLiveGamePlayer(playerId: String?) {
        guard let playerId = playerId else { return }
        guard let liveGameCustomSetId = liveGameCustomSet.id else { return }

        let playerRef = db.collection("liveGames")
            .document(liveGameCustomSetId)
            .collection("players")
            .document(playerId)

        // Delete the player document from Firestore
        playerRef.delete { error in
            if let error = error {
                print("Error deleting player: \(error.localizedDescription)")
            } else {
                print("Player successfully deleted")
                
                // Remove the deleted player from the liveGamePlayers array
                if let playerIndex = self.liveGamePlayers.firstIndex(where: { $0.id == playerId }) {
                    self.liveGamePlayers.remove(at: playerIndex)
                }
            }
        }
    }
    
    func updateLiveGamePlayerRanks() {
        guard let liveGameCustomSetID = liveGameCustomSet.id else { return }
        
        let playersRef = db.collection("liveGames").document(liveGameCustomSetID).collection("players")
        
        // Fetch all players
        playersRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching live game players: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            // Sort players by currentScore in descending order
            let sortedPlayers = documents.sorted { document1, document2 in
                (document1.get("currentScore") as? Int ?? 0) > (document2.get("currentScore") as? Int ?? 0)
            }
            
            var rank = 1
            var previousScore: Int?
            
            for (index, player) in sortedPlayers.enumerated() {
                let currentScore = player.get("currentScore") as? Int ?? 0
                
                // Handle ties
                if let previousScore = previousScore, currentScore == previousScore {
                    // Do not increment rank for tied players
                } else {
                    rank = index + 1
                }
                
                let playerID = player.documentID
                
                // Update player ranks
                playersRef.document(playerID).updateData([
                    "previousRank": player.get("currentRank") ?? rank,
                    "currentRank": rank
                ]) { error in
                    if let error = error {
                        print("Error updating player rank: \(error.localizedDescription)")
                    }
                }
                
                previousScore = currentScore
            }
        }
    }
    
    func setCurrentPlayer(buzzerWinnerId: String) {
        if buzzerWinnerId.isEmpty { return }
        
        guard let liveGameCustomSetID = self.liveGameCustomSet.id else {
            return
        }

        let liveGamesRef = db.collection("liveGames").document(liveGameCustomSetID)
        let playersRef = liveGamesRef.collection("players").document(buzzerWinnerId)

        playersRef.getDocument { document, error in
            if let error = error {
                print("Error fetching player data: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Player document does not exist")
                return
            }
            
            let currentScore = document.get("currentScore") as? Int ?? 0
            let previousScore = document.get("previousScore") as? Int ?? 0
            
            if currentScore > previousScore {
                liveGamesRef.updateData([
                    "currentPlayerId": buzzerWinnerId
                ]) { error in
                    if let error = error {
                        print("Error updating currentPlayerId: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func moveOntoLiveGameRound2() {
        liveGameCustomSet.currentRound = "round2"
        categories = liveGameCustomSet.round2CategoryNames
        generateFinishedClues2D()
        pointValueArray = round2PointValues
        currentCategoryIndex = 0
    }
    
    func doneWithLiveRound() -> Bool {
        if liveGameCustomSet.currentRound != "finalRound" {
            return finishedCategories.allSatisfy({ $0 })
        } else {
            return false
        }
    }
}
