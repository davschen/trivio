//
//  MobileGameView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileGameView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        ZStack {
            switch gamesVM.gameSetupMode {
            case .settings:
                MobileGameSettingsView()
                    .transition(AnyTransition.move(edge: .bottom))
            case .participants:
                MobileParticipantsView()
                    .transition(AnyTransition.move(edge: .leading))
            default:
                MobileGameplayView()
                    .transition(AnyTransition.move(edge: .top))
            }
        }
    }
}

