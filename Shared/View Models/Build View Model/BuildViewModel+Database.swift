//
//  BuildViewModel+Database.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/17/22.
//

import Foundation

extension BuildViewModel {
    func writeToFirestore() {
        guard let currCustomSetID = self.currCustomSet.id else { return }
        
        currCustomSet.isDraft = !checkForSetIsComplete()
        let docRef = db.collection(self.currCustomSet.isDraft ? "drafts" : "userSets").document(currCustomSetID)

        currCustomSet.dateLastModified = Date()
        currCustomSet.userID = myUID
        currCustomSet.round1CatIDs = jCategories[0..<currCustomSet.round1Len].compactMap { $0.id }
        currCustomSet.round2CatIDs = djCategories[0..<currCustomSet.round2Len].compactMap { $0.id }
        currCustomSet.categoryNames = getCategoryNames()
        currCustomSet.numClues = getNumClues()
        
        docRef.getDocument { (doc, error) in
            if error != nil { return }
            DispatchQueue.main.async {
                try? docRef.setData(from: self.currCustomSet)
                self.writeCategories()
                self.updateTagsDB()
                self.dirtyBit = 0
                if !self.currCustomSet.isDraft {
                    self.db.collection("drafts").document(currCustomSetID).delete()
                }
            }
        }
    }
    
    func writeCategories() {
        for i in 0..<self.currCustomSet.round1Len {
            let category = jCategories[i]
            guard let id = category.id else { return }
            let docRef = db.collection("userCategories").document(id)
            try? docRef.setData(from: category)
        }
        for i in 0..<self.currCustomSet.round2Len {
            let category = djCategories[i]
            guard let id = category.id else { return }
            let docRef = db.collection("userCategories").document(id)
            try? docRef.setData(from: category)
        }
    }
    
    func getCategoriesWithIDs(isDJ: Bool, ids: [String]) {
        if isDJ {
            self.djCategories = [CustomSetCategory](repeating: Empty().category(index: 0, emptyStrings: emptyStrings, gameID: gameID), count: ids.count)
        } else {
            self.jCategories = [CustomSetCategory](repeating: Empty().category(index: 0, emptyStrings: emptyStrings, gameID: gameID), count: ids.count)
        }
        for i in 0..<ids.count {
            let id = ids[i]
            db.collection("userCategories").document(id).getDocument { (doc, error) in
                if error != nil { return }
                guard let doc = doc else { return }
                guard let category = try? doc.data(as: CustomSetCategory.self) else { return }
                DispatchQueue.main.async {
                    if isDJ {
                        self.djCategories[category.index] = category
                    } else {
                        self.jCategories[category.index] = category
                    }
                    self.determineMostAdvancedStage()
                }
            }
        }
    }
    
    func updateTagsDB(tags: [String] = []) {
        let myDocRef = db.collection("users").document(myUID)
        myDocRef.getDocument { (docSnap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = docSnap else { return }
            var dbTags = doc.get("tags") as? [String:Int] ?? [:]
            let tagsToAdd = self.currCustomSet.tags.isEmpty ? self.currCustomSet.tags : tags
            for tag in tagsToAdd {
                let upperTag = tag.uppercased()
                if dbTags.keys.contains(upperTag) {
                    dbTags[upperTag]! += 1
                } else {
                    dbTags.updateValue(1, forKey: upperTag)
                }
            }
            myDocRef.setData([
                "tags" : dbTags
            ], merge: true)
        }
    }
    
    func edit(customSet: CustomSetCherry) {
        guard let customSetID = customSet.id else { return }
        
        self.gameID = customSetID
        self.clearAll()
        
        let docRef = db.collection(customSet.isDraft ? "drafts" : "userSets").document(customSetID)
        
        docRef.getDocument { (doc, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = doc else { return }
            
            let customSet: CustomSetCherry
            if let customSetOG = try? doc.data(as: CustomSet.self) {
                customSet = CustomSetCherry(customSet: customSetOG)
            } else if let customSetCherry = try? doc.data(as: CustomSetCherry.self) {
                customSet = customSetCherry
            } else {
                return
            }
            DispatchQueue.main.async {
                self.currCustomSet = customSet
                self.getCategoriesWithIDs(isDJ: false, ids: customSet.round1CatIDs)
                self.getCategoriesWithIDs(isDJ: true, ids: customSet.round2CatIDs)
                self.determineMostAdvancedStage()
                
                self.categories = self.jCategories
                self.isRandomDD = true
                self.editingClueIndex = 0
                self.round1CatsShowing = [Bool](repeating: true, count: customSet.round1Len) + [Bool](repeating: false, count: 6 - customSet.round1Len)
                self.round2CatsShowing = [Bool](repeating: true, count: customSet.round2Len) + [Bool](repeating: false, count: 6 - customSet.round2Len)
            }
        }
    }
}
