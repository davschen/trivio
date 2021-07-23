//
//  UserView.swift
//  Trivio!
//
//  Created by David Chen on 7/21/21.
//

import Foundation
import SwiftUI

struct UserView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @Binding var isShowingUserView: Bool
    
    let gridItems = [GridItem](repeating: GridItem(spacing: 15), count: 3)
    
    var body: some View {
        VStack {
            VStack (alignment: .leading, spacing: 15) {
                Button {
                    isShowingUserView.toggle()
                } label: {
                    HStack (spacing: 3) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .bold))
                        Text("Back to Explore")
                    }
                    .font(formatter.font())
                }
                VStack (alignment: .leading, spacing: 5) {
                    Text(exploreVM.viewingUsername)
                        .font(formatter.font(fontSize: .large))
                    Text(exploreVM.viewingName)
                        .font(formatter.font(fontSize: .semiLarge))
                        .foregroundColor(formatter.color(.mediumContrastWhite))
                }
                .padding(30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(formatter.color(.primaryFG))
                .cornerRadius(10)
            }
            .font(formatter.customFont(weight: "Bold", iPadSize: 50))
            if gamesVM.previewViewShowing {
                GamePreviewView()
                    .padding(.top)
            }
            CustomSetView(searchItem: $exploreVM.searchItem, isMine: false, customSets: exploreVM.userResults, columns: gridItems)
            Spacer()
        }
        .padding([.top, .horizontal], 30)
    }
}
