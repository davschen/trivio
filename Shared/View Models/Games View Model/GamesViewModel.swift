//
//  GameViewModel.swift
//  Trivio
//
//  Created by David Chen on 2/3/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class GamesViewModel: ObservableObject {
    @Published var menuChoice: MenuChoice = .explore
    
    @Published var moneySections = ["200", "400", "600", "800", "1000"]
    @Published var isDoubleJeopardy = false
    @Published var wagersMade = false
    
    @Published var gamePreviews = [GamePreview]()
    @Published var seasonFolders = [SeasonFolder]()
    @Published var currentSeason = SeasonFolder(id: "", collection_index: 0, num_games: 0, title: "")
    
    @Published var pullFromCustom = false
    @Published var customSetIDs = [String]()
    @Published var categories = [String]()
    @Published var clues: [[String]] = []
    @Published var responses: [[String]] = []
    
    @Published var jRoundLen = 6
    @Published var djRoundLen = 6
    @Published var jeopardyCategories = [String](repeating: "", count: 6)
    @Published var doubleJeopardyCategories = [String](repeating: "", count: 6)
    @Published var jeopardyDailyDoubles = [Int]()
    @Published var djDailyDoubles1 = [Int]()
    @Published var djDailyDoubles2 = [Int]()
    @Published var jeopardyRoundClues: [[String]] = []
    @Published var doubleJeopardyRoundClues: [[String]] = []
    @Published var jeopardyRoundResponses: [[String]] = []
    @Published var doubleJeopardyRoundResponses: [[String]] = []
    @Published var fjCategory = ""
    @Published var fjClue = ""
    @Published var fjResponse = ""
    
    @Published var selectedSeason = ""
    @Published var selectedEpisode = ""
    @Published var usedAnswers = [String]()
    @Published var timeRemaining: Double = 5
    
    @Published var date = Date()
    @Published var jRoundScores = [String]()
    @Published var djRoundScores = [String]()
    @Published var finalScores = [String]()
    @Published var jTripleStumpers: [[Int]] = []
    @Published var djTripleStumpers: [[Int]] = []
    
    // Following @Published variables will be for custom sets
    @Published var customSet = Empty().customSet
    @Published var rating: Double = 0.0
    @Published var title = ""
    @Published var userID = "NID"
    @Published var queriedUserName = ""
    
    // From profile view
    @Published var menuSelectedItem = "My Sets"
    @Published var previewViewShowing = false
    @Published var playedGames = [String]()
    @Published var setOffsets = [String:CGFloat]()
    @Published var customSets = [CustomSet]()
    
    @Published var loadingGame = false
    
    var categoryCompletes = [Int](repeating: 0, count: 6)
    var jCategoryCompletesReference = [Int](repeating: 0, count: 6)
    var djCategoryCompletesReference = [Int](repeating: 0, count: 6)
    var jRoundCompletes = 0
    var djRoundCompletes = 0
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }
    
    private var moneySectionsJ = ["200", "400", "600", "800", "1000"]
    private var moneySectionsDJ = ["400", "800", "1200", "1600", "2000"]
    public var db = Firestore.firestore()
    private let isVIP = UserDefaults.standard.value(forKey: "isVIP") as? Bool ?? false
    
    init() {
        getSeasons()
        readCustomData() 
        if isVIP {
            menuChoice = .gamepicker
        }
    }
    
    func removeAnswer(answer: String) {
        self.usedAnswers = self.usedAnswers.filter { $0 != answer }
    }
    
    // for starting a new game
    func reset() {
        self.isDoubleJeopardy = false
        self.wagersMade = false
        self.clues = jeopardyRoundClues
        self.responses = jeopardyRoundResponses
        self.usedAnswers = [String]()
        self.moneySections = moneySectionsJ
        self.categories = jeopardyCategories
        self.clearCategoryDones()
    }
    
    func moveOntoDoubleJeopardy() {
        self.isDoubleJeopardy = true
        self.usedAnswers = [String]()
        self.clues = doubleJeopardyRoundClues
        self.responses = doubleJeopardyRoundResponses
        self.moneySections = moneySectionsDJ
        self.categories = doubleJeopardyCategories
        self.clearCategoryDones()
    }
    
    func getSeasons() {
        db.collection("folders").order(by: "collection_index", descending: true).addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            
            DispatchQueue.main.async {
                self.seasonFolders = data.compactMap({ (querySnapshot) -> SeasonFolder? in
                    var folder = try? querySnapshot.data(as: SeasonFolder.self)
                    folder?.setID(id: querySnapshot.documentID)
                    return folder
                })
                if self.isVIP {
                    if let season = self.seasonFolders.first {
                        if let seasonID = season.id {
                            self.getEpisodes(seasonID: seasonID)
                            self.setSeason(folder: season)
                        }
                    }
                }
            }
        }
    }
    
    func setSeason(folder: SeasonFolder) {
        self.selectedSeason = folder.id ?? "NID"
        self.currentSeason = folder
    }
    
    func setEpisode(ep: String) {
        self.selectedEpisode = ep
    }
    
    func getCountdown(second: Int) -> (lower: Int, upper: Int) {
        let highBound = Int(self.timeRemaining * 2)
        if second <= Int(self.timeRemaining) {
            return (second, highBound - second)
        } else {
            return (0, 0)
        }
    }
    
    // Read previews
    func getEpisodes(seasonID: String) {
        db.collection("folders").document(seasonID).collection("games").order(by: "group_index", descending: true).addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            DispatchQueue.main.async {
                self.gamePreviews = data.compactMap { (querySnapshot) -> GamePreview? in
                    var preview = try? querySnapshot.data(as: GamePreview.self)
                    preview?.setID(id: querySnapshot.documentID)
                    return preview
                }
                if let gameID = self.gamePreviews.first?.id {
                    self.getEpisodeData(gameID: gameID)
                    self.setEpisode(ep: gameID)
                    self.previewViewShowing = true
                }
            }
        }
    }
    
    // for clearing your selection
    func clearAll() {
        self.jeopardyCategories.removeAll()
        self.doubleJeopardyCategories.removeAll()
        self.usedAnswers.removeAll()
        self.jeopardyRoundClues.removeAll()
        self.doubleJeopardyRoundClues.removeAll()
        self.jeopardyRoundResponses.removeAll()
        self.doubleJeopardyRoundResponses.removeAll()
        self.isDoubleJeopardy = false
        self.fjClue.removeAll()
        self.fjResponse.removeAll()
        self.jeopardyDailyDoubles.removeAll()
        self.djDailyDoubles1.removeAll()
        self.djDailyDoubles2.removeAll()
        self.jTripleStumpers.removeAll()
        self.djTripleStumpers.removeAll()
        self.date = Date()
        self.customSet = Empty().customSet
        self.jRoundScores.removeAll()
        self.djRoundScores.removeAll()
        self.finalScores.removeAll()
        self.clearCategoryDones()
        self.jCategoryCompletesReference = [Int](repeating: 0, count: 6)
        self.djCategoryCompletesReference = [Int](repeating: 0, count: 6)
        self.jRoundCompletes = 0
        self.djRoundCompletes = 0
    }
    
    func addToCompletes(colIndex: Int) {
        self.categoryCompletes[colIndex] += 1
    }
    
    func removeFromCompletes(colIndex: Int) {
        self.categoryCompletes[colIndex] -= 1
    }
    
    func categoryDone(colIndex: Int) -> Bool {
        return categoryCompletes[colIndex] == (isDoubleJeopardy ? djCategoryCompletesReference[colIndex] : jCategoryCompletesReference[colIndex])
    }
    
    func doneWithRound() -> Bool {
        return (isDoubleJeopardy ? djRoundCompletes : jRoundCompletes) == usedAnswers.count
    }
    
    func clearCategoryDones() {
        for i in 0..<self.categoryCompletes.count {
            self.categoryCompletes[i] = 0
        }
    }
    
    func getEpisodeDataWithCompletion(gameID: String, completion: @escaping (Bool) -> Void) {
        let gameDocRef = db.collection("games").document(gameID)
        clearAll()
        reset()
        gameDocRef.getDocument { (doc, error) in
            let j_category_ids = doc?.get("j_category_ids") as? [String] ?? []
            let dj_category_ids = doc?.get("dj_category_ids") as? [String] ?? []
            let j_round_len = doc?.get("j_round_len") as? Int ?? 0
            let dj_round_len = doc?.get("dj_round_len") as? Int ?? 0
            
            // there are six categories, should be doing stuff for category
            for id in j_category_ids {
                self.db.collection("categories").document(id).getDocument { (doc, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        let index = doc?.get("index") as? Int ?? 0
                        let clues = doc?.get("clues") as? [String] ?? []
                        if self.jeopardyRoundClues.isEmpty {
                            let toAdd = (j_round_len - self.jeopardyRoundClues.count)
                            self.jeopardyRoundClues = [[String]](repeating: [""], count: toAdd)
                            self.jeopardyRoundResponses = [[String]](repeating: [""], count: toAdd)
                            self.jeopardyCategories = [String](repeating: "", count: toAdd)
                        }
                        self.jeopardyRoundClues[index] = doc?.get("clues") as? [String] ?? []
                        self.jeopardyRoundResponses[index] = doc?.get("responses") as? [String] ?? []
                        self.jeopardyCategories[index] = doc?.get("name") as? String ?? ""
                        
                        self.clues = self.jeopardyRoundClues
                        self.responses = self.jeopardyRoundResponses
                        self.categories = self.jeopardyCategories
                        clues.forEach {
                            self.jRoundCompletes += ($0.isEmpty ? 0 : 1)
                            self.jCategoryCompletesReference[index] += ($0.isEmpty ? 0 : 1)
                        }
                    }
                }
            }
            
            for id in dj_category_ids {
                self.db.collection("categories").document(id).getDocument { (doc, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        let index = doc?.get("index") as? Int ?? 0
                        let clues = doc?.get("clues") as? [String] ?? []
                        if self.doubleJeopardyRoundClues.isEmpty {
                            let toAdd = (dj_round_len - self.doubleJeopardyRoundClues.count)
                            self.doubleJeopardyRoundClues = [[String]](repeating: [""], count: toAdd)
                            self.doubleJeopardyRoundResponses = [[String]](repeating: [""], count: toAdd)
                            self.doubleJeopardyCategories = [String](repeating: "", count: toAdd)
                        }
                        self.doubleJeopardyRoundClues[index] = doc?.get("clues") as? [String] ?? []
                        self.doubleJeopardyRoundResponses[index] = doc?.get("responses") as? [String] ?? []
                        self.doubleJeopardyCategories[index] = doc?.get("name") as? String ?? ""
                        clues.forEach {
                            self.djRoundCompletes += ($0.isEmpty ? 0 : 1)
                            self.djCategoryCompletesReference[index] += ($0.isEmpty ? 0 : 1)
                        }
                    }
                }
            }
            
            gameDocRef.collection("j_round_triple_stumpers").addSnapshotListener { (snap, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                guard let data = snap?.documents else { return }
                data.forEach { (queryDocSnap) in
                    let stumper = queryDocSnap.get("stumper") as? [Int] ?? []
                    DispatchQueue.main.async {
                        self.jTripleStumpers.append(stumper)
                    }
                }
            }
            
            gameDocRef.collection("dj_round_triple_stumpers").addSnapshotListener { (snap, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                guard let data = snap?.documents else { return }
                data.forEach { (queryDocSnap) in
                    let stumper = queryDocSnap.get("stumper") as? [Int] ?? []
                    DispatchQueue.main.async {
                        self.djTripleStumpers.append(stumper)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.jeopardyDailyDoubles = doc?.get("j_dds") as? [Int] ?? []
                self.djDailyDoubles1 = doc?.get("dj_dds_1") as? [Int] ?? []
                self.djDailyDoubles2 = doc?.get("dj_dds_2") as? [Int] ?? []
                
                self.fjCategory = doc?.get("fj_category") as? String ?? ""
                self.fjClue = doc?.get("fj_clue") as? String ?? ""
                self.fjResponse = doc?.get("fj_response") as? String ?? ""
                self.title = doc?.get("title") as? String ?? ""
                let ts = doc?.get("date") as? Timestamp ?? Timestamp()
                self.date = ts.dateValue()
                completion(true)
            }
        }
    }
    
    // firestore things
    func getEpisodeData(gameID: String) {
        self.loadingGame = true
        self.getEpisodeDataWithCompletion(gameID: gameID) { (success) in
            if success {
                self.loadingGame = false
            }
        }
    }

    func deleteSet(setID: String) {
        var copyOfCustomSets = customSets
        for i in 0..<customSets.count {
            let set = customSets[i]
            guard let id = set.id else { return }
            if setID == id {
                copyOfCustomSets.remove(at: i)
            }
        }
        customSets = copyOfCustomSets
    }
}

struct GamePreview: Decodable, Hashable, Identifiable {
    @DocumentID var id: String?
    var contestants: String
    var date: Date
    var details: String
    var group_index: Int
    var title: String
    
    enum CodingKeys: String, CodingKey {
        case contestants, date, details, group_index, title
    }
    
    static func == (lhs: GamePreview, rhs: GamePreview) -> Bool {
        lhs.id == rhs.id
    }
    
    mutating func setID(id: String) {
        self.id = id
    }
}

struct SeasonFolder: Decodable, Hashable, Identifiable {
    @DocumentID var id: String?
    var collection_index: Int
    var num_games: Int
    var title: String
    
    enum CodingKeys: String, CodingKey {
        case collection_index, num_games, title
    }
    
    mutating func setID(id: String) {
        self.id = id
    }
}
