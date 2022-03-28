//
//  DailyTrivioViewModel.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 3/22/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class DailyTrivioViewModel: ObservableObject {
    @Published var guessedWord = ""
    @Published var charDict = [String:CharacterOutcome]()
    @Published var attemptedStrings = [String]()
    
    @Published var dtDisplayMode = [DTDisplayMode:Bool]()
    @Published var dtSetStringDict = [DailyTrivioStringValue:String]()
    @Published var myDTStatsDict = [DailyTrivioGameStringValue:String]()
    
    @Published var solved = 0
    @Published var timeAllowed = 60
    @Published var timeElapsed = 0
    @Published var globalGameStats = [GameStat:[Int]]()
    @Published var gameStatus: GameStatus = .notBegun
    @Published var todaysGame: DailyTrivioGame? = nil
    @Published var allGamesToday = [DailyTrivioGame]()
    @Published var todaysSet: DailyTrivioSet? = nil
    
    @Published var username = ""
    @Published var scaleValues = [Float]()
    @Published var opacities = [CGFloat](repeating: 1, count: 10)
    @Published var startEndTimes: (Int64, Int64) = (0, 0)
    
    private var db = Firestore.firestore()
    public var myUID = Auth.auth().currentUser?.uid
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var correctResponse: String {
        return dtSetStringDict[.correctResponse] ?? ""
    }
    
    init() {
        handlePullFromDB()
    }
    
    func addChar(char: String) {
        if guessedWord.count < correctResponse.count {
            guessedWord.append(char)
            scaleValues = [Float](repeating: 1.0, count: correctResponse.count)
            scaleValues[guessedWord.count - 1] = 1.2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scaleValues[self.guessedWord.count - 1] = 1.0
            }
        }
    }
    
    func removeChar() {
        if guessedWord.count > 0 {
            self.guessedWord.removeLast(1)
        }
    }
    
    func enterWord() {
        if guessedWord.count == correctResponse.count {
            for i in 0..<guessedWord.count {
                if guessedWord[i] == correctResponse[i] {
                    charDict[guessedWord[i]] = .correct
                } else if correctResponse.contains(guessedWord[i]) && charDict[guessedWord[i]] != .correct {
                    charDict[guessedWord[i]] = .misplaced
                } else if !charDict.keys.contains(guessedWord[i]) {
                    charDict[guessedWord[i]] = .notInWord
                }
            }
            attemptedStrings.append(guessedWord)
            
            // if solved correctly
            if guessedWord == correctResponse {
                gameStatus = .solved
                solved += 1
                finishWithDelay(2)
                return
            }
            self.guessedWord.removeAll()
        }
    }
    
    func finishWithDelay(_ delay: Double) {
        cancelTimer()
        writeGameToDB()
        startEndTimes.1 = Date().millisecondsSince1970
        let intervalInMilliseconds = Double(startEndTimes.1 - startEndTimes.0)
        let secondsAsDouble = intervalInMilliseconds / 1000.0
        getScore(secondsAsDouble: secondsAsDouble)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.dtDisplayMode[.stats] = true
        }
    }
    
    func toggleStartGame() {
        gameStatus = .ongoing
        startEndTimes.0 = Date().millisecondsSince1970
    }
    
    func toggleShowingInfo() {
        dtDisplayMode[.info]?.toggle()
    }
    
    func toggleShowingStats() {
        dtDisplayMode[.stats]?.toggle()
    }
    
    func guessedWordAtIndex(i: Int) -> String {
        if guessedWord.count > i {
            return guessedWord[i]
        }
        return "@@"
    }
    
    func getKeyColor(char: String) -> Color {
        if gameStatus != .ongoing {
            return MasterHandler().color(.secondaryFG).opacity(0.3)
        }
        
        if charDict.keys.contains(char) {
            // If the letter has been attempted, switch 3 cases
            switch charDict[char] {
            case .correct: return MasterHandler().color(.green)
            case .misplaced: return MasterHandler().color(.yellow)
            default: return MasterHandler().color(.secondaryFG).opacity(0.3)
            }
        } else {
            return MasterHandler().color(.secondaryFG)
        }
    }
    
    func getAttemptCharColor(attemptIndex: Int, charIndex: Int) -> Color {
        var charOutcome: CharacterOutcome = .notInWord
        if attemptedStrings[attemptIndex][charIndex] == correctResponse[charIndex] {
            charOutcome = .correct
        } else if correctResponse.contains(attemptedStrings[attemptIndex][charIndex]) {
            charOutcome = .misplaced
        }
        
        switch charOutcome {
        case .correct: return MasterHandler().color(.green)
        case .misplaced: return MasterHandler().color(.yellow)
        default: return MasterHandler().color(.primaryBG)
        }
    }
}

