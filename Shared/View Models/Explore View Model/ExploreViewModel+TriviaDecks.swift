//
//  ExploreViewModel+TriviaDecks.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/22/23.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

extension ExploreViewModel {
    public func fetchTriviaDeckInfo() {
        fetchTriviaDecks()
        fetchAllPlayedTriviaDeckClues()
    }
    
    public func fetchTriviaDecks() {
        db.collection("triviaDecks")
            .order(by: "title", descending: true)
            .getDocuments { (snap, error) in
            if error != nil {
                print(error!)
                return
            }
            guard let documents = snap?.documents else { return }
            self.allTriviaDecks = documents.compactMap({ (queryDocSnap) -> TriviaDeck? in
                let triviaDeck = try? queryDocSnap.data(as: TriviaDeck.self)
                return triviaDeck
            })
        }
    }
    
    public func setCurrentTriviaDeck(triviaDeck: TriviaDeck) {
        currentTriviaDeck = triviaDeck
        setCurrentAndNextTriviaDeckClues()
    }
    
    public func fetchAllPlayedTriviaDeckClues() {
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        let myProfileDocRef = db.collection("users").document(myUID)
        myProfileDocRef.collection("playedTriviaDeckClues").getDocuments { (snap, error) in
            if error != nil { return }
            guard let data = snap?.documents else { return }
            self.allPlayedTriviaDeckClues = data.compactMap({ (queryDocSnap) -> PlayedTriviaDeckClueLog? in
                let log = try? queryDocSnap.data(as: PlayedTriviaDeckClueLog.self)
                return log
            })
        }
    }
    
