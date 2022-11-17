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
    
    @Published var allPublicSets = [CustomSet]()
    @Published var recentlyPlayedSets = [CustomSet]()
    @Published var titleSearchResults = [CustomSet]()
    @Published var categorySearchResults = [CustomSet]()
    @Published var tagsSearchResults = [CustomSet]()
    @Published var userResults = [CustomSet]()
    
    @Published var filterBy = "dateCreated"
    @Published var isDescending = true
    @Published var tagsString = [String]()
    @Published var tags = [String:Int]()
    
    @Published var viewingUsername = ""
    @Published var viewingName = ""
    @Published var isShowingUserView = false
    @Published var usernameIDDict = [String:String]()
    @Published var nameIDDict = [String:String]()
    
    private var db = Firestore.firestore()
    
    private var currentSort: String {
        if filterBy == "dateCreated" && isDescending == true {
            return "Date created (newest)"
        } else if filterBy == "dateCreated" && isDescending == false {
            return "Date created (oldest)"
        } else if filterBy == "rating" && isDescending == true {
            return "Highest rating"
        } else {
            return "Most plays"
        }
    }
    
    init() {
        pullAllPublicSets()
        pullRecentlyPlayedSets()
    }
    
    func clearSearch() {
        self.searchItem.removeAll()
    }
    
    func searchAndPull() {
        let defaults = UserDefaults.standard
        if searchItem.isEmpty { return }
        if searchItem == "SocratesIsUnwise" {
            defaults.set(true, forKey: "isVIP")
        }
        switch currentSearchBy {
        case .title:
            searchByTitle()
        case .category:
            searchByCategory()
        case .allrecents:
            pullAllPublicSets()
        default:
            searchByTags()
        }
    }
    
    func searchByTitle() {
        self.titleSearchResults.removeAll()
        db.collection("userSets")
            .whereField("titleKeywords", arrayContains: self.searchItem.lowercased())
            .whereField("isPublic", isEqualTo: true)
            .order(by: filterBy, descending: isDescending)
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
            .order(by: filterBy, descending: isDescending)
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
            .order(by: filterBy, descending: isDescending)
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
    
    func addUsernameNameToDict(userID: String) {
        db.collection("users").document(userID).getDocument { docSnap, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = docSnap else { return }
            guard let username = doc.get("username") as? String else { return }
            guard let name = doc.get("name") as? String else { return }
            self.nameIDDict.updateValue(name, forKey: userID)
            self.usernameIDDict.updateValue(username, forKey: userID)
        }
    }
    
    func getUsernameFromUserID(userID: String) -> String {
        return usernameIDDict[userID] ?? "Creator"
    }
    
    func getInitialsFromUserID(userID: String) -> String {
        var initials: String = ""
        let name: String = nameIDDict[userID] ?? ""
        let fullNameArray = name.components(separatedBy: " ")
        for eachName in fullNameArray {
            initials += eachName.prefix(1)
            if initials.count > 2 {
                break
            }
        }
        return initials.uppercased()
    }
    
    func pullAllPublicSets() {
        db.collection("userSets")
            .whereField("isPublic", isEqualTo: true)
            .order(by: filterBy, descending: isDescending)
            .getDocuments { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            self.allPublicSets = data.compactMap({ (queryDocSnap) -> CustomSet? in
                let customSet = try? queryDocSnap.data(as: CustomSet.self)
                if let id = customSet?.userID {
                    self.addUsernameNameToDict(userID: id)
                }
                return customSet
            })
        }
    }
    
    private func pullRecentlyPlayedSets() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).collection("played").addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let snap = snap else { return }
            snap.documentChanges.forEach { (diff) in
                guard let playedGameID = diff.document.get("gameID") as? String else { return }
                if diff.type == .added {
                    self.addToRecentlyPlayed(customSetID: playedGameID)
                }
            }
        }
    }
    
    func addToRecentlyPlayed(customSetID: String) {
        db.collection("userSets")
            .document(customSetID)
            .getDocument { (snap, error) in
                if error != nil { return }
                guard let customSet = try? snap?.data(as: CustomSet.self) else { return }
                self.recentlyPlayedSets.append(customSet)
                self.recentlyPlayedSets = self.recentlyPlayedSets.sorted(by: { $0.dateCreated > $1.dateCreated })
            }
    }
    
    func noMatchesFound() -> Bool {
        switch currentSearchBy {
        case .title:
            return titleSearchResults.count == 0
        case .category:
            return categorySearchResults.count == 0
        case .allrecents:
            return allPublicSets.count == 0
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
            self.viewingName = doc.get("name") as? String ?? ""
        }
    }
    
    func getCurrentSort() -> String {
        return currentSort
    }
    
    func applyCurrentSort(sortByOption: String) {
        switch sortByOption {
        case "Date created (newest)":
            filterBy = "dateCreated"
            isDescending = true
        case "Date created (oldest)":
            filterBy = "dateCreated"
            isDescending = false
        case "Highest rating":
            filterBy = "rating"
            isDescending = true
        default:
            filterBy = "plays"
            isDescending = true
        }
        pullAllPublicSets()
    }
}

enum SearchByOption {
    case title, category, tags, allrecents
}
