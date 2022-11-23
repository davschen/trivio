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
    
    @Published var allPublicSets = [CustomSetCherry]()
    @Published var recentlyPlayedSets = [CustomSetCherry]()
    @Published var titleSearchResults = [CustomSet]()
    @Published var categorySearchResults = [CustomSet]()
    @Published var tagsSearchResults = [CustomSet]()
    @Published var userResults = [CustomSetCherry]()
    
    @Published var filterBy = "dateCreated"
    @Published var isDescending = true
    @Published var tagsString = [String]()
    @Published var tags = [String:Int]()
    
    @Published var selectedUserUsername = ""
    @Published var selectedUserName = ""
    @Published var selectedUserTagsDict = [String:Bool]()
    
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
    
    func pullAllPublicSets(isLimitingTo20: Bool = true) {
        // Is it a bit janky to limit to 10,000? Yes. I will never have 10,000 sets on my app, however.
        // When I do, I will be rich and I will sell this app to Kahoot or whomever and be even richer
        db.collection("userSets")
            .whereField("isPublic", isEqualTo: true)
            .order(by: filterBy, descending: isDescending)
            .limit(to: isLimitingTo20 ? 20 : 10000)
            .getDocuments { (snap, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                guard let data = snap?.documents else { return }
                self.allPublicSets = data.compactMap({ (queryDocSnap) -> CustomSetCherry? in
                    let customSet = try? queryDocSnap.data(as: CustomSet.self)
                    if let id = customSet?.userID {
                        self.addUsernameNameToDict(userID: id)
                    }
                    if let customSetCherry = try? queryDocSnap.data(as: CustomSetCherry.self) {
                        // Custom set for version 3.0
                        self.addUsernameNameToDict(userID: customSetCherry.userID)
                        return customSetCherry
                    } else {
                        // default
                        return CustomSetCherry(customSet: customSet ?? Empty().customSet)
                    }
                })
            }
    }
    
    private func pullRecentlyPlayedSets() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.addUsernameNameToDict(userID: uid)
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
                guard let docSnap = snap else { return }
                let customSet = try? docSnap.data(as: CustomSet.self)
                if let customSetCherry = try? docSnap.data(as: CustomSetCherry.self) {
                    // Custom set for version 3.0
                    self.recentlyPlayedSets.append(customSetCherry)
                } else if let customSet = customSet {
                    self.recentlyPlayedSets.append(CustomSetCherry(customSet: customSet))
                } else {
                    // default
                    return
                }
                guard let customSetUserID = customSet?.userID else { return }
                self.addUsernameNameToDict(userID: customSetUserID)
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
        selectedUserTagsDict.removeAll()
        
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
                
                self.userResults = data.compactMap({ (queryDocSnap) -> CustomSetCherry? in
                    let customSet = try? queryDocSnap.data(as: CustomSet.self)
                    if let id = customSet?.userID {
                        self.addUsernameNameToDict(userID: id)
                    }
                    if let customSetCherry = try? queryDocSnap.data(as: CustomSetCherry.self) {
                        // Custom set for version 3.0
                        for tag in customSetCherry.tags {
                            self.selectedUserTagsDict[tag] = true
                        }
                        print("ExploreViewModel :: selectedUserTagsDict")
                        return customSetCherry
                    } else {
                        // default
                        for tag in (customSet ?? Empty().customSet).tags {
                            self.selectedUserTagsDict[tag] = true
                        }
                        return CustomSetCherry(customSet: customSet ?? Empty().customSet)
                    }
                })
            }
        
        db.collection("users").document(userID).getDocument { (docSnap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = docSnap else { return }
            self.selectedUserUsername = doc.get("username") as? String ?? ""
            self.selectedUserName = doc.get("name") as? String ?? ""
        }
    }
    
    func toggleSelectedUserTagsDict(item: String) {
        self.selectedUserTagsDict[item]?.toggle()
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
        pullAllPublicSets(isLimitingTo20: false)
    }
}

enum SearchByOption {
    case title, category, tags, allrecents
}
