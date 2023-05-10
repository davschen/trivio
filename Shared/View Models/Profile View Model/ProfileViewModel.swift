//
//  ProfileVM.swift
//  Trivio!
//
//  Created by David Chen on 5/24/21.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift

class ProfileViewModel: ObservableObject {
    @Published var myTrivioUser: TrivioUser = TrivioUser()
    @Published var playedGameIDs = [String]()
    @Published var menuSelectedItem = "Summary"
    @Published var username = "" 
    @Published var name = ""
    @Published var usernameValid = false
    @Published var drafts = [CustomSetDurian]()
    @Published var triviaDeckCluesToReview = [TriviaDeckClue]()
    @Published var myTriviaDeckClues = [TriviaDeckClue]()
    @Published var searchItem = ""
    @Published var showingSettingsView = false
    @Published var settingsMenuSelectedItem = "Game Settings"
    @Published var myUserRecords = MyUserRecords()
    @Published var allUserRecords = [MyUserRecords]()
    
    @Published var currentVIPs = [String:String]()
    
    public var db = FirebaseConfigurator.shared.getFirestore()
    public var myUID = FirebaseConfigurator.shared.auth.currentUser?.uid
    
    init() {
        getUserInfo()
        pullUserRecordsData()
        fetchCluesToReview()
    }
    
    func markAsPlayed(gameID: String) {
        guard let myUID = myUID else { return }
        db.collection("users")
            .document(myUID)
            .collection("played").whereField(gameID, isEqualTo: gameID).getDocuments { (snap, error) in
                if error != nil { return }
                guard let firstDoc = snap?.documents.first else {
                    return
                }
                if !firstDoc.exists {
                    self.db.collection("users").document(myUID).collection("played").addDocument(data: [
                        "gameID" : gameID
                    ])
                }
        }
    }
    
    func beenPlayed(gameID: String) -> Bool {
        return playedGameIDs.contains(gameID)
    }
    
    public func pullAllVIPs() {
        db.collectionGroup("myUserRecords").getDocuments { (snap, error) in
            if error != nil { return }
            guard let data = snap?.documents else { return }
            data.forEach { docSnap in
                guard let username = docSnap.get("username") as? String else { return }
                guard let isVIP = docSnap.get("isVIP") as? Bool else { return }
                guard isVIP else { return }
                self.db.collection("users").whereField("username", isEqualTo: username).getDocuments { (snap, error) in
                    if error != nil { return }
                    guard let data = snap?.documents else { return }
                    guard let firstDoc = data.first else { return }
                    guard let username = firstDoc.get("username") as? String else { return }
                    guard let name = firstDoc.get("name") as? String else { return }
                    self.currentVIPs[username] = name
                }
            }
        }
    }
    
    public func updateMostRecentSession() {
        guard let myUID = myUID else { return }
        let cherryUpdatesDocRef = db.collection("users").document(myUID).collection("myUserRecords").document("myUserRecordsCherry")
        cherryUpdatesDocRef.setData([
            "mostRecentSession" : Date()
        ], merge: true)
        db.collection("userSessions").document(myUID).setData([
            "mostRecentSession" : Date()
        ], merge: true)
    }
    
    public func getUserInfo() {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        let myProfileDocRef = db.collection("users").document(myUID)
        
        myProfileDocRef.getDocument { (docSnap, error) in
            if error != nil { return }
            guard let doc = docSnap else { return }
            if let myTrivioUser = try? doc.data(as: TrivioUser.self) {
                self.myTrivioUser = myTrivioUser
            }
            self.db.document("users/\(myUID)/myUserRecords/myUserRecordsCherry").setData([
                "username" : self.myTrivioUser.username,
            ], merge: true)
        }
        
        fetchMyTriviaDeckClues()
        
        db.collection("drafts")
            .whereField("userID", isEqualTo: myUID)
            .order(by: "dateCreated", descending: true)
            .getDocuments { snap, error in
                if error != nil { return }
                guard let documents = snap?.documents else { return }
                for document in documents {
                    let customSetDurian = try? document.data(as: CustomSetDurian.self)
                    if let durianSet = customSetDurian {
                        DispatchQueue.main.async {
                            self.drafts.append(durianSet)
                        }
                    } else {
                        self.fetchDurianData(userSetID: document.documentID) { durianSet in
                            guard let durianSet = durianSet else { return }
                            DispatchQueue.main.async {
                                self.drafts.append(durianSet)
                            }
                        }
                    }
                }
        }
        
        if UserDefaults.standard.string(forKey: "clueAppearance") == nil {
            UserDefaults.standard.set("classic", forKey: "clueAppearance")
        }
        if UserDefaults.standard.string(forKey: "speechLanguage") == nil {
            UserDefaults.standard.set("americanEnglish", forKey: "speechLanguage")
        }
        if UserDefaults.standard.string(forKey: "speechSpeed") == nil {
            UserDefaults.standard.set(0.5, forKey: "speechSpeed")
        }
        if UserDefaults.standard.string(forKey: "speechGender") == nil {
            UserDefaults.standard.set("male", forKey: "speechGender")
        }
    }
    
