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
    @Published var buildStage: BuildStage = .details
    @Published var buildPhaseType: BuildPhaseType = .rounds1and2
    @Published var currentDisplay: CurrentDisplay = .settings
    @Published var currCustomSet = CustomSetCherry()

    @Published var moneySections = ["", "", "", "", ""]
    
    @Published var isPreviewDisplayModern = true
    @Published var mostAdvancedStage: BuildStage = .details
    @Published var gameID = ""
    @Published var isPublic = true
    @Published var tag = ""
    @Published var categories = [CustomSetCategory]()
    @Published var jCategories = [CustomSetCategory]()
    @Published var djCategories = [CustomSetCategory]()
    @Published var isRandomDD = false
    
    @Published var dirtyBit = 0
    @Published var editingClueIndex = 0
    @Published var choosingDailyDoubles = false
    @Published var round1CatsShowing = [Bool]()
    @Published var round2CatsShowing = [Bool]()
    
    @Published var cluePreview = ""
    @Published var responsePreview = ""
    @Published var processPending = false
    @Published var showingBuildView = false
    
    public var editingCategoryIndex = 0
    
    private var moneySectionsJ = ["200", "400", "600", "800", "1000"]
    private var moneySectionsDJ = ["400", "800", "1200", "1600", "2000"]
    private var db = Firestore.firestore()
    private var emptyStrings = ["", "", "", "", ""]
    private var myUID = Auth.auth().currentUser?.uid ?? "no_one"
    
    init() {
        self.fillBlanks()
    }
    
    func clearAll() {
        self.categories.removeAll()
        self.jCategories.removeAll()
        self.djCategories.removeAll()
        self.currCustomSet = CustomSetCherry()
        
        self.isRandomDD = false
        self.editingClueIndex = 0
        self.round1CatsShowing.removeAll()
        self.round2CatsShowing.removeAll()
        self.gameID = UUID().uuidString
        self.moneySections = moneySectionsDJ
        self.fillBlanks()
        
        self.buildStage = .trivioRound
        self.mostAdvancedStage = .details
        self.currentDisplay = .grid
    }
    
    func writeToFirestore(completion: @escaping (Bool) -> Void) {
        let docRef = db.collection(self.currCustomSet.isDraft ? "drafts" : "userSets").document(gameID)
        currCustomSet.dateLastModified = Date()
        docRef.getDocument { (doc, error) in
            if error != nil { return }
            DispatchQueue.main.async {
                try? docRef.setData(from: self.currCustomSet)
                self.writeCategories()
                self.updateTagsDB()
                self.dirtyBit = 0
                if !self.currCustomSet.isDraft {
                    self.db.collection("drafts").document(self.gameID).delete()
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
    
    func edit(gameID: String) {
        self.showingBuildView.toggle()
        self.gameID = gameID
        self.jCategories.removeAll()
        self.djCategories.removeAll()
        let docRef = db.collection(currCustomSet.isDraft ? "drafts" : "userSets").document(gameID)
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
                
                self.categories = self.jCategories
                self.isRandomDD = true
                self.editingClueIndex = 0
                self.round1CatsShowing = [Bool](repeating: true, count: 6)
                self.round2CatsShowing = [Bool](repeating: true, count: 6)
            }
        }
    }
    
    func saveDraft(isExiting: Bool = false) {
        writeToFirestore() { (success) in
            self.processPending = true
            if success {
                self.processPending = false
                self.buildStage = .trivioRound
                if isExiting {
                    self.showingBuildView.toggle()
                }
            }
        }
    }
    
    func getCategoryIDs(isDJ: Bool) -> [String] {
        var IDs = [String]()
        for i in 0..<(isDJ ? currCustomSet.round2Len : currCustomSet.round2Len) {
            let category = isDJ ? djCategories[i] : jCategories[i]
            if let id = category.id {
                IDs.append(id)
            }
        }
        return IDs
    }
    
    func fillBlanks() {
        for i in 0..<self.currCustomSet.round1Len {
            self.jCategories.append(Empty().category(index: i, emptyStrings: emptyStrings, gameID: gameID))
            round1CatsShowing.append(true)
        }
        for i in 0..<self.currCustomSet.round2Len {
            self.djCategories.append(Empty().category(index: i, emptyStrings: emptyStrings, gameID: gameID))
            round2CatsShowing.append(true)
        }
        gameID = UUID().uuidString
        moneySections = moneySectionsJ
        buildStage = .details
    }
    
    func start() {
        clearAll()
        showingBuildView.toggle()
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
                }
            }
        }
    }
    
    func addCategoryRound1() {
        if self.currCustomSet.round1Len == 6 { return }
        self.currCustomSet.round1Len += 1
        round1CatsShowing[currCustomSet.round1Len - 1] = true
        if jCategories.count <= currCustomSet.round1Len {
            self.jCategories.append(Empty().category(index: currCustomSet.round1Len - 1, emptyStrings: emptyStrings, gameID: gameID))
        }
    }
    
    func addCategoryRound2() {
        if self.currCustomSet.round2Len == 6 { return }
        self.currCustomSet.round2Len += 1
        round2CatsShowing[currCustomSet.round2Len - 1] = true
        if djCategories.count <= currCustomSet.round2Len {
            self.jCategories.append(Empty().category(index: currCustomSet.round2Len - 1, emptyStrings: emptyStrings, gameID: gameID))
        }
    }
    
    func addCategory() {
        if buildStage == .trivioRound {
            addCategoryRound1()
        } else if buildStage == .dtRound {
            addCategoryRound2()
        }
    }
    
    func subtractCategoryRound1() {
        if currCustomSet.round1Len == 3 { return }
        currCustomSet.round1Len -= 1
        round1CatsShowing[currCustomSet.round1Len] = false
    }
    
    func subtractCategoryRound2() {
        if currCustomSet.round2Len == 3 { return }
        currCustomSet.round2Len -= 1
        round2CatsShowing[currCustomSet.round2Len] = false
    }
    
    func subtractCategory() {
        if buildStage == .trivioRound {
            subtractCategoryRound1()
        } else if buildStage == .dtRound {
            subtractCategoryRound2()
        }
    }
    
    func getNumClues() -> Int {
        var numClues = 0
        for i in 0..<currCustomSet.round1Len {
            let clues = jCategories[i].clues
            let responses = jCategories[i].responses
            for j in 0..<emptyStrings.count {
                if !clues[j].isEmpty && !responses[j].isEmpty {
                    numClues += 1
                }
            }
        }
        for i in 0..<currCustomSet.round2Len {
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
            self.currCustomSet.roundOneDaily.removeAll()
        } else if buildStage == .dtRoundDD {
            self.currCustomSet.roundTwoDaily1.removeAll()
            self.currCustomSet.roundTwoDaily2.removeAll()
        }
    }
    
    func randomDDs() {
        clearDailyDoubles()
        if buildStage == .trivioRoundDD {
            while self.currCustomSet.roundOneDaily.isEmpty {
                let randCol = Int.random(in: 0..<currCustomSet.round1Len)
                let randRow = Int.random(in: 0..<5)

                if !(self.jCategories[randCol].clues[randRow].isEmpty && self.jCategories[randCol].responses[randRow].isEmpty) {
                    self.currCustomSet.roundOneDaily = [randCol, randRow]
                }
            }
        } else if buildStage == .dtRoundDD {
            while self.currCustomSet.roundTwoDaily1.isEmpty || self.currCustomSet.roundTwoDaily2.isEmpty {
                let randCol = Int.random(in: 0..<currCustomSet.round2Len)
                let randRow = Int.random(in: 0..<5)
                if self.currCustomSet.roundTwoDaily1.isEmpty {
                    if !self.djCategories[randCol].clues[randRow].isEmpty {
                        self.currCustomSet.roundTwoDaily1 = [randCol, randRow]
                    }
                } else if self.currCustomSet.roundTwoDaily2.isEmpty {
                    if !self.djCategories[randCol].clues[randRow].isEmpty
                        && self.currCustomSet.roundTwoDaily1[0] != randCol {
                        self.currCustomSet.roundTwoDaily2 = [randCol, randRow]
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
            return !currCustomSet.roundTwoDaily1.isEmpty && !currCustomSet.roundTwoDaily2.isEmpty
        default:
            return !currCustomSet.roundOneDaily.isEmpty
        }
    }
    
    func setEditingIndex(index: Int) {
        self.editingClueIndex = index
    }
    
    func stepStringHandler() -> String {
        var stepString = ""
        switch buildStage {
        case .trivioRound:
            stepString = "Trivio! Round"
        case .trivioRoundDD:
            stepString = "Trivio! Round Duplexes"
        case .dtRound:
            stepString = "Double Trivio! Round"
        case .dtRoundDD:
            stepString = "Double Trivio! Round Duplexes"
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
        case .trivioRound:
            buildStage = .details
            currentDisplay = .settings
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
            if currCustomSet.hasTwoRounds {
                buildStage = .dtRoundDD
            } else {
                buildStage = .trivioRoundDD
            }
            currentDisplay = .grid
        default:
            buildStage = .finalTrivio
            currentDisplay = .finalTrivio
        }
    }
    
    func rectifyNextProhibited() {
        // Can't get this to work, but it's supposed to reconsider mostAdvancedStage
//        mostAdvancedStage = buildStage
    }
    
    func checkForSetIsComplete() -> Bool {
        var round1FilledCount = 0
        var round2FilledCount = 0
        for category in jCategories {
            round1FilledCount += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
        }
        for category in djCategories {
            round2FilledCount += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
        }
        
        let detailsCheck = !currCustomSet.tags.isEmpty && !currCustomSet.title.isEmpty
        let trivioRoundCheck = round1FilledCount >= currCustomSet.round1Len
        let dtRoundCheck = round2FilledCount >= currCustomSet.round2Len
        let roundOneDailyCheck = !currCustomSet.roundOneDaily.isEmpty
        let roundTwoDailyCheck = !currCustomSet.roundTwoDaily1.isEmpty && !currCustomSet.roundTwoDaily2.isEmpty
        let finalCheck = !currCustomSet.finalCat.isEmpty && !currCustomSet.finalClue.isEmpty && !currCustomSet.finalResponse.isEmpty
        
        return detailsCheck && trivioRoundCheck && dtRoundCheck && roundOneDailyCheck && roundTwoDailyCheck && finalCheck
    }
    
    func nextPermitted() -> Bool {
        switch buildStage {
        case .details:
            if currCustomSet.tags.isEmpty || currCustomSet.title.isEmpty {
                rectifyNextProhibited()
            }
            return !currCustomSet.tags.isEmpty && !currCustomSet.title.isEmpty
        case .trivioRound:
            var numFilled = 0
            for category in jCategories {
                numFilled += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
            }
            if numFilled < currCustomSet.round1Len {
                rectifyNextProhibited()
            }
            return numFilled >= currCustomSet.round1Len
        case .dtRound:
            var numFilled = 0
            for category in djCategories {
                numFilled += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
            }
            if numFilled < currCustomSet.round2Len {
                rectifyNextProhibited()
            }
            return numFilled >= currCustomSet.round2Len
        case .trivioRoundDD:
            if currCustomSet.roundOneDaily.isEmpty {
                rectifyNextProhibited()
            }
            return !currCustomSet.roundOneDaily.isEmpty
        case .dtRoundDD:
            if (currCustomSet.roundTwoDaily1.isEmpty  || currCustomSet.roundTwoDaily2.isEmpty) {
                rectifyNextProhibited()
            }
            return (!currCustomSet.roundTwoDaily1.isEmpty && !currCustomSet.roundTwoDaily2.isEmpty)
        default:
            if currCustomSet.finalCat.isEmpty || currCustomSet.finalClue.isEmpty || currCustomSet.finalResponse.isEmpty {
                rectifyNextProhibited()
            }
            return checkForSetIsComplete()
        }
    }
    
    func categoryEmpty(category: CustomSetCategory) -> Bool {
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
    
    public func changePointValues(isAdvancing: Bool) {
        moneySections = isAdvancing ? moneySectionsDJ : moneySectionsJ
    }
    
    func nextButtonHandler() {
        let buildStageIndexDict = MobileBuildStageIndexDict()
        let buildStageIndex = buildStageIndexDict.getIndex(from: buildStage)
        let mostAdvancedStageIndex = buildStageIndexDict.getIndex(from: mostAdvancedStage)
        
        currCustomSet.isDraft = !checkForSetIsComplete()
        
        switch buildStage {
        case .details:
            buildStage = .trivioRound
            currentDisplay = .grid
            editingCategoryIndex = 0
        case .trivioRound:
            buildStage = .trivioRoundDD
            currentDisplay = .grid
            editingCategoryIndex = 0
        case .trivioRoundDD:
            if currCustomSet.hasTwoRounds {
                buildStage = .dtRound
                changePointValues(isAdvancing: true)
            } else {
                buildStage = .finalTrivio
                currentDisplay = .finalTrivio
            }
        case .dtRound:
            buildStage = .dtRoundDD
            isRandomDD = false
            currentDisplay = .grid
            editingCategoryIndex = 0
        case .dtRoundDD:
            buildStage = .finalTrivio
            currentDisplay = .finalTrivio
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
        if mostAdvancedStageIndex <= buildStageIndex {
            mostAdvancedStage = buildStage
        }
    }
    
    func addDailyDouble(i: Int, j: Int) {
        switch buildStage {
        case .dtRoundDD:
            if currCustomSet.roundTwoDaily1 == [i, j] {
                currCustomSet.roundTwoDaily1.removeAll()
            } else if currCustomSet.roundTwoDaily2 == [i, j] {
                currCustomSet.roundTwoDaily2.removeAll()
            } else {
                if currCustomSet.roundTwoDaily1.isEmpty {
                    currCustomSet.roundTwoDaily1 = [i, j]
                } else if i != currCustomSet.roundTwoDaily1[0] {
                    currCustomSet.roundTwoDaily2 = [i, j]
                }
            }
        default:
            currCustomSet.roundOneDaily = [i, j]
        }
    }
    
    func isDailyDouble(i: Int, j: Int) -> Bool {
        if buildStage == .dtRoundDD {
            return self.currCustomSet.roundTwoDaily1 == [i, j] || self.currCustomSet.roundTwoDaily2 == [i, j]
        } else if buildStage == .trivioRoundDD {
            return self.currCustomSet.roundOneDaily == [i, j]
        }
        return false
    }
    
    func addTag() {
        if !currCustomSet.tags.contains(tag) {
            currCustomSet.tags.append(contentsOf: tag.split(separator: " ").compactMap { String($0) })
        }
        self.tag.removeAll()
    }
    
    func removeTag(tag: String) {
        currCustomSet.tags = currCustomSet.tags.filter { $0 != tag }
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
        let splitTitle = currCustomSet.title.split(separator: " ")
        
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
        for i in 0..<currCustomSet.round1Len {
            let name = jCategories[i].name
            let nameSplit = name.split(separator: " ").compactMap { String($0).uppercased() }
            names.append(contentsOf: nameSplit)
        }
        for i in 0..<currCustomSet.round2Len {
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

struct MobileBuildStageIndexDict {
    var dict: [BuildStage:Int] = [
        .details: 0,
        .trivioRound: 1,
        .trivioRoundDD: 2,
        .dtRound: 3,
        .dtRoundDD: 4,
        .finalTrivio: 5
    ]
    
    func getIndex(from buildStage: BuildStage) -> Int {
        return dict[buildStage] ?? 0
    }
}

struct Empty {
    var customSet = CustomSet(id: "", jCategoryIDs: [], djCategoryIDs: [], categoryNames: [], title: "", titleKeywords: [], fjCategory: "", fjClue: "", fjResponse: "", dateCreated: Date(), jeopardyDailyDoubles: [], djDailyDoubles1: [], djDailyDoubles2: [], userID: "NID", isPublic: false, tags: [], plays: 0, rating: 0, numRatings: 0, numclues: 0, averageScore: 0, jRoundLen: 0, djRoundLen: 0)
    
    var game = Game(id: "", date: Date(), dj_category_ids: [], dj_dds_1: [], dj_dds_2: [], dj_round_len: 0, fj_category: "", fj_clue: "", fj_response: "", game_id: "", group_index: 0, j_category_ids: [], j_round_len: 0, title: "", type: "", userID: "")
    var team = Team(id: UUID().uuidString, index: 0, name: "", members: [], score: 0, color: "blue")
    func category(index: Int, emptyStrings: [String], gameID: String) -> CustomSetCategory {
        return CustomSetCategory(id: UUID().uuidString, name: "", index: index, clues: emptyStrings, responses: emptyStrings, gameID: gameID, imageURLs: [:], audioURLs: [:])
    }
}

enum BuildStage {
    case details, trivioRound, trivioRoundDD, dtRound, dtRoundDD, finalTrivio
}

enum CurrentDisplay {
    case grid, buildAll, finalTrivio, settings, saveDraft
}
