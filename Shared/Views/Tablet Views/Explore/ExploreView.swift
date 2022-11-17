//
//  ExploreView.swift
//  Trivio
//
//  Created by David Chen on 5/1/21.
//

import Foundation
import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        if exploreVM.isShowingUserView {
            UserView(isShowingUserView: $exploreVM.isShowingUserView)
        } else {
            ExploreSearchView(isShowingUserView: $exploreVM.isShowingUserView)
        }
    }
}

struct ExploreSearchView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var isShowingUserView: Bool
    
    @State var isShowingSearchView = false
    @State var showSortByMenu = false
    
    let gridItems = [GridItem](repeating: GridItem(spacing: 15), count: 3)
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading, spacing: 15) {
                HStack (spacing: 20) {
                    // Top "Explore" text
                    Text("Explore")
                        .font(formatter.font(fontSize: .extraLarge))
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .bold))
                        TextField("Search sets", text: $exploreVM.searchItem, onCommit: {
                            exploreVM.searchAndPull()
                        })
                            .font(formatter.font())
                            .accentColor(formatter.color(.secondaryAccent))
                            .foregroundColor(formatter.color(.highContrastWhite))
                        if !exploreVM.searchItem.isEmpty {
                            Button {
                                exploreVM.searchItem.removeAll()
                                formatter.resignKeyboard()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .padding(.horizontal, 10)
                            }
                        }
                    }
                    .foregroundColor(formatter.color(.lowContrastWhite))
                    .padding()
                    .background(formatter.color(.secondaryFG))
                    .cornerRadius(5)
                    .padding(.horizontal, 2)
                }
                
                // Sorting button
                Button {
                    showSortByMenu.toggle()
                } label: {
                    HStack {
                        Text(exploreVM.getCurrentSort())
                            .font(formatter.font())
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .rotationEffect(Angle(degrees: showSortByMenu ? 180 : 0))
                    }
                    .foregroundColor(formatter.color(.mediumContrastWhite))
                }
                
                // Game preview view
                if gamesVM.previewViewShowing {
                    GamePreviewView(searchQuery: exploreVM.capSplit)
                }
                
                if exploreVM.noMatchesFound() {
                    Text("No Matches Found")
                        .font(formatter.font())
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    CustomSetView(searchItem: $exploreVM.searchItem, isMine: false, customSets: exploreVM.allPublicSets, columns: gridItems)
                }
                Spacer()
            }
            if showSortByMenu {
                ZStack (alignment: .topLeading) {
                    VStack (alignment: .leading, spacing: 0) {
                        FilterByView(showSortByMenu: $showSortByMenu, sortByOption: "Date created (newest)")
                        FilterByView(showSortByMenu: $showSortByMenu, sortByOption: "Date created (oldest)")
                        FilterByView(showSortByMenu: $showSortByMenu, sortByOption: "Highest rating")
                        FilterByView(showSortByMenu: $showSortByMenu, sortByOption: "Most plays")
                    }
                    .padding(.vertical)
                    .frame(width: 300)
                    .background(formatter.color(.primaryFG))
                    .cornerRadius(10)
                    .offset(y: 90)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .contentShape(Rectangle())
                .onTapGesture {
                    showSortByMenu.toggle()
                }
            }
        }
        .padding([.horizontal, .top], 30)
    }
}

struct FilterByView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    @Binding var showSortByMenu: Bool
    
    var sortByOption: String
    
    var body: some View {
        HStack {
            Text(sortByOption)
        }
        .font(formatter.font())
        .foregroundColor(formatter.color(.highContrastWhite))
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 30)
        .background(formatter.color(exploreVM.getCurrentSort() == sortByOption ? .secondaryFG : .primaryFG))
        .onTapGesture {
            exploreVM.applyCurrentSort(sortByOption: sortByOption)
            showSortByMenu.toggle()
        }
    }
}