    public func fetchUnplayedClue(after: DocumentSnapshot? = nil, completion: @escaping (TriviaDeckClue?, DocumentSnapshot?) -> Void) {
        guard let currentTriviaDeckId = currentTriviaDeck.id else {
            completion(nil, nil)
            return
        }
        let currentTDRef = db.collection("triviaDecks").document(currentTriviaDeckId).collection("triviaDeckClues")
        
        var query = currentTDRef
            .order(by: "totalSubmissions", descending: true)
            .limit(to: 1)
        
        if let afterDoc = after {
            query = query.start(afterDocument: afterDoc)
        }
        
        query.getDocuments { (snap, error) in
            if let error = error {
                print("Error fetching clue: \(error)")
                completion(nil, nil)
                return
            }
            guard let docs = snap?.documents else {
                completion(nil, nil)
                return
            }
            
            if let firstDoc = docs.first, let clue = try? firstDoc.data(as: TriviaDeckClue.self), clue.isAdminApproved {
                let cluePath = "triviaDecks/\(currentTriviaDeckId)/triviaDeckClues/\(firstDoc.documentID)"
                
                let playedCluePaths = self.allPlayedTriviaDeckClues.map { $0.triviaDeckPath }
                if !playedCluePaths.contains(cluePath) {
                    completion(clue, firstDoc)
                } else {
                    self.fetchUnplayedClue(after: firstDoc, completion: completion)
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    
    public func setCurrentAndNextTriviaDeckClues() {
        triviaDeckClueViewState.triviaDeckDisplayMode = .triviaDeckClue
        fetchUnplayedClue(after: nil) { (newCurrentClue, newCurrentClueDoc) in
            if let newCurrentClue = newCurrentClue {
                self.currentTriviaDeckClue = newCurrentClue
                
                // Fetch the nextTriviaDeckClue
                self.fetchUnplayedClue(after: newCurrentClueDoc) { (newNextClue, newNextClueDoc) in
                    if let newNextClue = newNextClue {
                        self.nextTriviaDeckClue = newNextClue
                        self.nextTriviaDeckClueDocumentSnapshot = newNextClueDoc
                    }
                }
            }
        }
    }
    
    public func advanceNextTriviaDeckClue(secondsFloat: Float, numAttempts: Int) {
        // Mark the previous one as played
        let justPlayedClue = currentTriviaDeckClue
        currentTriviaDeckClue = nextTriviaDeckClue
        
        // Set the nextTriviaDeckClue to one that has not been played _and_ is not the currentTriviaDeckClue
        fetchUnplayedClue(after: nextTriviaDeckClueDocumentSnapshot) { (newNextClue, newNextClueDoc) in
            if let newNextClue = newNextClue {
                self.nextTriviaDeckClue = newNextClue
                self.nextTriviaDeckClueDocumentSnapshot = newNextClueDoc
            } else {
                self.currentTriviaDeckClue = TriviaDeckClue()
            }
        }
        
        guard let myUID = FirebaseConfigurator.shared.auth.currentUser?.uid else { return }
        let myProfileDocRef = db.collection("users").document(myUID)
        let playedDeckClueDocRef = myProfileDocRef.collection("playedTriviaDeckClues").document()
        let triviaDeckDocId = kebabCase(from: justPlayedClue.triviaDeckTitle)
        if let justPlayedClueId = justPlayedClue.id {
            let triviaDeckPath = "triviaDecks/\(triviaDeckDocId)/triviaDeckClues/\(justPlayedClueId)"
            self.incrementTDSubmissions(clue: justPlayedClue, secondsBin: Int(floor(secondsFloat)), attemptsBin: numAttempts - 1)
            let playedClueLog = PlayedTriviaDeckClueLog(triviaDeckPath: triviaDeckPath, secondsFloat: secondsFloat, numAttempts: numAttempts, datePlayed: Date())
            try? playedDeckClueDocRef.setData(from: playedClueLog)
            self.allPlayedTriviaDeckClues.append(playedClueLog)
        }
    }
    
    public func incrementTDSubmissions(clue: TriviaDeckClue, correctSubmission: Bool = true, secondsBin: Int = 0, attemptsBin: Int = 0) {
        // Increment the number of attempts
        triviaDeckClueViewState.currentClueNumAttempts += 1
        
        guard let clueId = clue.id else { return }
        let triviaDeckDocId = kebabCase(from: clue.triviaDeckTitle)
        let triviaDeckRef = db.collection("triviaDecks/\(triviaDeckDocId)/triviaDeckClues").document(clueId)

        triviaDeckRef.getDocument { (document, error) in
            if let document = document, document.exists {
                triviaDeckRef.setData([
                    "totalSubmissions": FieldValue.increment(Int64(1)),
                ], merge: true)

                if correctSubmission {
                    var secondsCountsBins = document.get("secondsCountsBins") as? [Int] ?? Array(repeating: 0, count: 61)
                    var attemptsCountsBins = document.get("attemptsCountsBins") as? [Int] ?? Array(repeating: 0, count: 11)

                    secondsCountsBins[min(secondsBin, 60)] += 1
                    attemptsCountsBins[min(attemptsBin, 10)] += 1
                    
                    triviaDeckRef.setData([
                        "correctSubmissions": FieldValue.increment(Int64(1)),
                        "secondsCountsBins": secondsCountsBins,
                        "attemptsCountsBins": attemptsCountsBins,
                    ], merge: true)
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func kebabCase(from title: String) -> String {
        let lowercaseTitle = title.lowercased()
        let kebabCaseTitle = lowercaseTitle.replacingOccurrences(of: " ", with: "-")
        return kebabCaseTitle
    }
    
    public func submitTriviaDeckClue(triviaDeckClue: TriviaDeckClue, authorID: String?, authorUsername: String) {
        guard let authorID = authorID else { return }
        
        var mutatedTriviaDeckClue = triviaDeckClue
        mutatedTriviaDeckClue.setCategory(newCategory: self.currentTriviaDeckClue.category)
        mutatedTriviaDeckClue.authorID = authorID
        mutatedTriviaDeckClue.authorUsername = authorUsername
        mutatedTriviaDeckClue.triviaDeckTitle = self.currentTriviaDeck.title
        
        do {
            let encodedTriviaDeckClue = try Firestore.Encoder().encode(mutatedTriviaDeckClue)
            db.collection("triviaDecks").document(kebabCase(from: currentTriviaDeck.title)).collection("triviaDeckClues").addDocument(data: encodedTriviaDeckClue)
        } catch let error {
            print("Error adding document: \(error.localizedDescription)")
        }
    }
}
