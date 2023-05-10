//
//  GamesViewModel+CustomSets.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/15/21.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

extension GamesViewModel {
    func fetchMyCustomSets() {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        db.collection("userSets")
            .whereField("userID", isEqualTo: myUID)
            .order(by: "dateCreated", descending: true).getDocuments { (snap, error) in
                if let error = error {
                    print("Error fetching public sets: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snap?.documents else { return }
                
                for document in documents {
                    let customSetDurian = try? document.data(as: CustomSetDurian.self)
                    if let durianSet = customSetDurian {
                        DispatchQueue.main.async {
                            self.customSets.append(durianSet)
                        }
                    } else {
                        self.fetchDurianData(userSetID: document.documentID) { durianSet in
                            guard let durianSet = durianSet else { return }
                            DispatchQueue.main.async {
                                self.customSets.append(durianSet)
                            }
                        }
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
    
    private func dictToNestedStringArray(dict: [Int:[String]]) -> [[String]] {
        var toReturn = [[String]]()
        for categoryIndex in 0..<dict.count {
            if let stringArray = dict[categoryIndex] {
                toReturn.append(stringArray)
            }
        }
        return toReturn
    }
    
    func getCustomSetData(customSet: CustomSetDurian) {
        clearAll()
        reset()
        self.customSet = customSet
        
        clues = dictToNestedStringArray(dict: customSet.round1Clues)
        responses = dictToNestedStringArray(dict: customSet.round1Responses)
        categories = customSet.round1CategoryNames
        generateFinishedCatsAndClues(cluesNestedDict: customSet.round1Clues)
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
    
    func getCustomData(customSet: CustomSetDurian) {
        clearAll()
        reset()
        getUserName(userID: customSet.userID)
        completedCustomSetClues = countNonEmptyClues(cluesDict: customSet.round1Clues)
        self.customSet = customSet
    }
    
    func countNonEmptyClues(cluesDict: [Int:[String]] = [:]) -> Int {
        let cluesDictCopy = cluesDict.isEmpty ? (gamePhase == .round1 ? customSet.round1Clues : customSet.round2Clues) : cluesDict
        let nonEmptyCluesCount = cluesDictCopy.reduce(0) { (count, cluesArray) -> Int in
            count + cluesArray.value.filter { !$0.isEmpty }.count
        }
        return nonEmptyCluesCount
    }
    
    func deleteSet(setID: String) {
        customSets = customSets.filter { customSet in
            guard let id = customSet.id else { return true }
            return setID != id
        }
    }
    
    // for scrolling
    func getUnitPoint() -> UnitPoint {
        let categoryCount = gamePhase == .round1 ? customSet.round1Len : customSet.round2Len
        return currentCategoryIndex == categoryCount - 1 ? .trailing : .center
    }
}
