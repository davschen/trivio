//
//  GamesViewModel+Sets.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/17/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

extension GamesViewModel {
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
