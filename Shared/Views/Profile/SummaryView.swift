//
//  SummaryView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/8/21.
//

import Foundation
import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            Text("Summary")
                .font(formatter.font(fontSize: .extraLarge))
                .foregroundColor(formatter.color(.highContrastWhite))
            SummaryPreviewView()
            Spacer()
        }
    }
    
    struct SummaryPreviewView: View {
        @EnvironmentObject var formatter: MasterHandler
        @EnvironmentObject var gamesVM: GamesViewModel
        var body: some View {
            ScrollView (.vertical) {
                VStack (alignment: .leading) {
                    HStack {
                        Text("My Sets")
                            .font(formatter.font(fontSize: .large))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .padding([.horizontal, .top], 20)
                    ScrollView (.horizontal, showsIndicators: false) {
                        HStack (spacing: 20) {
                            Spacer()
                                .frame(width: 0, height: 0)
                            ForEach(gamesVM.customSets, id: \.self) { set in
                                CustomSetCellView(set: set, isMine: true)
                            }
                            Spacer()
                                .frame(width: 0, height: 0)
                        }
                        .padding(.bottom)
                    }
                }
                .background(formatter.color(.primaryFG))
                .cornerRadius(10)
            }
        }
    }
}
