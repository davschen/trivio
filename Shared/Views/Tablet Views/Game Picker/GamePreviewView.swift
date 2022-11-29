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
        VStack (alignment: .leading, spacing: 10) {
            VStack (alignment: .leading, spacing: 0) {
                Text("Trivio Round Categories")
                    .font(formatter.font())
                HStack {
                    ForEach(gamesVM.tidyCustomSet.round1Cats, id: \.self) { category in
                        CategoryPreviewView(category: category, searchQuery: searchQuery)
                    }
                }
                .frame(height: 100)
            }
            VStack (alignment: .leading, spacing: 0) {
                Text("Double Trivio Round Categories")
                    .font(formatter.font())
                HStack {
                    ForEach(gamesVM.tidyCustomSet.round2Cats, id: \.self) { category in
                        CategoryPreviewView(category: category, searchQuery: searchQuery)
                    }
                }
                .frame(height: 100)
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
        }
    }
}

struct CategoryPreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    let category: String
    let searchQuery: [String]
    
    var body: some View {
        let shouldHighlight = profileVM.categoryInSearch(categoryName: category, searchQuery: searchQuery)
        ZStack {
            formatter.color(.primaryAccent)
            Text(category.uppercased())
                .font(formatter.font(fontSize: .small))
                .foregroundColor(formatter.color(.highContrastWhite))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
                .minimumScaleFactor(0.1)
                .padding(2)
        }
        .cornerRadius(10)
        .frame(maxHeight: .infinity)
        .padding(2)
        .tag(UUID().uuidString)
        .background(RoundedRectangle(cornerRadius: 5).stroke(formatter.color(.secondaryAccent), lineWidth: shouldHighlight ? 5 : 0))
    }
}
