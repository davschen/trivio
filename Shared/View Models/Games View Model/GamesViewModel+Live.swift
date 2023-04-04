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
    public func createLiveGameDocument(hostUsername: String, hostName: String) {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        guard let customSetID = self.customSet.id else { return }
        let hostCode = String(randomNumberWith(digits: 6))
        let playerCode = String(randomNumberWith(digits: 6))
        self.liveGameCustomSet = LiveGameCustomSet(hostUsername: hostUsername, hostName: hostName, userSetId: customSetID, hostCode: hostCode, playerCode: playerCode, tidyCustomSet: self.tidyCustomSet, customSet: self.customSet)
        // the document ID is myUID because I don't want one user to be making multiple live games
        db.collection("liveGames").document(myUID).addSnapshotListener { (snap, error) in
            if error != nil {
                return
            } else {
                try? self.db.collection("liveGames").document(myUID).setData(from: self.liveGameCustomSet)
            }
        }
        listenToLiveGamePlayers(liveGameCustomSetId: myUID)
    }

    public func randomNumberWith(digits:Int) -> Int {
        let min = Int(pow(Double(10), Double(digits-1))) - 1
        let max = Int(pow(Double(10), Double(digits))) - 1
        return Int(Range(uncheckedBounds: (min, max)))
    }
    
    func listenToLiveGamePlayers(liveGameCustomSetId: String) {
        let db = Firestore.firestore()
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
                try? document.data(as: LiveGamePlayer.self)
            } ?? []
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func startGame() {
        guard let liveGameCustomSetID = self.liveGameCustomSet.id else {
            return
        }

        let documentReference = db.collection("liveGames").document(liveGameCustomSetID)

        documentReference.updateData([
            "gameHasBegun": true
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
                self.liveGameCustomSet.gameHasBegun = true
            }
        }
    }
}

// Flow so I can get this shit out of my head and onto a screen:
/// iOS User creates this live game doc by tapping on "Host this game live!" in Gameplay : MobileGameSettingsView
///     This live game doc contains all the information anyone with low-level privileges will ever need to read or write to
/// When web user on desktop joins with hostCode, hostHasJoined = true
///     All web users have the same permissions upon visiting www.trivio.live, namely read and write access to the "liveGames" collection
/// If hostHasJoined, mobile web users can add themselves to "players" collection by entering playerCode
///
