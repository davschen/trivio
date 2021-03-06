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
    @Published var gameSetupMode: GameSetupMode = .settings
    @Published var gamePhase: GamePhase = .trivio
    @Published var gameplayDisplay: GameplayDisplay = .grid
    
    @Published var gamePreviews = [GamePreview]()
    @Published var seasonFolders = [SeasonFolder]()
    @Published var currentSeason = SeasonFolder(id: "", collection_index: 0, num_games: 0, title: "")
    
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
    @Published var previewViewShowing = false
    @Published var playedGames = [String]()
    @Published var setOffsets = [String:CGFloat]()
    @Published var customSets = [CustomSet]()
    
    @Published var loadingGame = false
    @Published var finalTrivioStage: FinalTrivioStage = .makeWager
    @Published var gameQueryFromType: MenuChoice = .explore
    
    public var currentCategoryIndex = 0
    public var categoryCompletes = [Int](repeating: 0, count: 6)
    public var jCategoryCompletesReference = [Int](repeating: 0, count: 6)
    public var djCategoryCompletesReference = [Int](repeating: 0, count: 6)
    public var jRoundCompletes = 0
    public var djRoundCompletes = 0
    
    public var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }
    
    private var moneySectionsJ = ["200", "400", "600", "800", "1000"]
    private var moneySectionsDJ = ["400", "800", "1200", "1600", "2000"]
    
    public var db = Firestore.firestore()
    public let isVIP = UserDefaults.standard.value(forKey: "isVIP") as? Bool ?? false
    
    init() {
        getSeasons()
        readCustomData()
        if isVIP {
            menuChoice = .gamepicker
            gameQueryFromType = .gamepicker
        } else {
            gameQueryFromType = .explore
        }
    }
    
    func removeAnswer(answer: String) {
        self.usedAnswers = self.usedAnswers.filter { $0 != answer }
    }
    
    // for starting a new game
    func reset() {
        self.gamePhase = .trivio
        self.clues = jeopardyRoundClues
        self.responses = jeopardyRoundResponses
        self.usedAnswers.removeAll()
        self.moneySections = moneySectionsJ
        self.categories = jeopardyCategories
        self.clearCategoryDones()
        self.finalTrivioStage = .notBegun
        self.currentCategoryIndex = 0
    }
    
    func moveOntoDoubleJeopardy() {
        self.gamePhase = .doubleTrivio
        self.usedAnswers = [String]()
        self.clues = doubleJeopardyRoundClues
        self.responses = doubleJeopardyRoundResponses
        self.moneySections = moneySectionsDJ
        self.categories = doubleJeopardyCategories
        self.clearCategoryDones()
        self.currentCategoryIndex = 0
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
    
    // for clearing your selection
    func clearAll() {
        self.jeopardyCategories.removeAll()
        self.doubleJeopardyCategories.removeAll()
        self.usedAnswers.removeAll()
        self.jeopardyRoundClues.removeAll()
        self.doubleJeopardyRoundClues.removeAll()
        self.jeopardyRoundResponses.removeAll()
        self.doubleJeopardyRoundResponses.removeAll()
        self.gamePhase = .trivio
        self.gameSetupMode = .settings
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
        self.queriedUserName.removeAll()
    }
    
    func addToCompletes(colIndex: Int) {
        self.categoryCompletes[colIndex] += 1
    }
    
    func removeFromCompletes(colIndex: Int) {
        self.categoryCompletes[colIndex] -= 1
    }
    
    func categoryDone(colIndex: Int) -> Bool {
        var reference = -1
        if gamePhase == .trivio {
            reference = jCategoryCompletesReference[colIndex]
            return categoryCompletes[colIndex] == reference
        } else if gamePhase == .doubleTrivio {
            reference = djCategoryCompletesReference[colIndex]
            return categoryCompletes[colIndex] == reference
        } else {
            return true
        }
    }
    
    func doneWithRound() -> Bool {
        if gamePhase == .trivio {
            return jRoundCompletes == usedAnswers.count
        } else if gamePhase == .doubleTrivio {
            return djRoundCompletes == usedAnswers.count
        } else {
            return false
        }
    }
    
    func clearCategoryDones() {
        for i in 0..<self.categoryCompletes.count {
            self.categoryCompletes[i] = 0
        }
    }
    
    func gameInProgress() -> Bool {
        if gamePhase == .trivio && usedAnswers.count == 0 {
            return false
        } else {
            return true
        }
    }
}

enum GameSetupMode {
    case settings, participants, play
}

enum GamePhase {
    case trivio, doubleTrivio, finalTrivio
}

enum GameplayDisplay {
    case grid, clue
}
