//
//  MobileGamePreviewView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileGamePreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var searchQuery: [String] = []
    @State var roundSelector = "Trivio Round"
    
    var body: some View {
        if gamesVM.menuChoice == gamesVM.gameQueryFromType {
            VStack (alignment: .leading, spacing: 10) {
                VStack (alignment: .leading, spacing: 0) {
                    Text("Trivio Round Categories")
                        .font(formatter.font())
                    ScrollView (.horizontal, showsIndicators: false) {
                        HStack (spacing: 5) {
                            ForEach(gamesVM.jeopardyCategories, id: \.self) { category in
                                MobileCategoryPreviewView(category: category, searchQuery: searchQuery)
                            }
                        }
                        .frame(height: 100)
                    }
                }
                VStack (alignment: .leading, spacing: 0) {
                    Text("Double Trivio Round Categories")
                        .font(formatter.font())
                    ScrollView (.horizontal, showsIndicators: false) {
                        HStack (spacing: 5) {
                            ForEach(gamesVM.doubleJeopardyCategories, id: \.self) { category in
                                MobileCategoryPreviewView(category: category, searchQuery: searchQuery)
                            }
                        }
                        .frame(height: 100)
                    }
                }
                // if the set is not custom, show the little signs
                if gamesVM.queriedUserName.isEmpty {
                    HStack {
                        Spacer()
                        Button(action: {
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
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
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
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
                }
            }
        }
    }
}

struct MobileCategoryPreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    let category: String
    let searchQuery: [String]
    
    var body: some View {
        let shouldHighlight = profileVM.categoryInSearch(categoryName: category, searchQuery: searchQuery)
        ZStack {
            Text(category.uppercased())
                .font(formatter.font(fontSize: .regular))
                .foregroundColor(formatter.color(.highContrastWhite))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
                .minimumScaleFactor(0.1)
                .padding(2)
                .onTapGesture {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    gamesVM.menuChoice = .game
                    gamesVM.reset()
                }
        }
        .frame(maxHeight: .infinity)
        .frame(width: 130)
        .tag(UUID().uuidString)
        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(formatter.color(.secondaryAccent), lineWidth: shouldHighlight ? 5 : 0))
        .background(formatter.color(.primaryAccent))
        .cornerRadius(10)
    }
}

