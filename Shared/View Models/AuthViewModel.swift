//
//  AuthViewModel.swift
//  Trivio!
//
//  Created by David Chen on 12/1/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class AuthViewModel: ObservableObject {
    private var db = Firestore.firestore()
    
    func checkUsernameExists(uid: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(uid).getDocument { (docSnap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = docSnap else { return }
            if let _ = doc.get("username") as? String {
                completion(true)
            }
        }
    }
}
