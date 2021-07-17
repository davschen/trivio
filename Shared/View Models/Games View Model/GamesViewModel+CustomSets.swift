//
//  GamesViewModel+CustomSets.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/15/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

extension GamesViewModel {
    func readCustomData() {
        guard let myUID = Auth.auth().currentUser?.uid else { return }
        db.collection("userSets")
            .whereField("userID", isEqualTo: myUID)
            .order(by: "dateCreated", descending: true).addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            DispatchQueue.main.async {
                self.customSets = data.compactMap { (queryDocSnap) -> CustomSet? in
                    return try? queryDocSnap.data(as: CustomSet.self)
                }
            }
        }
    }
    
    func getUserName(userID: String) {
        db.collection("users").document(userID).getDocument { docSnap, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = docSnap else { return }
            DispatchQueue.main.async {
                self.queriedUserName = doc.get("username") as? String ?? ""
            }
        }
    }
    
    func getCustomDataWithCompletion(setID: String, completion: @escaping (Bool) -> Void) {
        clearAll()
        reset()
        setEpisode(ep: setID)
        let group = DispatchGroup()
        db.collection("userSets").document(setID).addSnapshotListener { (doc, err) in
            group.enter()
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            guard let doc = doc else { return }
            let jCategoryIDs = doc.get("jCategoryIDs") as? [String] ?? []
            let djCategoryIDs = doc.get("djCategoryIDs") as? [String] ?? []
            let jRoundLen = doc.get("jRoundLen") as? Int ?? 0
            let djRoundLen = doc.get("djRoundLen") as? Int ?? 0
            
            for id in jCategoryIDs {
                self.db.collection("userCategories").document(id).getDocument { (doc, err) in
                    if err != nil {
                        print(err!.localizedDescription)
                        return
                    }
                    guard let doc = doc else { return }
                    DispatchQueue.main.async {
                        guard let index = doc.get("index") as? Int else { return }
                        if self.jeopardyRoundClues.isEmpty {
                            let toAdd = (jRoundLen - self.jeopardyRoundClues.count)
                            self.jeopardyRoundClues = [[String]](repeating: [""], count: toAdd)
                            self.jeopardyRoundResponses = [[String]](repeating: [""], count: toAdd)
                            self.jeopardyCategories = [String](repeating: "", count: toAdd)
                        }
                        if self.jeopardyRoundClues.indices.contains(index) {
                            let clues = doc.get("clues") as? [String] ?? []
                            let responses = doc.get("responses") as? [String] ?? []
                            self.jeopardyRoundClues[index] = clues
                            self.jeopardyRoundResponses[index] = responses
                            self.jeopardyCategories[index] = doc.get("name") as? String ?? ""
                            self.clues = self.jeopardyRoundClues
                            self.responses = self.jeopardyRoundResponses
                            self.categories = self.jeopardyCategories
                            self.jRoundLen = jRoundLen
                            self.djRoundLen = djRoundLen
                            clues.forEach {
                                self.jRoundCompletes += ($0.isEmpty ? 0 : 1)
                                self.jCategoryCompletesReference[index] += ($0.isEmpty ? 0 : 1)
                            }
                        }
                    }
                }
            }
            
            for id in djCategoryIDs {
                self.db.collection("userCategories").document(id).getDocument { (doc, err) in
                    if err != nil {
                        print(err!.localizedDescription)
                        return
                    }
                    guard let doc = doc else { return }
                    DispatchQueue.main.async {
                        guard let index = doc.get("index") as? Int else { return }
                        if self.doubleJeopardyRoundClues.isEmpty {
                            let toAdd = (djRoundLen - self.doubleJeopardyRoundClues.count)
                            self.doubleJeopardyRoundClues = [[String]](repeating: [""], count: toAdd)
                            self.doubleJeopardyRoundResponses = [[String]](repeating: [""], count: toAdd)
                            self.doubleJeopardyCategories = [String](repeating: "", count: toAdd)
                        }
                        if self.doubleJeopardyRoundClues.indices.contains(index) {
                            let clues = doc.get("clues") as? [String] ?? []
                            let responses = doc.get("responses") as? [String] ?? []
                            self.doubleJeopardyRoundClues[index] = clues
                            self.doubleJeopardyRoundResponses[index] = responses
                            self.doubleJeopardyCategories[index] = doc.get("name") as? String ?? ""
                            clues.forEach {
                                self.djRoundCompletes += ($0.isEmpty ? 0 : 1)
                                self.djCategoryCompletesReference[index] += ($0.isEmpty ? 0 : 1)
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.fjCategory = doc.get("fjCategory") as? String ?? ""
                self.fjClue = doc.get("fjClue") as? String ?? ""
                self.fjResponse = doc.get("fjResponse") as? String ?? ""
                let userID = doc.get("userID") as? String ?? "NID"
                self.jeopardyDailyDoubles = doc.get("jeopardyDailyDoubles") as? [Int] ?? []
                self.djDailyDoubles1 = doc.get("djDailyDoubles1") as? [Int] ?? []
                self.djDailyDoubles2 = doc.get("djDailyDoubles2") as? [Int] ?? []
                self.getUserName(userID: userID)
                
                guard let customSet = try? doc.data(as: CustomSet.self) else { return }
                self.customSet = customSet
                self.title = doc.get("title") as? String ?? ""
            }
            group.leave()
            group.notify(queue: .main) {
                completion(true)
            }
        }
    }
    
    func getCustomData(setID: String) {
        self.loadingGame = true
        getCustomDataWithCompletion(setID: setID) { (success) in
            if success {
                self.loadingGame = false
            }
        }
    }
}
