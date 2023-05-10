//
//  TrivioUser.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/27/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct TrivioUser: Encodable, Decodable, Hashable, Identifiable {
    @DocumentID var id: String?
    var name: String = ""
    var username: String = ""
}
