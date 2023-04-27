//
//  Build.swift
//  Trivio!
//
//  Created by David Chen on 10/28/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum BuildPhaseType {
    case rounds1and2, ddSelections
}

var BuildStageValueDict: [BuildStage:Int] {
    return [
        .details : 0,
        .trivioRound : 1,
        .trivioRoundDD : 2,
        .dtRound : 3,
        .dtRoundDD : 4,
        .finalTrivio: 5
    ]
}
