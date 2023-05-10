//
//  ProfileViewModel+UserRecords.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/27/23.
//

import Foundation

extension ProfileViewModel {
    public func pullUserRecordsData() {
        guard let myUID = myUID else { return }
        let cherryUpdatesDocRef = db.collection("users").document(myUID).collection("myUserRecords").document("myUserRecordsCherry")
        cherryUpdatesDocRef.getDocument(completion: { (docSnap, error) in
            if error != nil {
                return
            }
            guard let doc = docSnap else { return }
            // Ideally, I'd check if the doc is of the type MyUserRecordsCherry, but not today.
            if !doc.exists || doc.get("mostRecentSession") == nil {
                self.db.collection("users").document(myUID).getDocument(completion: { (docSnap, error) in
                    if error != nil { return }
                    guard let doc = docSnap else { return }
                    let username = doc.get("username") as! String
                    var newUserRecord = MyUserRecordsCherry()
                    newUserRecord.username = username
                    try? cherryUpdatesDocRef.setData(from: newUserRecord)
                })
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "LLLL"
                
                guard let myUserRecordsCherry = try? doc.data(as: MyUserRecordsCherry.self) else { return }
                DispatchQueue.main.async {
                    if myUserRecordsCherry.numLiveTokens == 0 && myUserRecordsCherry.freeTokenLastGeneratedMonth != dateFormatter.string(from: Date()) {
                        // If the user is due for a free token
                        self.incrementNumTokens()
                        self.updateMyUserRecords(fieldName: "freeTokenLastGeneratedMonth", newValue: dateFormatter.string(from: Date()))
                        var murCherry = myUserRecordsCherry
                        murCherry.numLiveTokens += 1
                        self.myUserRecords.assignFromMURCherry(myUserRecordsCherry: murCherry)
                    } else {
                        self.myUserRecords.assignFromMURCherry(myUserRecordsCherry: myUserRecordsCherry)
                    }
                    self.updateMostRecentSession()
                    self.incrementNumSessions()
                    if self.myUserRecords.isAdmin { self.pullAllVIPs() }
                }
                if myUserRecordsCherry.isAdmin {
                    self.pullAllUserRecords()
                }
            }
        })
    }
    
    public func purgeAndPullAllUserRecords() {
        allUserRecords.removeAll()
        pullAllUserRecords()
    }
    
    private func pullAllUserRecords() {
        db.collection("userSessions").order(by: "mostRecentSession").limit(to: 50).getDocuments { (snap, error) in
            if error != nil { return }
            guard let data = snap?.documents else { return }
            let userSessionIDs = data.compactMap({ (docSnap) -> String in
                return docSnap.documentID
            })
            userSessionIDs.forEach { userID in
                self.db.collection("users").document(userID).collection("myUserRecords").document("myUserRecordsCherry").getDocument { (docSnap, error) in
                    if error != nil {
                        return
                    }
                    guard let myUserRecordCherry = try? docSnap?.data(as: MyUserRecordsCherry.self) else { return }
                    var userRecord = MyUserRecords()
                    userRecord.assignFromMURCherry(myUserRecordsCherry: myUserRecordCherry)
                    let insertionIndex = self.allUserRecords.insertionIndexOf(userRecord) { $0.mostRecentSession > $1.mostRecentSession }
                    self.allUserRecords.insert(userRecord, at: insertionIndex)
                }
            }
        }
    }
    
    public func updateMyUserRecords(fieldName: String, newValue: Any) {
        guard let myUID = myUID else { return }
        let cherryUpdatesDocRef = db.collection("users").document(myUID).collection("myUserRecords").document("myUserRecordsCherry")
        cherryUpdatesDocRef.setData([
            fieldName : newValue
        ], merge: true)
    }
}
