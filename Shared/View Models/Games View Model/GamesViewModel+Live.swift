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
        guard let myUID = Auth.auth().currentUser?.uid else { return }
        guard let customSetID = self.customSet.id else { return }
        let hostCode = String(randomNumberWith(digits: 6))
        let playerCode = String(randomNumberWith(digits: 6))
        self.liveGameCustomSet = LiveGameCustomSet(hostUsername: hostUsername, hostName: hostName, userSetId: customSetID, hostCode: hostCode, playerCode: playerCode, tidyCustomSet: self.tidyCustomSet, customSet: self.customSet)
        // the document ID is myUID because I don't want one user to be making multiple live games
        db.collection("liveGames").document(myUID).getDocument { (snap, error) in
            if error != nil {
                return
            } else {
//                guard let doc = snap else { return }
                try? self.db.collection("liveGames").document(myUID).setData(from: self.liveGameCustomSet)
//                if doc.exists {
//                    // We don't want to overwrite a good thing going
//                    // Check if the live game is over 2hrs old (if so, overwrite) or if
//                    // the user wants to interrupt the existing game (existing
//                    // == hostHasJoined is true
//                    guard let liveGameSet = try? doc.data(as: LiveGameCustomSet.self) else { return }
//                    let diffComponents = Calendar.current.dateComponents([.hour], from: liveGameSet.dateInitiated, to: Date())
//                    if diffComponents.hour ?? 2 > 2 {
//                        // the live game is over 2 hours old
//                        try? self.db.collection("liveGames").document(myUID).setData(from: self.liveGameCustomSet)
//                    } else if liveGameSet.hostHasJoined {
//                        // This is a hard problem to solve. I am trying to signal the outside world that there is a game going on, and the alert shown should present the option to override the existing game (<game code>)
//                        // Potential solution: increment some int liveGameExistsTicker and onChange of this published variable, present the alert. Yeah!!
//                        return
//                    }
//                } else {
//                    try? self.db.collection("liveGames").document(myUID).setData(from: self.liveGameCustomSet)
//                }
            }
        }
    }

    public func randomNumberWith(digits:Int) -> Int {
        let min = Int(pow(Double(10), Double(digits-1))) - 1
        let max = Int(pow(Double(10), Double(digits))) - 1
        return Int(Range(uncheckedBounds: (min, max)))
    }
}

// Flow so I can get this shit out of my head and onto a screen:
/// iOS User creates this live game doc by tapping on "Host this game live!" in Gameplay : MobileGameSettingsView
///     This live game doc contains all the information anyone with low-level privileges will ever need to read or write to
/// When web user on desktop joins with hostCode, hostHasJoined = true
///     All web users have the same permissions upon visiting www.trivio.live, namely read and write access to the "liveGames" collection
/// If hostHasJoined, mobile web users can add themselves to "players" collection by entering playerCode
///
