//
//  MobileExploreView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileExploreView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        NavigationView() {
            MobileExploreSearchView(isShowingUserView: $exploreVM.isShowingUserView)
                .withHeader("Explore")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(formatter.color(.primaryBG))
        .transition(.identity)
    }
}

struct MobileExploreSearchView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var isShowingUserView: Bool
    
    @State var isShowingSearchView = false
    @State var showSortByMenu = false
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading, spacing: 10) {
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
                                .font(.system(size: 15, weight: .bold))
                                .padding(.horizontal, 10)
                        }
                    }
                }
                .foregroundColor(formatter.color(.lowContrastWhite))
                .padding()
                .background(formatter.color(.secondaryFG))
                .cornerRadius(5)
                .padding(.horizontal)
                
                // Sorting button
                Button {
                    showSortByMenu.toggle()
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                } label: {
                    HStack {
                        Text(exploreVM.getCurrentSort())
                            .font(formatter.font())
                        Image(systemName: "chevron.down")
                            .font(.system(size: 15, weight: .bold))
                            .rotationEffect(Angle(degrees: showSortByMenu ? 180 : 0))
                    }
                    .foregroundColor(formatter.color(.mediumContrastWhite))
                }
                .padding(.horizontal)
                
                if exploreVM.noMatchesFound() {
                    LoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    MobileCustomSetView(searchItem: $exploreVM.searchItem, isMine: false, customSets: exploreVM.allRecents)
                }
            }
            if showSortByMenu {
                ZStack (alignment: .topLeading) {
                    VStack (alignment: .leading, spacing: 0) {
                        MobileFilterByView(showSortByMenu: $showSortByMenu, sortByOption: "Date created (newest)")
                        MobileFilterByView(showSortByMenu: $showSortByMenu, sortByOption: "Date created (oldest)")
                        MobileFilterByView(showSortByMenu: $showSortByMenu, sortByOption: "Highest rating")
                        MobileFilterByView(showSortByMenu: $showSortByMenu, sortByOption: "Most plays")
                    }
                    .padding(.vertical)
                    .frame(width: 250)
                    .background(formatter.color(.primaryFG))
                    .cornerRadius(10)
                    .offset(x: 15, y: 80)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .contentShape(Rectangle())
                .shadow(color: formatter.color(.primaryBG), radius: 20, x: 0, y: 10)
                .onTapGesture {
                    showSortByMenu.toggle()
                }
            }
        }
        
    }
}

struct MobileFilterByView: View {
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
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
        .background(formatter.color(exploreVM.getCurrentSort() == sortByOption ? .secondaryFG : .primaryFG))
        .onTapGesture {
            formatter.hapticFeedback(style: .rigid, intensity: .weak)
            exploreVM.applyCurrentSort(sortByOption: sortByOption)
            showSortByMenu.toggle()
        }
    }
}

