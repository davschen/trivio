//
//  MobileDTInfoView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 3/23/22.
//

import Foundation
import SwiftUI

struct MobileDTInfoView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (alignment: .center, spacing: 7) {
                Text("How to Play")
                    .font(formatter.font(.bold, fontSize: .mediumLarge))
                    .padding(20)
                MobileStaticInstructionsView()
            }
            .padding(15)
        }
        .frame(maxWidth: .infinity)
        .background(formatter.color(.primaryFG))
        .cornerRadius(10)
        .padding([.horizontal, .bottom], 10)
    }
}

struct MobileStaticInstructionsView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            Text("Given a clue and the date it originally aired, try to guess the response in as few attempts as possible. You will have 60 seconds to make your guesses. After you finish, you'll be able to see averrage global statistics for the Daily Trivio.")
            Text("Much like other derivatives of Wordle, you'll be told which letters you've used are correct and which ones are not. While you are technically allowed to guess any random string of letters, you are scored by your number of attempts, so guessing gibberish might not be the best strategy.")
            Text("Your score is a function of time, attempts, and correctness. The highest score possible is 5000, which happens when you guess the correct answer with one attempt and in under one second.")
        }
        .font(formatter.font(.regular, fontSize: .small))
        .multilineTextAlignment(.leading)
        .lineSpacing(5)
    }
}
