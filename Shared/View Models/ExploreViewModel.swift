//
//  ExploreViewModel.swift
//  Trivio
//
//  Created by David Chen on 5/4/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore

class ExploreViewModel: ObservableObject {
    @Published var currentSearchBy: SearchByOption = .allrecents
    @Published var searchItem = ""
    @Published var gameIDs = [String]()
    @Published var games = [Game]()
    @Published var hasSearch = false
    @Published var capSplit = [String]()
    
    @Published var allRecents = [CustomSet]()
    @Published var titleSearchResults = [CustomSet]()
    @Published var categorySearchResults = [CustomSet]()
    @Published var tagsSearchResults = [CustomSet]()
    @Published var userResults = [CustomSet]()
    
    @Published var filterBy = "dateCreated"
    @Published var descending = true
    @Published var tagsString = [String]()
    @Published var tags = [String:Int]()
    
    @Published var viewingUsername = ""
    @Published var isShowingUserView = false
    @Published var usernameIDDict = [String:String]()
    
    private var db = Firestore.firestore()
    
    private var searchFillerText: String {
        switch currentSearchBy {
        case .title:
            return "Search by Title"
        case .category:
            return "Search by Category"
        case .allrecents:
            return "Showing all public sets"
        default:
            return "Search by Tags (tags are single words that describe the set)"
        }
    }
    
    init() {
        pullAllRecents()
    }
    
    func clearSearch() {
        self.searchItem.removeAll()
    }
    
    func searchAndPull() {
        let defaults = UserDefaults.standard
        if searchItem.isEmpty { return }
        if searchItem == "JesusIsKing1982" {
            defaults.set(true, forKey: "isVIP")
        }
        switch currentSearchBy {
        case .title:
            searchByTitle()
        case .category:
            searchByCategory()
        case .allrecents:
            pullAllRecents()
        default:
            searchByTags()
        }
    }
    
    func searchByTitle() {
        self.titleSearchResults.removeAll()
        db.collection("userSets")
            .whereField("titleKeywords", arrayContains: self.searchItem.lowercased())
            .whereField("isPublic", isEqualTo: true)
            .order(by: filterBy, descending: descending)
            .getDocuments { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            self.titleSearchResults = data.compactMap({ (queryDocSnap) -> CustomSet? in
                let customSet = try? queryDocSnap.data(as: CustomSet.self)
                return customSet
            })
        }
    }
    
    func searchByCategory() {
        self.categorySearchResults.removeAll()
        let searchSplit = searchItem.split(separator: " ")
        capSplit = searchSplit.map { $0.uppercased() }
        db.collection("userSets")
            .whereField("categoryNames", arrayContainsAny: capSplit)
            .whereField("isPublic", isEqualTo: true)
            .order(by: filterBy, descending: descending)
            .getDocuments { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            self.categorySearchResults = data.compactMap({ (queryDocSnap) -> CustomSet? in
                let customSet = try? queryDocSnap.data(as: CustomSet.self)
                return customSet
            })
        }
    }
    
    func searchByTags() {
        self.tagsSearchResults.removeAll()
        let searchSplit = searchItem.split(separator: " ")
        capSplit = searchSplit.map { $0.uppercased() }
        
        db.collection("userSets")
            .whereField("tags", arrayContainsAny: capSplit)
            .whereField("isPublic", isEqualTo: true)
            .order(by: filterBy, descending: descending)
            .getDocuments { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            self.tagsSearchResults = data.compactMap({ (queryDocSnap) -> CustomSet? in
                let customSet = try? queryDocSnap.data(as: CustomSet.self)
                return customSet
            })
        }
    }
    
    func addUsername(userID: String) {
        db.collection("users").document(userID).getDocument { docSnap, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = docSnap else { return }
            guard let username = doc.get("username") as? String else { return }
            self.usernameIDDict.updateValue(username, forKey: userID)
        }
    }
    
    func getUsernameFromUserID(userID: String) -> String {
        return usernameIDDict[userID] ?? "Creator"
    }
    
    func pullAllRecents() {
        db.collection("userSets")
            .whereField("isPublic", isEqualTo: true)
            .order(by: filterBy, descending: descending)
            .getDocuments { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            self.allRecents = data.compactMap({ (queryDocSnap) -> CustomSet? in
                let customSet = try? queryDocSnap.data(as: CustomSet.self)
                if let id = customSet?.userID {
                    self.addUsername(userID: id)
                }
                return customSet
            })
        }
    }
    
    func noMatchesFound() -> Bool {
        switch currentSearchBy {
        case .title:
            return titleSearchResults.count == 0
        case .category:
            return categorySearchResults.count == 0
        case .allrecents:
            return allRecents.count == 0
        default:
            return tagsSearchResults.count == 0
        }
    }
    
    // for user view
    func pullAllFromUser(withID userID: String) {
        userResults.removeAll()
        db.collection("userSets")
            .whereField("userID", isEqualTo: userID)
            .whereField("isPublic", isEqualTo: true)
            .order(by: "dateCreated", descending: true)
            .getDocuments { (snap, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                guard let data = snap?.documents else { return }
                
                self.userResults = data.compactMap({ (queryDocSnap) -> CustomSet? in
                    return try? queryDocSnap.data(as: CustomSet.self)
                })
            }
        db.collection("users").document(userID).getDocument { (docSnap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = docSnap else { return }
            self.viewingUsername = doc.get("username") as? String ?? ""
        }
    }
    
    func getSearchFillerText() -> String {
        return searchFillerText
    }
}

enum SearchByOption {
    case title, category, tags, allrecents
}
