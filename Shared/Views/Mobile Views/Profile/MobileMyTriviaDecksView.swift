//
//  MobileMyTriviaDecksView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/28/23.
//

import Foundation
import SwiftUI

struct MobileMyTriviaDecksView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel

    var body: some View {
        let columns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(profileVM.myTriviaDeckClues, id: \.self) { triviaDeckClue in
                        MobileMyTriviaDecksCellView(triviaDeckClue: triviaDeckClue)
                            .transition(.identity)
                            .animation(nil)
                    }
                }
                .padding(10)
            }
        }
        .withBackButton()
        .navigationTitle("My Trivia Deck Clues")
    }
}

struct MobileMyTriviaDecksCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var triviaDeckClue: TriviaDeckClue
    
    var body: some View {
        VStack (spacing: 3) {
            Text("\(triviaDeckClue.triviaDeckTitle)")
                .font(formatter.font(fontSize: .regular))
            Text("\(triviaDeckClue.category.uppercased())")
                .font(formatter.font(.regular, fontSize: .small))
            Spacer(minLength: 0)
            Text("\(triviaDeckClue.clue)")
                .tracking(0.1)
                .font(formatter.bigCaslonFont(sizeFloat: 14))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .lineLimit(3)
                .opacity(triviaDeckClue.needsAdminReview ? 0.4 : 1)
            Text("\(triviaDeckClue.response)")
                .tracking(0.1)
                .font(formatter.bigCaslonFont(sizeFloat: 14))
                .foregroundColor(formatter.color(.secondaryAccent))
                .opacity(triviaDeckClue.needsAdminReview ? 0.4 : 1)
                .padding(.top, 5)
            Spacer(minLength: 0)
            Text("Submitted \(formatter.relativeDateString(from: triviaDeckClue.submittedDate))")
                .font(formatter.font(.regularItalic, fontSize: .small))
            if triviaDeckClue.needsAdminReview {
                Text("Under Review")
                    .font(formatter.font(.regularItalic, fontSize: .small))
            } else {
                Text("Responses: \(triviaDeckClue.totalSubmissions)")
                    .font(formatter.font(.regularItalic, fontSize: .small))
            }
        }
        .frame(maxWidth: 160)
        .frame(height: 210)
        .padding(20)
        .background(formatter.gradient(.primaryFG))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(formatter.color(.secondaryFG), lineWidth: triviaDeckClue.needsAdminReview ? 1 : 0))
    }
}

