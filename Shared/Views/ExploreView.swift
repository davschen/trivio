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
                .padding([.horizontal, .top], 30)
        }
    }
}

struct UserView: View {
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @Binding var isShowingUserView: Bool
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack {
            VStack (alignment: .leading, spacing: 5) {
                Button {
                    isShowingUserView.toggle()
                    gamesVM.setEpisode(ep: "")
                } label: {
                    HStack (spacing: 3) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: formatter.shrink(iPadSize: 30, factor: 1.5)))
                        Text("Back to Explore")
                    }
                    .font(formatter.customFont(weight: "Medium", iPadSize: 30))
                }
                HStack (spacing: 0) {
                    Text("@\(exploreVM.viewingUsername)")
                        .foregroundColor(Color("MainAccent"))
                    Text("'s Games")
                    Spacer()
                }
            }
            .font(formatter.customFont(weight: "Bold", iPadSize: 50))
            if (formatter.deviceType == .iPad && !gamesVM.selectedEpisode.isEmpty) || (formatter.deviceType == .iPhone && gamesVM.previewViewShowing) {
                GamePreviewView()
            }
            CustomSetView(isMine: false, customSets: exploreVM.userResults)
            Spacer()
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
    @State var showFilterBy = true
    
    var body: some View {
        VStack (spacing: 5) {
            // Top "Explore" text
            HStack {
                Text("Explore")
                    .font(formatter.customFont(weight: "Bold", iPadSize: 50))
                // Search by title, category, or tags
                HStack (alignment: .bottom, spacing: formatter.deviceType == .iPad ? nil : 3) {
                    SearchByView(currentSearchBy: $exploreVM.currentSearchBy, showFilterBy: $showFilterBy, searchByOption: .title)
                    SearchByView(currentSearchBy: $exploreVM.currentSearchBy, showFilterBy: $showFilterBy, searchByOption: .category)
                    SearchByView(currentSearchBy: $exploreVM.currentSearchBy, showFilterBy: $showFilterBy, searchByOption: .tags)
                    SearchByView(currentSearchBy: $exploreVM.currentSearchBy, showFilterBy: $showFilterBy, searchByOption: .allrecents)
                    if exploreVM.currentSearchBy == .allrecents {
                        Button(action: {
                            exploreVM.pullAllRecents()
                        }, label: {
                            Text("Go")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                .foregroundColor(Color.white)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(formatter.cornerRadius(5))
                        })
                    }
                    Spacer()
                }
                .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                Spacer()
            }
            if !(exploreVM.currentSearchBy == .allrecents) {
                // Search bar
                HStack {
                    Button(action: {
                        showFilterBy.toggle()
                    }, label: {
                        Image(systemName: "line.horizontal.3.decrease.circle\(showFilterBy ? ".fill" : "")")
                    })
                    HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                        Image(systemName: "magnifyingglass")
                        TextField(exploreVM.getSearchFillerText(), text: $exploreVM.searchItem, onCommit: {
                            exploreVM.searchAndPull()
                        })
                        .font(formatter.customFont(iPadSize: 20))
                        Image(systemName: "xmark.circle.fill")
                            .onTapGesture {
                                self.exploreVM.clearSearch()
                            }
                    }
                    .padding(.vertical, formatter.shrink(iPadSize: 10)).padding(.horizontal, formatter.shrink(iPadSize: 15))
                    .background(Color.gray.opacity(0.3))
                    .accentColor(.white)
                    .clipShape(Capsule())
                    Button {
                        exploreVM.searchAndPull()
                        gamesVM.setEpisode(ep: "")
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Text("SEARCH")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            .padding(.vertical, 5).padding(.horizontal, 10)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(formatter.cornerRadius(5))
                    }
                }
            }
            // Filter options
            HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                if showFilterBy {
                    Text("Filter by: ")
                    FilterByView(filterByOption: "rating")
                    FilterByView(filterByOption: "plays")
                    FilterByView(filterByOption: "dateCreated")
                    Image(systemName: "chevron.down")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                        .foregroundColor(Color("MainAccent"))
                        .rotationEffect(Angle(degrees: exploreVM.descending ? 0 : 180))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(formatter.cornerRadius(5))
                        .onTapGesture {
                            exploreVM.descending.toggle()
                        }
                    Spacer()
                }
            }
            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
            .foregroundColor(Color.white)
            .padding(.vertical, 5)
            
            // Game preview view
            if gamesVM.previewViewShowing {
                GamePreviewView(searchQuery: exploreVM.capSplit)
            }
            
            if exploreVM.noMatchesFound() {
                HStack {
                    Text("No Matches Found")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                    Spacer()
                }
            } else {
                if formatter.deviceType == .iPad {
                    QueriedCustomSetView()
                } else if formatter.deviceType == .iPhone {
                    if !gamesVM.previewViewShowing {
                        QueriedCustomSetView()
                    }
                }
            }
            Spacer()
        }
    }
}

struct SearchByView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @Binding var currentSearchBy: SearchByOption
    @Binding var showFilterBy: Bool
    var searchByOption: SearchByOption
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        HStack {
            switch searchByOption {
            case .title:
                Text("Title")
            case .category:
                Text("Category")
            case .tags:
                Text("Tags")
            default:
                Text("All")
            }
        }
        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
        .foregroundColor(Color("MainAccent"))
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(currentSearchBy == searchByOption ? 0.7 : 0.2))
        .cornerRadius(formatter.cornerRadius(5))
        .onTapGesture {
            gamesVM.setEpisode(ep: "")
            currentSearchBy = searchByOption
            if searchByOption == .allrecents {
                showFilterBy = true
            }
        }
    }
}

struct QueriedCustomSetView: View {
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    var body: some View {
        ZStack {
            switch exploreVM.currentSearchBy {
            case .title:
                CustomSetView(isMine: false, customSets: exploreVM.titleSearchResults)
            case .category:
                CustomSetView(isMine: false, customSets: exploreVM.categorySearchResults)
            case .allrecents:
                CustomSetView(isMine: false, customSets: exploreVM.allRecents)
            default:
                CustomSetView(isMine: false, customSets: exploreVM.tagsSearchResults)
            }
        }
    }
}

struct FilterByView: View {
    @EnvironmentObject var exploreVM: ExploreViewModel
    var filterByOption: String
    @EnvironmentObject var formatter: MasterHandler
    var body: some View {
        HStack {
            switch filterByOption {
            case "rating":
                Text("Rating")
            case "plays":
                Text("Plays")
            case "averageScore":
                Text("Score")
            default:
                Text("Date")
            }
        }
        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(exploreVM.filterBy == filterByOption ? 0.7 : 0.2))
        .cornerRadius(formatter.cornerRadius(5))
        .onTapGesture {
            exploreVM.filterBy = filterByOption
        }
    }
}
