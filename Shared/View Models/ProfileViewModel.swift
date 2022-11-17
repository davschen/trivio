//
//  ProfileVM.swift
//  Trivio!
//
//  Created by David Chen on 5/24/21.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift

class ProfileViewModel: ObservableObject {
    @Published var playedGameIDs = [String]()
    @Published var menuSelectedItem = "Summary"
    @Published var username = "" 
    @Published var name = ""
    @Published var usernameValid = false
    @Published var drafts = [CustomSet]()
    @Published var searchItem = ""
    @Published var showingSettingsView = false
    @Published var settingsMenuSelectedItem = "Game Settings"
    
    private var db = Firestore.firestore()
    public var myUID = Auth.auth().currentUser?.uid
    
    init() {
        getPlayedGameIDs()
        getUserInfo()
    }
    
    private func getPlayedGameIDs() {
        guard let uid = myUID else { return }
        db.collection("users").document(uid).collection("played").addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let snap = snap else { return }
            snap.documentChanges.forEach { (diff) in
                guard let playedGameID = diff.document.get("gameID") as? String else { return }
                if diff.type == .added {
                    self.playedGameIDs.append(playedGameID)
                } else if diff.type == .removed {
                    self.playedGameIDs = self.playedGameIDs.filter { $0 != playedGameID }
                }
            }
        }
    }
    
    func markAsPlayed(gameID: String) {
        let playedRef = db.collection("users").document(Auth.auth().currentUser?.uid ?? "NID").collection("played")
        if !playedGameIDs.contains(gameID) {
            playedRef.addDocument(data: [
                "gameID" : gameID
            ])
        }
    }
    
    func beenPlayed(gameID: String) -> Bool {
        return playedGameIDs.contains(gameID)
    }
    
    func categoryInSearch(categoryName: String, searchQuery: [String]) -> Bool {
        var toReturn = false
        for word in searchQuery {
            if categoryName.lowercased().contains(word.lowercased()) {
                toReturn = true
            }
        }
        return toReturn
    }
    
    func checkForbiddenChars() -> String {
        var forbiddenReport = ""
        let forbiddenChars: [Character] = [" ", "/", "-", "&", "$", "#", "@", "!", "%", "^", "*", "(", ")", "+"]
        for char in forbiddenChars {
            if username.contains(String(char)) {
                forbiddenReport = String(char)
            }
        }
        if forbiddenReport.isEmpty {
            return ""
        } else {
            return forbiddenReport == " " ? "space" : "'" + forbiddenReport + "'"
        }
    }
    
    func checkUsernameExists(completion: @escaping (Bool) -> Void) {
        guard let uid = myUID else { return }
        let docRef = db.collection("users")
            .whereField("username", isEqualTo: username.lowercased())
        docRef.addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            if let doc = data.first {
                if (doc.documentID == uid) {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(true)
            }
        }
    }
    
    func checkUsernameValidWithHandler(completion: @escaping (Bool) -> Void) {
        checkUsernameExists { (success) -> Void in
            if success && !self.username.isEmpty && self.checkForbiddenChars().isEmpty {
                completion(true)
            } else {
                self.usernameValid = false
                completion(false)
            }
        }
    }
    
    func checkUsernameValid() {
        checkUsernameExists { (success) -> Void in
            if success && !self.username.isEmpty {
                self.usernameValid = true 
            } else {
                self.usernameValid = false
            }
        }
    }
    
    private func getUserInfo() {
        guard let myUID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(myUID).getDocument { (docSnap, error) in
            if error != nil { return }
            guard let doc = docSnap else { return }
            let name = doc.get("name") as? String ?? ""
            let username = doc.get("username") as? String ?? ""
            DispatchQueue.main.async {
                self.name = name
                self.username = username
            }
        }
        db.collection("drafts")
            .whereField("userID", isEqualTo: myUID)
            .order(by: "dateCreated", descending: true)
            .addSnapshotListener { snap, error in
            if error != nil { return }
            guard let data = snap?.documents else { return }
            self.drafts = data.compactMap({ (queryDocSnap) -> CustomSet? in
                return try? queryDocSnap.data(as: CustomSet.self)
            })
        }
    }
    
    func writeKeyValueToFirestore(key: String, value: Any) {
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "NID").setData([
            key : value
        ], merge: true)
    }
    
    func getInitials(name: String) -> String {
        var initials = ""
        let nameSplit = name.split(separator: " ")
        for i in 0..<nameSplit.count {
            let name = nameSplit[i]
            if initials.count < 3 {
                initials += name.prefix(1)
            }
        }
        return initials
    }
    
    func editAccountInfo() {
        guard let uid = myUID else { return }
        db.collection("users").document(uid).setData([
            "name": self.name,
            "username": self.username.lowercased()
        ], merge: true)
        getUserInfo()
    }
    
    func getPhoneNumber() -> String {
        return Auth.auth().currentUser?.phoneNumber ?? ""
    }
    
    func updatePhoneNumber(newPhoneNumber: String) {
        
    }
    
    func logOut() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        NotificationCenter.default.post(name: NSNotification.Name("LogInStatusChange"), object: nil)
        try? Auth.auth().signOut()
    }
}

enum DeviceType {
    case iPad, iPhone
}
