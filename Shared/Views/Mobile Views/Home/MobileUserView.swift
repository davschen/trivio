//
//  MobileUserView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileUserView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading, spacing: 15) {
                VStack (alignment: .leading, spacing: 5) {
                    Text(exploreVM.viewingUsername)
                        .font(formatter.font(fontSize: .large))
                    Text(exploreVM.viewingName)
                        .font(formatter.font(fontSize: .semiLarge))
                        .foregroundColor(formatter.color(.mediumContrastWhite))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(formatter.color(.primaryFG))
                .cornerRadius(10)
            }
            .font(formatter.customFont(weight: "Bold", iPadSize: 50))
            .padding(.horizontal)
            
            MobileCustomSetsView(customSets: $exploreVM.userResults)
        }
        .padding(.top)
        .withBackButton()
    }
}

