//
//  MobileViewAllSetsView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/22/22.
//

import Foundation
import SwiftUI

struct MobileFilterByView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    @Binding var showSortByMenu: Bool
    
    var sortByOption: String
    var isSortingPublicSets: Bool
    
    var body: some View {
        HStack {
            Text(sortByOption)
        }
        .font(formatter.font(.regular))
        .foregroundColor(formatter.color(.highContrastWhite))
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
        .background(formatter.color(exploreVM.getCurrentSort() == sortByOption ? .primaryBG : .secondaryFG))
        .onTapGesture {
            exploreVM.applyCurrentSort(sortByOption: sortByOption, isSortingPublicSets: isSortingPublicSets)
            showSortByMenu.toggle()
        }
    }
}