    private func fetchDurianData(userSetID: String, completion: @escaping (CustomSetDurian?) -> Void) {
        let userSetsRef = db.collection("userSets").document(userSetID)
        let userCategoriesRef = db.collection("userCategories")

        userSetsRef.getDocument { (userSetDoc, error) in
            if let error = error {
                print("Error fetching userSet: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let userSetDoc = userSetDoc,
                  userSetDoc.exists,
                  let customSetCherry = try? userSetDoc.data(as: CustomSetCherry.self),
                  let round1CatIDs = userSetDoc["round1CatIDs"] as? [String],
                  let round2CatIDs = userSetDoc["round2CatIDs"] as? [String]
            else {
                completion(nil)
                return
            }

            let allCategoryIDs = Array(Set(round1CatIDs + round2CatIDs))
            var categories: [String: (name: String, clues: [String], responses: [String])] = [:]

            let dispatchGroup = DispatchGroup()
            
            for catID in allCategoryIDs {
                if catID.isEmpty { continue }
                dispatchGroup.enter()
                userCategoriesRef.document(catID).getDocument { (categoryDoc, error) in
                    if let error = error {
                        print("Error fetching category: \(error.localizedDescription)")
                    } else if let categoryDoc = categoryDoc,
                              categoryDoc.exists,
                              let name = categoryDoc["name"] as? String,
                              let clues = categoryDoc["clues"] as? [String],
                              let responses = categoryDoc["responses"] as? [String] {
                        categories[catID] = (name: name, clues: clues, responses: responses)
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                let customSet = CustomSetDurian(customSet: customSetCherry, round1CatIDs: round1CatIDs, round2CatIDs: round2CatIDs, categories: categories)
                completion(customSet)
            }
        }
    }
    
    private func fetchMyTriviaDeckClues() {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        db.collectionGroup("triviaDeckClues")
            .whereField("authorID", isEqualTo: myUID)
            .getDocuments { (snap, error) in
            if error != nil {
                print("Error getting triviaDeckClue documents: \(error!.localizedDescription)")
                return
            }
            guard let data = snap?.documents else { return }
            self.myTriviaDeckClues = data.compactMap({ (queryDocSnap) -> TriviaDeckClue? in
                let triviaDeckClue = try? queryDocSnap.data(as: TriviaDeckClue.self)
                return triviaDeckClue
            }).sorted(by: { $0.submittedDate > $1.submittedDate })
        }
    }
    
    public func incrementNumTokens() {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        let usersRef = db.collection("users").document(myUID).collection("myUserRecords").document("myUserRecordsCherry")
        usersRef.setData([
            "numLiveTokens" : FieldValue.increment(Int64(1)),
        ], merge: true)
        self.myUserRecords.numLiveTokens += 1
    }
    
    public func incrementNumSessions() {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        let usersRef = db.collection("users").document(myUID).collection("myUserRecords").document("myUserRecordsCherry")
        usersRef.setData([
            "numTrackedSessions" : FieldValue.increment(Int64(1)),
        ], merge: true)
        self.myUserRecords.numTrackedSessions += 1
    }
    
    func writeKeyValueToFirestore(key: String, value: Any) {
        db.collection("users").document(FirebaseConfigurator.shared.auth.currentUser?.uid ?? "NID").setData([
            key : value
        ], merge: true)
    }
    
    func shouldRequestAppStoreReview() -> (Bool, String) {
        let currentVersion = "Cherry"
        return (myUserRecords.numTrackedSessions > 10 && !(myUserRecords.lastVersionReviewPrompt == currentVersion), currentVersion)
    }
    
    func getInitials(name: String) -> String {
        var initials = ""
        let nameSplit = name.split(separator: " ")
        for i in 0..<nameSplit.count {
            let name = nameSplit[i]
            if initials.count < 3 {
                initials += name.prefix(1)
            }
        }
        return initials
    }
    
    func logOut() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        NotificationCenter.default.post(name: NSNotification.Name("LogInStatusChange"), object: nil)
        try? FirebaseConfigurator.shared.auth.signOut()
    }
    
    func deleteCurrentUserFromDB() {
        guard let uid = myUID else { return }
        let docRef = self.db.collection("users").document(uid)
        docRef.delete()
        logOut()
    }
}

enum DeviceType {
    case iPad, iPhone
}
