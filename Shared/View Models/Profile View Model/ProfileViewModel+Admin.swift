//
//  ProfileViewModel+Admin.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/24/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

extension ProfileViewModel {
    func fetchCluesToReview() {
        let db = Firestore.firestore()
        db.collection("triviaDecks").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents from triviaDecks: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var fetchedClues: [TriviaDeckClue] = []
            
            let group = DispatchGroup()
            
            for document in documents {
                group.enter()
                let triviaDeckID = document.documentID
                db.collection("triviaDecks")
                    .document(triviaDeckID)
                    .collection("triviaDeckClues")
                    .whereField("needsAdminReview", isEqualTo: true)
                    .getDocuments { cluesSnapshot, cluesError in
                    guard let clues = cluesSnapshot?.documents else {
                        print("Error fetching clues from \(triviaDeckID): \(cluesError?.localizedDescription ?? "Unknown error")")
                        group.leave()
                        return
                    }
                    
                    for clue in clues {
                        if let triviaDeckClue = try? clue.data(as: TriviaDeckClue.self) {
                            fetchedClues.append(triviaDeckClue)
                        } else {
                            print("Error decoding TriviaDeckClue from document data")
                        }
                    }
                    
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.triviaDeckCluesToReview = fetchedClues
            }
        }
    }
    
    private func kebabCase(from title: String) -> String {
        let lowercaseTitle = title.lowercased()
        let kebabCaseTitle = lowercaseTitle.replacingOccurrences(of: " ", with: "-")
        return kebabCaseTitle
    }
    
    public func approveTriviaDeckClue(triviaDeckClue: TriviaDeckClue) {
        let triviaDeckDocId = kebabCase(from: triviaDeckClue.triviaDeckTitle)
        let triviaDeckRef = db.collection("triviaDecks").document(triviaDeckDocId)
        if let triviaDeckClueId = triviaDeckClue.id {
            triviaDeckRef.collection("triviaDeckClues").document(triviaDeckClueId).setData([
                "isAdminApproved" : true,
                "needsAdminReview" : false,
                "releasedDate" : Date(),
            ], merge: true)
        } else {
            print("Error approving trivia deck clue")
            return
        }
        triviaDeckCluesToReview.removeAll(where: { $0.id == triviaDeckClue.id })
    }
    
    public func rejectTriviaDeckClue(triviaDeckClue: TriviaDeckClue, rejectionNote: String) {
        let triviaDeckDocId = kebabCase(from: triviaDeckClue.triviaDeckTitle)
        let triviaDeckRef = db.collection("triviaDecks").document(triviaDeckDocId)
        if let triviaDeckClueId = triviaDeckClue.id {
            triviaDeckRef.collection("triviaDeckClues").document(triviaDeckClueId).setData([
                "needsAdminReview" : false,
                "adminFeedback" : rejectionNote,
            ], merge: true)
        } else {
            print("Error approving trivia deck clue")
            return
        }
        triviaDeckCluesToReview.removeAll(where: { $0.id == triviaDeckClue.id })
    }
}
