//
//  BuildViewModel.swift
//  Trivio
//
//  Created by David Chen on 3/12/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class BuildViewModel: ObservableObject {
    @Published var buildStage: BuildStage = .trivioRound
    @Published var currentDisplay: CurrentDisplay = .grid
    @Published var isEditing = false
    @Published var isEditingDraft = false
    
    @Published var moneySections = ["", "", "", "", ""]
    @Published var jeopardyDailyDoubles = [Int]()
    @Published var djDailyDoubles1 = [Int]()
    @Published var djDailyDoubles2 = [Int]()
    @Published var fjCategory = ""
    @Published var fjClue = ""
    @Published var fjResponse = ""
    
    @Published var gameID = ""
    @Published var isPublic = true
    @Published var tags = [String]()
    @Published var tag = ""
    @Published var setName = ""
    @Published var jRoundLen = 0
    @Published var djRoundLen = 0
    @Published var categories = [Category]()
    @Published var jCategories = [Category]()
    @Published var djCategories = [Category]()
    @Published var isRandomDD = false
    
    @Published var editingIndex = 0
    @Published var choosingDailyDoubles = false
    @Published var jCategoriesShowing = [Bool]()
    @Published var djCategoriesShowing = [Bool]()
    
    @Published var cluePreview = ""
    @Published var responsePreview = ""
    @Published var processPending = false
    @Published var showingBuildView = false
    
    private var moneySectionsJ = ["200", "400", "600", "800", "1000"]
    private var moneySectionsDJ = ["400", "800", "1200", "1600", "2000"]
    private var db = Firestore.firestore()
    private var emptyStrings = ["", "", "", "", ""]
    private var myUID = Auth.auth().currentUser?.uid ?? "no_one"
    
    init() {
        self.fillBlanks()
    }
    
    func clearAll() {
        self.jRoundLen = 6
        self.djRoundLen = 6
        self.categories.removeAll()
        self.jCategories.removeAll()
        self.djCategories.removeAll()
        self.setName.removeAll()
        self.jeopardyDailyDoubles.removeAll()
        self.djDailyDoubles1.removeAll()
        self.djDailyDoubles2.removeAll()
        self.fjCategory.removeAll()
        self.fjClue.removeAll()
        self.fjResponse.removeAll()
        self.tags.removeAll()
        
        self.isRandomDD = false
        self.editingIndex = 0
        self.jCategoriesShowing.removeAll()
        self.djCategoriesShowing.removeAll()
        self.gameID = UUID().uuidString
        self.moneySections = moneySectionsDJ
        self.fillBlanks()
        
        self.buildStage = .trivioRound
        self.currentDisplay = .grid
    }
    
    func writeToFirestore(isDraft: Bool = false, completion: @escaping (Bool) -> Void) {
        let docRef = db.collection(isDraft ? "drafts" : "userSets").document(gameID)
        docRef.getDocument { (doc, error) in
            if error != nil { return }
            guard let doc = doc else { return }
            let plays = doc.get("plays") as? Int ?? 0
            let rating = doc.get("rating") as? Double ?? 0
            let numRatings = doc.get("numRatings") as? Int ?? 0
            let averageScore = doc.get("averageScore") as? Double ?? 0
            let date = doc.get("dateCreated") as? Timestamp ?? Timestamp()
            
            DispatchQueue.main.async {
                try? docRef.setData(from:
                                CustomSet(
                                    jCategoryIDs: self.getCategoryIDs(isDJ: false),
                                    djCategoryIDs: self.getCategoryIDs(isDJ: true),
                                    categoryNames: self.getCategoryNames(),
                                    title: self.setName,
                                    titleKeywords: self.getKeywords(),
                                    fjCategory: self.fjCategory.uppercased(),
                                    fjClue: self.fjClue,
                                    fjResponse: self.fjResponse,
                                    dateCreated: date.dateValue(),
                                    jeopardyDailyDoubles: self.jeopardyDailyDoubles,
                                    djDailyDoubles1: self.djDailyDoubles1,
                                    djDailyDoubles2: self.djDailyDoubles2,
                                    userID: Auth.auth().currentUser?.uid ?? "no_one",
                                    isPublic: self.isPublic,
                                    tags: self.tags.compactMap { $0.uppercased() },
                                    plays: plays,
                                    rating: rating,
                                    numRatings: numRatings,
                                    numclues: self.getNumClues(),
                                    averageScore: averageScore,
                                    jRoundLen: self.jRoundLen,
                                    djRoundLen: self.djRoundLen), completion: { (error) in
                                        if error != nil {
                                            return
                                        } else {
                                            completion(true)
                                        }
                                    }
                )
                self.writeCategories()
                self.updateTagsDB()
                if self.isEditingDraft && !isDraft {
                    self.db.collection("drafts").document(self.gameID).delete()
                }
            }
        }
    }
    
    func writeCategories() {
        for i in 0..<self.jRoundLen {
            let category = jCategories[i]
            guard let id = category.id else { return }
            let docRef = db.collection("userCategories").document(id)
            try? docRef.setData(from: category)
        }
        for i in 0..<self.djRoundLen {
            let category = djCategories[i]
            guard let id = category.id else { return }
            let docRef = db.collection("userCategories").document(id)
            try? docRef.setData(from: category)
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
            let tagsToAdd = tags.isEmpty ? self.tags : tags
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
    
    func edit(isDraft: Bool = false, gameID: String) {
        self.showingBuildView.toggle()
        self.isEditing = true
        self.gameID = gameID
        self.jCategories.removeAll()
        self.djCategories.removeAll()
        let docRef = db.collection(isDraft ? "drafts" : "userSets").document(gameID)
        docRef.getDocument { (doc, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = doc else { return }
            guard let customSet = try? doc.data(as: CustomSet.self) else { return }
            DispatchQueue.main.async {
                self.jRoundLen = customSet.jRoundLen
                self.djRoundLen = customSet.djRoundLen
                self.getCategoriesWithIDs(isDJ: false, ids: customSet.jCategoryIDs)
                self.getCategoriesWithIDs(isDJ: true, ids: customSet.djCategoryIDs)
                self.setName = customSet.title
                self.jeopardyDailyDoubles = customSet.jeopardyDailyDoubles
                self.djDailyDoubles1 = customSet.djDailyDoubles1
                self.djDailyDoubles2 = customSet.djDailyDoubles2
                self.fjCategory = customSet.fjCategory
                self.fjClue = customSet.fjClue
                self.fjResponse = customSet.fjResponse
                self.tags = customSet.tags
                self.isPublic = customSet.isPublic
                
                self.categories = self.jCategories
                self.isRandomDD = true
                self.editingIndex = 0
                self.jCategoriesShowing = [Bool](repeating: true, count: 6)
                self.djCategoriesShowing = [Bool](repeating: true, count: 6)
            }
        }
    }
    
    func saveDraft() {
        writeToFirestore(isDraft: true) { (success) in
            self.processPending = true
            if success {
                self.processPending = false
                self.buildStage = .trivioRound
                self.showingBuildView.toggle()
            }
        }
    }
    
    func getCategoryIDs(isDJ: Bool) -> [String] {
        var IDs = [String]()
        for i in 0..<(isDJ ? djRoundLen : jRoundLen) {
            let category = isDJ ? djCategories[i] : jCategories[i]
            if let id = category.id {
                IDs.append(id)
            }
        }
        return IDs
    }
    
    func fillBlanks() {
        self.jRoundLen = 6
        self.djRoundLen = 6
        for i in 0..<self.jRoundLen {
            self.jCategories.append(Empty().category(index: i, emptyStrings: emptyStrings, gameID: gameID))
            jCategoriesShowing.append(true)
        }
        for i in 0..<self.djRoundLen {
            self.djCategories.append(Empty().category(index: i, emptyStrings: emptyStrings, gameID: gameID))
            djCategoriesShowing.append(true)
        }
        gameID = UUID().uuidString
        moneySections = moneySectionsJ
        buildStage = .trivioRound
    }
    
    func start() {
        clearAll()
        showingBuildView.toggle()
        isEditing = false
        isEditingDraft = false
    }
    
    func getCategoriesWithIDs(isDJ: Bool, ids: [String]) {
        if isDJ {
            self.djCategories = [Category](repeating: Empty().category(index: 0, emptyStrings: emptyStrings, gameID: gameID), count: ids.count)
        } else {
            self.jCategories = [Category](repeating: Empty().category(index: 0, emptyStrings: emptyStrings, gameID: gameID), count: ids.count)
        }
        for i in 0..<ids.count {
            let id = ids[i]
            db.collection("userCategories").document(id).getDocument { (doc, error) in
                if error != nil { return }
                guard let doc = doc else { return }
                guard let category = try? doc.data(as: Category.self) else { return }
                DispatchQueue.main.async {
                    if isDJ {
                        self.djCategories[category.index] = category
                    } else {
                        self.jCategories[category.index] = category
                    }
                }
            }
        }
    }
    
    func addCategory() {
        if buildStage == .trivioRound {
            if self.jRoundLen == 6 { return }
            self.jRoundLen += 1
            jCategoriesShowing[jRoundLen - 1] = true
            if jCategories.count <= jRoundLen {
                self.jCategories.append(Empty().category(index: jRoundLen - 1, emptyStrings: emptyStrings, gameID: gameID))
            }
        } else if buildStage == .dtRound {
            if self.djRoundLen == 6 { return }
            self.djRoundLen += 1
            djCategoriesShowing[djRoundLen - 1] = true
            if djCategories.count <= djRoundLen {
                self.jCategories.append(Empty().category(index: djRoundLen - 1, emptyStrings: emptyStrings, gameID: gameID))
            }
        }
    }
    
    func subtractCategory(index: Int, last: Bool) {
        if buildStage == .trivioRound {
            if self.jRoundLen == 3 { return }
            self.jRoundLen -= 1
            jCategoriesShowing[jRoundLen] = false
        } else if buildStage == .dtRound {
            if self.djRoundLen == 3 { return }
            self.djRoundLen -= 1
            djCategoriesShowing[djRoundLen] = false
        }
    }
    
    func getNumClues() -> Int {
        var numClues = 0
        for i in 0..<jRoundLen {
            let clues = jCategories[i].clues
            let responses = jCategories[i].responses
            for j in 0..<emptyStrings.count {
                if !clues[j].isEmpty && !responses[j].isEmpty {
                    numClues += 1
                }
            }
        }
        for i in 0..<djRoundLen {
            let clues = djCategories[i].clues
            let responses = djCategories[i].responses
            for j in 0..<emptyStrings.count {
                if !clues[j].isEmpty && !responses[j].isEmpty {
                    numClues += 1
                }
            }
        }
        return numClues
    }
    
    func clearDailyDoubles() {
        if buildStage == .trivioRoundDD {
            self.jeopardyDailyDoubles.removeAll()
        } else if buildStage == .dtRoundDD {
            self.djDailyDoubles1.removeAll()
            self.djDailyDoubles2.removeAll()
        }
    }
    
    func randomDDs() {
        if buildStage == .trivioRoundDD {
            while self.jeopardyDailyDoubles.isEmpty {
                let randCol = Int.random(in: 0..<jRoundLen)
                let randRow = Int.random(in: 0..<5)

                if !self.jCategories[randCol].clues[randRow].isEmpty {
                    self.jeopardyDailyDoubles = [randCol, randRow]
                }
            }
        } else if buildStage == .dtRoundDD {
            while self.djDailyDoubles1.isEmpty || self.djDailyDoubles2.isEmpty {
                let randCol = Int.random(in: 0..<djRoundLen)
                let randRow = Int.random(in: 0..<5)
                if self.djDailyDoubles1.isEmpty {
                    if !self.djCategories[randCol].clues[randRow].isEmpty {
                        self.djDailyDoubles1 = [randCol, randRow]
                    }
                } else if self.djDailyDoubles2.isEmpty {
                    if !self.djCategories[randCol].clues[randRow].isEmpty
                        && self.djDailyDoubles1[0] != randCol {
                        self.djDailyDoubles2 = [randCol, randRow]
                    }
                }
            }
        }
    }
    
    func getCategoryName(catIndex: Int) -> String {
        if buildStage == .trivioRound || buildStage == .trivioRoundDD {
            return jCategories[catIndex].name
        } else {
            return djCategories[catIndex].name
        }
    }
    
    func getClueResponsePair(crIndex: Int, catIndex: Int) -> (clue: String, response: String) {
        if buildStage == .trivioRound {
            return (jCategories[catIndex].clues[crIndex], jCategories[catIndex].responses[crIndex])
        } else {
            return (djCategories[catIndex].clues[crIndex], djCategories[catIndex].responses[crIndex])
        }
    }
    
    func addCategoryName(name: String, catIndex: Int) {
        if buildStage == .trivioRound || buildStage == .trivioRoundDD {
            jCategories[catIndex].name = name
        } else {
            djCategories[catIndex].name = name
        }
    }
    
    func addClueResponsePair(clue: String, response: String, crIndex: Int, catIndex: Int) {
        if buildStage == .trivioRound {
            jCategories[catIndex].clues[crIndex] = clue
            jCategories[catIndex].responses[crIndex] = response
        } else {
            djCategories[catIndex].clues[crIndex] = clue
            djCategories[catIndex].responses[crIndex] = response
        }
    }
    
    func ddsFilled() -> Bool {
        switch buildStage {
        case .dtRoundDD:
            return !djDailyDoubles1.isEmpty && !djDailyDoubles2.isEmpty
        default:
            return !jeopardyDailyDoubles.isEmpty
        }
    }
    
    func setEditingIndex(index: Int) {
        self.editingIndex = index
    }
    
    func stepStringHandler() -> String {
        var stepString = ""
        switch buildStage {
        case .trivioRound:
            stepString = "Trivio! Round"
        case .trivioRoundDD:
            stepString = "Trivio! Round DDs"
        case .dtRound:
            stepString = "Double Trivio! Round"
        case .dtRoundDD:
            stepString = "Double Trivio! Round DDs"
        case .finalTrivio:
            stepString = "Final Trivio! Round"
        default:
            stepString = "Finishing Touches"
        }
        return stepString
    }
    
    func descriptionHandler() -> String {
        var description = ""
        switch buildStage {
        case .trivioRound:
            description = "Add & Edit Categories"
        case .trivioRoundDD:
            description = "Select One Duplex of the Day"
        case .dtRound:
            description = "Add & Edit Categories"
        case .dtRoundDD:
            description = "Select Two Duplex of the Days"
        case .finalTrivio:
            description = "Add A Category, Clue, and Response"
        default:
            description = "Add a title, at least 2 tags, and decide if the set should be public"
        }
        return description
    }
    
    func backStringHandler() -> String {
        var backString = ""
        switch buildStage {
        case .trivioRoundDD, .dtRoundDD:
            backString = "Back to Editing Categories"
        case .dtRound, .finalTrivio:
            backString = "Back to Choosing Duplex of the Days"
        case .details:
            backString = "Back to Final Trivio"
        default:
            backString = "Back"
        }
        return backString
    }
    
    func back() {
        switch buildStage {
        case .trivioRoundDD:
            buildStage = .trivioRound
            currentDisplay = .grid
        case .dtRound:
            moneySections = moneySectionsJ
            buildStage = .trivioRoundDD
            currentDisplay = .grid
        case .dtRoundDD:
            buildStage = .dtRound
            currentDisplay = .grid
        case .finalTrivio:
            buildStage = .dtRoundDD
            currentDisplay = .grid
        default:
            buildStage = .finalTrivio
            currentDisplay = .finalTrivio
        }
    }
    
    func nextPermitted() -> Bool {
        switch buildStage {
        case .trivioRound:
            var numFilled = 0
            for category in jCategories {
                numFilled += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
            }
            return numFilled >= jRoundLen
        case .dtRound:
            var numFilled = 0
            for category in djCategories {
                numFilled += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
            }
            return numFilled >= djRoundLen
        case .trivioRoundDD:
            return !jeopardyDailyDoubles.isEmpty
        case .dtRoundDD:
            return (!djDailyDoubles1.isEmpty && !djDailyDoubles2.isEmpty)
        case .details:
            return tags.count >= 2 && !setName.isEmpty
        default:
            return !fjCategory.isEmpty && !fjClue.isEmpty && !fjResponse.isEmpty
        }
    }
    
    func categoryEmpty(category: Category) -> Bool {
        for i in 0..<category.clues.count {
            let clue = category.clues[i]
            let response = category.responses[i]
            if !clue.isEmpty && !response.isEmpty {
                return false
            }
        }
        return true
    }
    
    func stringArrEmpty(stringArr: [String]) -> Bool {
        for string in stringArr {
            if !string.isEmpty {
                return false
            }
        }
        return true
    }
    
    func nextButtonHandler() {
        switch buildStage {
        case .trivioRound:
            buildStage = .trivioRoundDD
        case .trivioRoundDD:
            buildStage = .dtRound
            moneySections = moneySectionsDJ
        case .dtRound:
            buildStage = .dtRoundDD
            isRandomDD = false
        case .dtRoundDD:
            buildStage = .finalTrivio
            currentDisplay = .finalTrivio
        case .finalTrivio:
            buildStage = .details
            currentDisplay = .finishingTouches
        default:
            writeToFirestore() { (success) -> Void in
                self.processPending = true
                if success {
                    self.processPending = false
                    self.buildStage = .trivioRound
                    self.showingBuildView.toggle()
                    self.clearAll()
                }
            }
        }
    }
    
    func addDailyDouble(i: Int, j: Int) {
        switch buildStage {
        case .dtRoundDD:
            if djDailyDoubles1 == [i, j] {
                djDailyDoubles1.removeAll()
            } else if djDailyDoubles2 == [i, j] {
                djDailyDoubles2.removeAll()
            } else {
                if djDailyDoubles1.isEmpty {
                    djDailyDoubles1 = [i, j]
                } else if i != djDailyDoubles1[0] {
                    djDailyDoubles2 = [i, j]
                }
            }
        default:
            jeopardyDailyDoubles = [i, j]
        }
    }
    
    func isDailyDouble(i: Int, j: Int) -> Bool {
        if buildStage == .dtRoundDD {
            return self.djDailyDoubles1 == [i, j] || self.djDailyDoubles2 == [i, j]
        } else if buildStage == .trivioRoundDD {
            return self.jeopardyDailyDoubles == [i, j]
        }
        return false
    }
    
    func addTag() {
        if !tags.contains(tag) {
            tags.append(contentsOf: tag.split(separator: " ").compactMap { String($0) })
        }
        self.tag.removeAll()
    }
    
    func removeTag(tag: String) {
        tags = tags.filter { $0 != tag }
    }
    
    func deleteSet(isDraft: Bool = false, setID: String) {
        db.collection(isDraft ? "drafts" : "userSets").document(setID).getDocument { (doc, error) in
            if error != nil {
                return
            }
            guard let doc = doc else { return }
            guard let customSet = try? doc.data(as: CustomSet.self) else { return }
            for id in customSet.jCategoryIDs {
                self.db.collection("userCategories").document(id).delete()
            }
        }
        db.collection(isDraft ? "drafts" : "userSets").document(setID).delete()
    }
    
    func getKeywords() -> [String] {
        // example title: Jeopardy with host Alex Trebek
        let splitTitle = setName.split(separator: " ")
        
        var keywords = [""]
        
        for i in 0..<splitTitle.count {
            var growingName = ""
            let joinedTitle = Array(splitTitle[i..<splitTitle.count]).joined(separator: " ")
            joinedTitle.forEach { char in
                growingName += String(char).lowercased()
                keywords.append(growingName)
            }
        }
        
        return keywords
    }
    
    func getCategoryNames() -> [String] {
        var names = [String]()
        for i in 0..<jRoundLen {
            let name = jCategories[i].name
            let nameSplit = name.split(separator: " ").compactMap { String($0).uppercased() }
            names.append(contentsOf: nameSplit)
        }
        for i in 0..<djRoundLen {
            let name = djCategories[i].name
            let nameSplit = name.split(separator: " ").compactMap { String($0).uppercased() }
            names.append(contentsOf: nameSplit)
        }
        return names
    }
    
    func setPreviews(clue: String, response: String) {
        self.cluePreview = clue.uppercased()
        self.responsePreview = response.uppercased()
    }
    
    func swap(currentIndex: Int, swapToIndex: Int, categoryIndex: Int) {
        // good old fashioned swapping
        if buildStage == .trivioRound {
            let tempClue = jCategories[categoryIndex].clues[currentIndex]
            let tempResponse = jCategories[categoryIndex].responses[currentIndex]
            jCategories[categoryIndex].clues[currentIndex] = jCategories[categoryIndex].clues[swapToIndex]
            jCategories[categoryIndex].responses[currentIndex] = jCategories[categoryIndex].responses[swapToIndex]
            jCategories[categoryIndex].clues[swapToIndex] = tempClue
            jCategories[categoryIndex].responses[swapToIndex] = tempResponse
        } else {
            let tempClue = djCategories[categoryIndex].clues[currentIndex]
            let tempResponse = djCategories[categoryIndex].responses[currentIndex]
            djCategories[categoryIndex].clues[currentIndex] = djCategories[categoryIndex].clues[swapToIndex]
            djCategories[categoryIndex].responses[currentIndex] = djCategories[categoryIndex].responses[swapToIndex]
            djCategories[categoryIndex].clues[swapToIndex] = tempClue
            djCategories[categoryIndex].responses[swapToIndex] = tempResponse
        }
    }
}

struct Category: Decodable, Hashable, Encodable {
    @DocumentID var id: String?
    var name: String
    var index: Int
    var clues: [String]
    var responses: [String]
    var gameID: String
    // stored as [<index>, <URL>]
    var imageURLs: [Int:String]
    var audioURLs: [Int:String]
    
    mutating func setIndex(index: Int) {
        self.index = index
    }
}

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

struct Empty {
    var customSet = CustomSet(id: "", jCategoryIDs: [], djCategoryIDs: [], categoryNames: [], title: "", titleKeywords: [], fjCategory: "", fjClue: "", fjResponse: "", dateCreated: Date(), jeopardyDailyDoubles: [], djDailyDoubles1: [], djDailyDoubles2: [], userID: "NID", isPublic: false, tags: [], plays: 0, rating: 0, numRatings: 0, numclues: 0, averageScore: 0, jRoundLen: 0, djRoundLen: 0)
    var game = Game(id: "", date: Date(), dj_category_ids: [], dj_dds_1: [], dj_dds_2: [], dj_round_len: 0, fj_category: "", fj_clue: "", fj_response: "", game_id: "", group_index: 0, j_category_ids: [], j_round_len: 0, title: "", type: "", userID: "")
    func category(index: Int, emptyStrings: [String], gameID: String) -> Category {
        return Category(id: UUID().uuidString, name: "", index: index, clues: emptyStrings, responses: emptyStrings, gameID: gameID, imageURLs: [:], audioURLs: [:])
    }
}

enum BuildStage {
    case trivioRound, trivioRoundDD, dtRound, dtRoundDD, finalTrivio, details
}

enum CurrentDisplay {
    case grid, categoryName, clueResponse, finalTrivio, finishingTouches, saveDraft
}
