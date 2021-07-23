//
//  GameView.swift
//  Trivio!
//
//  Created by David Chen on 7/21/21.
//

import Foundation
import SwiftUI

struct GameView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        ZStack {
            switch gamesVM.gameSetupMode {
            case .settings:
                GameSettingsView()
                    .transition(AnyTransition.move(edge: .bottom))
            case .participants:
                ParticipantsView()
                    .transition(AnyTransition.move(edge: .leading))
            default:
                GameplayView()
                    .transition(AnyTransition.move(edge: .top))
            }
        }
    }
}
