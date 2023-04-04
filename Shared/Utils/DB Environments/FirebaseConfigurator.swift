//
//  FirebaseConfigurator.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 3/30/23.
//

import Foundation
import FirebaseFirestore
import Firebase

class FirebaseConfigurator {
    static let shared = FirebaseConfigurator()

    private let useTestingDB = true

    private init() {
        let options: FirebaseOptions

        if useTestingDB {
            options = FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: "GoogleService-Info-Test", ofType: "plist")!)!
        } else {
            options = FirebaseOptions(contentsOfFile: Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!)!
        }

        FirebaseApp.configure(options: options)
    }

    var db: Firestore {
        return Firestore.firestore()
    }

    var auth: Auth {
        return Auth.auth()
    }
    
    func getFirestore() -> Firestore {
        return db
    }
}