// MARK: - Read from DB
extension DailyTrivioViewModel {
    
    func handlePullFromDB() {
        // If today's game does not exist, get a new one
        findTodaySourceFromDB { success in
            if !success {
                self.resetValues()
                self.readInNewDTDataFromDB()
            }
        }
    }
    
    /*
     This method assigns all local variables to today's set as stored in DB
     If it cannot find a set from the "triviordleGameSources" collection,
     it pulls a new set from the "triviordleSets" collection, increments
     the "num_chosen" field, and adds it to the "triviordleGameSources"
     collection.
     
     When the function executes, our local variables are guaranteed to be
     updated with information from the DB
     */
    func findTodaySourceFromDB(completion: @escaping (Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let todayDateString = dateFormatter.string(from: Date())
        
        db.collection("triviordleGameSources")
            .order(by: "date", descending: true)
            .limit(to: 1)
            .getDocuments { (snap, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                guard let data = snap?.documents else { return }
                guard let first = data.first else { return }

                guard let dateOfMostRecentDT = first.get("date") as? Timestamp else { return }
                
                let lastDTDateString = dateFormatter.string(from: dateOfMostRecentDT.dateValue())
                
                if todayDateString == lastDTDateString {
                    // if a set w/ today's date exists in the "triviordleGameSources" collection,
                    // update local variables with that set
                    // Then, check if user has completed DT; if so, pull data
                    guard let setID = first.get("dtSetID") as? String else { return }
                    
                    self.db.collection("triviordleSets").document(setID).getDocument { doc, error in
                        if error != nil {
                            print(error!.localizedDescription)
                            return
                        }
                        guard let doc = doc else { return }
                        guard let triviordleSet = try? doc.data(as: DailyTrivioSet.self) else { return }
                        
                        self.updateVariablesWithSetData(todaysSet: triviordleSet)
                        self.readInExistingGameDataFromDB(setID: setID)
                        
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }
    }
    
    func readInNewDTDataFromDB() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let todayDateString = dateFormatter.string(from: Date())
        
        // First, reset anything that needs to be
        // self.resetValues()
        
        // if no set w/ today's date exists, pull a new set from "triviordleSets"
        // add that setID and today's date to "triviordleGameSources"
        self.db.collection("triviordleSets")
            .whereField("num_chosen", isEqualTo: 0)
            .limit(to: 1)
            .getDocuments { (snap, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                guard let data = snap?.documents else { return }
                
                self.todaysSet = data.compactMap({ (queryDocSnap) -> DailyTrivioSet? in
                    let customSet = try! queryDocSnap.data(as: DailyTrivioSet.self)
                    return customSet
                }).first
                
                guard let todaysSet = self.todaysSet else { return }
                guard let todaysSetID = todaysSet.id else { return }
                
                self.updateVariablesWithSetData(todaysSet: todaysSet)
                self.db.collection("triviordleSets").document(todaysSetID).updateData([
                    "num_chosen" : FieldValue.increment(Int64(1))
                ])
                
                // game sources share IDs with game sets
                // this is so that we can access gameSource with our set info
                let gameSource = DailyTrivioGameSource(id: todaysSetID, dateString: todayDateString, dtSetID: todaysSetID)
                guard let gameSourceID = gameSource.id else { return }
                try? self.db.collection("triviordleGameSources").document(gameSourceID).setData(from: gameSource)
        }
    }
    
    func resetValues() {
        self.guessedWord = ""
        self.timeElapsed = 0
        self.attemptedStrings.removeAll()
        self.gameStatus = .notBegun
        self.charDict.removeAll()
        self.opacities = [CGFloat](repeating: 1, count: 10)
    }
    
    // If user has already solved today's DT, set variables accordingly
    // Then, get info on all the games I've ever played
    func readInExistingGameDataFromDB(setID: String) {
        guard let uid = myUID else { return }
        
        db.collection("users")
            .document(uid)
            .collection("triviordleGames")
            .document(setID)
            .getDocument { doc, error in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                guard let doc = doc else { return }
                guard let dtGame = try? doc.data(as: DailyTrivioGame.self) else { return }
                
                self.todaysGame = dtGame
                
                if let todaysGame = self.todaysGame {
                    self.guessedWord = todaysGame.attempts.last ?? ""
                    self.timeElapsed = todaysGame.time
                    self.attemptedStrings = todaysGame.attempts
                    
                    self.dtDisplayMode[.info] = false
                    self.dtDisplayMode[.game] = false
                    self.dtDisplayMode[.stats] = true
                    
                    if todaysGame.correct {
                        self.gameStatus = .solved
                    } else {
                        self.gameStatus = .timedOut
                    }
                }
        }
    }
    
    func updateVariablesWithSetData(todaysSet: DailyTrivioSet) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        guard let id = todaysSet.id else { return }
        self.readInExistingGameDataFromDB(setID: id)
        self.pullGameInfo(dtSetID: id)
        self.pullMyHistorialGameInfo()
        self.todaysSet = todaysSet
        self.dtSetStringDict[.categoryName] = todaysSet.name
        self.dtSetStringDict[.amount] = String(todaysSet.amount)
        
        if let date = self.todaysSet?.date {
            let dateString = dateFormatter.string(from: date)
            self.dtSetStringDict[.date] = dateString
        } else {
            let dateString = dateFormatter.string(from: Date())
            self.dtSetStringDict[.date] = dateString
        }
        
        let correctResponse = todaysSet.response
        
        self.dtSetStringDict[.clue] = todaysSet.clue
        self.dtSetStringDict[.correctResponse] = correctResponse.lowercased()
        self.scaleValues = [Float](repeating: 1.0, count: correctResponse.count)
    }
    
    func pullGameInfo(dtSetID: String) {
        // This pulls ALL times, attempts, and scores from DB
        db.collection("triviordleGameSources").document(dtSetID)
            .collection("allGames")
            .getDocuments { snap, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            let everyGameToday = data.compactMap({ docSnap in
                return try? docSnap.data(as: DailyTrivioGame.self)
            })
            self.globalGameStats[.attempt] = everyGameToday.compactMap({ dtGame in
                return dtGame.attempts.count
            })
            self.globalGameStats[.time] = everyGameToday.compactMap({ dtGame in
                return dtGame.time
            })
            self.globalGameStats[.score] = everyGameToday.compactMap({ dtGame in
                return dtGame.score
            })
        }
        
        // This one takes top 5 scores
        db.collection("triviordleGameSources").document(dtSetID)
            .collection("allGames")
            .limit(to: 5)
            .order(by: "score", descending: true)
            .addSnapshotListener { snap, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            self.allGamesToday = data.compactMap({ docSnap in
                return try? docSnap.data(as: DailyTrivioGame.self)
            })
        }
        getUserInfo()
    }
    
    func pullMyHistorialGameInfo() {
        // Gets info on plays, win %, and streaks
        // This one's kinda clever I like it
        guard let uid = myUID else { return }
        db.collection("users")
            .document(uid)
            .collection("triviordleGames")
            .order(by: "date", descending: true)
            .getDocuments { snap, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            var allMyGames = [DailyTrivioGame]()
            allMyGames = data.compactMap({ docSnap in
                return try? docSnap.data(as: DailyTrivioGame.self)
            })
            // totalWins: array of all past games won
            let totalWins = allMyGames.filter {
                return $0.correct
            }
            let winPercent = Double(totalWins.count * 100) / Double(allMyGames.count)
            var streak = 0
            var prevGame: DailyTrivioGame? = nil
            for dtGame in allMyGames {
                guard let prev = prevGame else {
                    prevGame = dtGame
                    continue
                }
                let prevDate = prev.date
                let currDate = dtGame.date
                let interval = abs(currDate.interval(ofComponent: .day, fromDate: prevDate))
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                
                if interval <= 1 {
                    streak += interval
                } else {
                    break
                }
                prevGame = dtGame
            }
            self.myDTStatsDict[.plays] = String(allMyGames.count)
            self.myDTStatsDict[.winPercent] = String(Int(round(winPercent * 1) / 1.0))
            self.myDTStatsDict[.streak] = String(streak)
        }
    }
    
    func getUserInfo() {
        guard let myUID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(myUID).getDocument { (docSnap, error) in
            if error != nil { return }
            guard let doc = docSnap else { return }
            let username = doc.get("username") as? String ?? ""
            DispatchQueue.main.async {
                self.username = username
            }
        }
    }
}

// MARK: - Writing to DB
extension DailyTrivioViewModel {
    func writeGameToDB() {
        let correct = guessedWord == dtSetStringDict[.correctResponse]
        
        guard let uid = myUID else { return }
        guard let dtSetID = todaysSet?.id else { return }
        guard let dtGame = todaysGame else { return }
        
        self.todaysGame = DailyTrivioGame(attempts: attemptedStrings, time: timeElapsed, score: dtGame.score,
                                          username: self.username, userID: uid, correct: correct)
        
        try? db.collection("triviordleGameSources").document(dtSetID).collection("allGames").document(uid).setData(from: todaysGame)
        try? db.collection("users").document(uid).collection("triviordleGames").document(dtSetID).setData(from: todaysGame)
    }
}

// MARK: - Daily Trivio Timer
extension DailyTrivioViewModel {
    func connectTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    func cancelTimer() {
        self.timer.upstream.connect().cancel()
    }
    
    func incrementTimeElapsed() {
        if gameStatus == .ongoing && timeElapsed < timeAllowed {
            timeElapsed += 1
            if timeElapsed % 2 == 0 {
                MasterHandler().hapticFeedback(style: .rigid, intensity: .weak)
            } else {
                MasterHandler().hapticFeedback(style: .soft, intensity: .weak)
            }
        } else if gameStatus == .ongoing {
            gameStatus = .timedOut
            finishWithDelay(2)
        } else {
            self.cancelTimer()
        }
        getTimeOpacities()
    }
    
    func getTimeOpacities() {
        var opacities = [CGFloat](repeating: 1, count: 10)
        let timeRemaining = timeAllowed - timeElapsed
        let opacityIndexToChange = Int(timeRemaining / 6)
        
        let modValueAtIndex = timeRemaining % 6
        let opacityValueAtIndex = Double(modValueAtIndex) / Double(6)
        opacities[opacityIndexToChange] = CGFloat(opacityValueAtIndex)
        for i in 0..<opacities.count {
            let indexToCheck = opacities.count - i - 1
            if indexToCheck > opacityIndexToChange {
                opacities[indexToCheck] = 0
            }
        }
        self.opacities = opacities
    }
}

// MARK: - Getting stats and metrics
extension DailyTrivioViewModel {
    // score based on correctness, time, attempts
    func getScore(secondsAsDouble: Double) {
        let correctAnswer = dtSetStringDict[.correctResponse] ?? ""
        let attempts = Double(attemptedStrings.count)
        let seconds = Double(timeElapsed)
        
        if guessedWord.count < correctAnswer.count && attemptedStrings.count > 0 {
            guessedWord = attemptedStrings.last ?? ""
        }
        
        if guessedWord.count != correctAnswer.count || attemptedStrings.count == 0 {
            todaysGame?.score = 0
        }
        
        var letterPlacement: Double = 0
        for i in 0..<correctAnswer.count {
            if guessedWord[i] == correctAnswer[i] {
                letterPlacement += 1
            } else if correctAnswer.contains(guessedWord[i]) {
                letterPlacement += 0.5
            }
        }
        
        let correctness = letterPlacement / Double(correctAnswer.count)
        let attemptRatio = 1.0 / Double(log(attempts) * 0.1 + 1)
        let secondsRatio = 1.0 / Double(log(seconds) * 0.05 + 1)
        
        let score: Double = 5000.0 * correctness * attemptRatio * secondsRatio
        let roundedScore = round(score * 100) / 100.0
        
        todaysGame?.score = Int(roundedScore)
    }
    
    //  for MobileDTFinishedView -- attempts chart
    func getAttemptBarChartHeights(fixedHeight: Double = 25) -> ([Int], [CGFloat]) {
        var attemptCounts = [Int](repeating: 0, count: 10)
        var heights = [CGFloat]()
        var percents = [Int]()
        
        for n in globalGameStats[.attempt] ?? [] {
            let attemptIndex = n - 1
            if attemptIndex < 10 {
                attemptCounts[attemptIndex] += 1
            }
        }
        
        let totalCount = attemptCounts.reduce(0, +)
        let maxCount = attemptCounts.max() ?? 1
        
        for count in attemptCounts {
            let percent = Int((Double(count * 100)) / Double(totalCount))
            let height = Float((Double(count) * fixedHeight) / Double(maxCount))
            percents.append(percent)
            heights.append(CGFloat(height))
        }
        
        return (percents, heights)
    }
    
    //  for MobileDTFinishedView -- attempts chart
    func getTimesBarChartHeights(fixedHeight: Double = 25) -> ([Int], [CGFloat]) {
        if todaysGame == nil {
            return ([Int](repeating: 0, count: 10), [CGFloat](repeating: 0, count: 10))
        }
        
        var timeCounts = [Int](repeating: 0, count: 10)
        var heights = [CGFloat]()
        var percents = [Int]()
        
        for time in globalGameStats[.time] ?? [] {
            var timeRemaining = timeAllowed - time
            if timeRemaining % 6 == 0 {
                timeRemaining -= 1
            }
            let binIndex = Int(timeRemaining / 6)
            timeCounts[binIndex] += 1
        }
        
        let totalCount = timeCounts.reduce(0, +)
        let maxCount = timeCounts.max() ?? 1
        
        for count in timeCounts {
            let percent = Int((Double(count * 100)) / Double(totalCount))
            let height = Float((Double(count) * fixedHeight) / Double(maxCount))
            percents.append(percent)
            heights.append(CGFloat(height))
        }
        
        return (percents, heights)
    }
    
    func getAverageAttempts() -> Double {
        if let attempts = globalGameStats[.attempt] {
            let totalAttempts = Double(attempts.reduce(0, +))
            let averageAttempts = Double(totalAttempts / Double(attempts.count))
            return round(averageAttempts * 100) / 100.0
        } else {
            return 0.0
        }
    }
    
    func getAverageSeconds() -> Double {
        if let times = globalGameStats[.time] {
            let totalTimes = Double(times.reduce(0, +))
            let averageTimes = Double(totalTimes / Double(times.count))
            return round(averageTimes * 100) / 100.0
        } else {
            return 0.0
        }
    }
}

enum CharacterOutcome {
    case notInWord, misplaced, correct
}

enum DailyTrivioStringValue {
    case categoryName, amount, date, clue, correctResponse
}

enum DailyTrivioGameStringValue {
    case plays, winPercent, streak
}

enum DTDisplayMode {
    case game, info, stats
}

enum GameStat {
    case attempt, time, score
}

enum GameStatus {
    case notBegun, ongoing, solved, timedOut
}
