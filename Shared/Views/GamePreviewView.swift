//
//  GamePreviewView.swift
//  Trivio
//
//  Created by David Chen on 3/22/21.
//

import Foundation
import SwiftUI

struct GamePreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State var searchQuery: [String] = []
    @State var roundSelector = "Trivio Round"
    
    var body: some View {
        VStack (alignment: .leading) {
            if gamesVM.jeopardyCategories.count > 0 {
                if gamesVM.loadingGame {
                    ProgressView()
                } else {
                    if formatter.deviceType == .iPad {
                        Group {
                            VStack (alignment: .leading, spacing: 0) {
                                Text("Trivio Round Categories")
                                    .font(formatter.font())
                                HStack {
                                    ForEach(gamesVM.jeopardyCategories, id: \.self) { category in
                                        let shouldHighlight = profileVM.categoryInSearch(categoryName: category, searchQuery: searchQuery)
                                        ZStack {
                                            formatter.color(.primaryAccent)
                                            Text(category.uppercased())
                                                .font(formatter.font())
                                                .foregroundColor(formatter.color(.highContrastWhite))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 10)
                                                .frame(maxWidth: .infinity)
                                                .minimumScaleFactor(0.1)
                                                .padding(2)
                                        }
                                        .cornerRadius(10)
                                        .padding(2)
                                        .tag(UUID().uuidString)
                                        .background(RoundedRectangle(cornerRadius: 5).stroke(formatter.color(.secondaryAccent), lineWidth: shouldHighlight ? 5 : 0))
                                    }
                                }
                            }
                            VStack (alignment: .leading, spacing: 0) {
                                Text("Double Trivio Round Categories")
                                    .font(formatter.font())
                                HStack {
                                    ForEach(gamesVM.doubleJeopardyCategories, id: \.self) { category in
                                        let shouldHighlight = profileVM.categoryInSearch(categoryName: category, searchQuery: searchQuery)
                                        ZStack {
                                            formatter.color(.primaryAccent)
                                            Text(category.uppercased())
                                                .font(formatter.font())
                                                .foregroundColor(formatter.color(.highContrastWhite))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 10)
                                                .frame(maxWidth: .infinity)
                                                .minimumScaleFactor(0.1)
                                                .padding(2)
                                        }
                                        .cornerRadius(10)
                                        .padding(2)
                                        .tag(UUID().uuidString)
                                        .background(RoundedRectangle(cornerRadius: 5).stroke(formatter.color(.secondaryAccent), lineWidth: shouldHighlight ? 5 : 0))
                                    }
                                }
                            }
                            HStack {
                                Spacer()
                                Button(action: {
                                    gamesVM.previewViewShowing.toggle()
                                }, label: {
                                    HStack {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 15, weight: .bold))
                                        Text("Close")
                                    }
                                    .font(formatter.font())
                                    .foregroundColor(formatter.color(.primaryFG))
                                    .padding(10)
                                    .background(formatter.color(.highContrastWhite))
                                    .cornerRadius(5)
                                })
                                Button(action: {
                                    gamesVM.menuChoice = .game
                                    gamesVM.reset()
                                }, label: {
                                    HStack {
                                        Image(systemName: "gamecontroller.fill")
                                            .font(.system(size: 15, weight: .bold))
                                        Text("Play")
                                    }
                                    .font(formatter.font())
                                    .foregroundColor(formatter.color(.primaryFG))
                                    .padding(10)
                                    .background(formatter.color(.highContrastWhite))
                                    .cornerRadius(5)
                                })
                            }
                            .padding(.bottom, 10)
                        }
                    } else if formatter.deviceType == .iPhone {
                        Group {
                            HStack {
                                Button(action: {
                                    gamesVM.previewViewShowing.toggle()
                                }, label: {
                                    Image(systemName: "chevron.left")
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                })
                                
                                Text(gamesVM.title)
                                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                    .padding(5)
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(5)
                                Text("Trivio Round Categories")
                                    .padding(5)
                                    .background(Color.white.opacity(roundSelector == "Trivio Round" ? 0.1 : 0))
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        roundSelector = "Trivio Round"
                                    }
                                Text("Double Trivio Round Categories")
                                    .padding(5)
                                    .background(Color.white.opacity(roundSelector == "Double Trivio Round" ? 0.1 : 0))
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        roundSelector = "Double Trivio Round"
                                    }
                            }
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            HStack (spacing: 5) {
                                ForEach((roundSelector == "Trivio Round" ? gamesVM.jeopardyCategories : gamesVM.doubleJeopardyCategories), id: \.self) { category in
                                    let shouldHighlight = profileVM.categoryInSearch(categoryName: category, searchQuery: searchQuery)
                                    ZStack {
                                        Color("MainFG")
                                        Text(category.uppercased())
                                            .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                                            .foregroundColor(Color.white)
                                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 10)
                                            .frame(maxWidth: .infinity)
                                            .minimumScaleFactor(0.1)
                                            .padding(2)
                                    }
                                    .cornerRadius(5)
                                    .padding(2)
                                    .tag(UUID().uuidString)
                                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color("MainAccent"), lineWidth: shouldHighlight ? formatter.shrink(iPadSize: 10) : 0))
                                }
                            }
                            HStack {
                                Spacer()
                                if gamesVM.menuChoice != .gamepicker {
                                    Button(action: {
                                        exploreVM.isShowingUserView = true
                                        exploreVM.pullAllFromUser(withID: gamesVM.customSet.userID)
                                        gamesVM.previewViewShowing = false
                                    }, label: {
                                        HStack {
                                            Image(systemName: "person.circle")
                                            Text(gamesVM.queriedUserName)
                                        }
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                                        .foregroundColor(Color("MainAccent"))
                                        .padding(10)
                                        .background(Color.gray.opacity(0.4))
                                        .cornerRadius(5)
                                    })
                                }
                                Button(action: {
                                    gamesVM.menuChoice = .game
                                    gamesVM.reset()
                                }, label: {
                                    HStack {
                                        Image(systemName: "gamecontroller")
                                        Text("Play")
                                    }
                                    .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.gray.opacity(0.4))
                                    .cornerRadius(5)
                                })
                            }
                        }
                    }
                }
            }
        }
        .frame(height: formatter.deviceType == .iPad ? (gamesVM.selectedEpisode.isEmpty ? 0 : 360) : nil)
    }
}
