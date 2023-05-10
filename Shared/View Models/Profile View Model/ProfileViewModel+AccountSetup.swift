//
//  ProfileViewModel+AccountSetup.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/27/23.
//

import Foundation

extension ProfileViewModel {    
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
    
    func getAuthProvider() -> String {
        let providerData = FirebaseConfigurator.shared.auth.currentUser?.providerData
        var provider = ""
        providerData?.forEach({ userInfo in
            if userInfo.phoneNumber != nil {
                provider = "Phone"
            } else {
                provider = "Google"
            }
        })
        return provider
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
        return FirebaseConfigurator.shared.auth.currentUser?.phoneNumber ?? ""
    }
    
    func updatePhoneNumber(newPhoneNumber: String) {
        // I assume I may try this in the future but definitely not anytime soon
    }
    
    func accountInformationError(usernameTaken: Bool) -> Bool {
        return !nameError().isEmpty || !usernameError(usernameTaken: usernameTaken).isEmpty
    }
    
    func usernameError(usernameTaken: Bool) -> String {
        if usernameTaken {
            return "That username is already taken"
        } else if self.username.isEmpty {
            return "Your username cannot be empty"
        } else if !self.checkForbiddenChars().isEmpty {
            return "Your username cannot contain a " + self.checkForbiddenChars()
        } else {
            return ""
        }
    }
    
    func nameError() -> String {
        if self.name.isEmpty {
            return "Your name cannot be empty"
        } else {
            return ""
        }
    }
}
