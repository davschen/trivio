//
//  DailyTrivioPreviewView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 3/23/22.
//

import Foundation
import SwiftUI

struct DailyTrivioPreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    let trivioStringArr = ["T", "R", "I", "V", "I", "O"]
    
    var body: some View {
        VStack {
            // Top bar with "Tap to Play!" and time left
            ZStack {
                Text("Tap to Play!")
                Text("09:06:14 left")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(formatter.font(.boldItalic, fontSize: .small))
            .frame(maxWidth: .infinity)
            .padding()
            .background(formatter.color(.secondaryAccent))
            
            HStack (alignment: .bottom) {
                VStack (alignment: .leading) {
                    Text("Daily")
                        .font(formatter.font(.bold, fontSize: .mediumLarge))
                    HStack (spacing: 3) {
                        ForEach(0..<trivioStringArr.count) { i in
                            let letter = trivioStringArr[i]
                            Text(letter)
                                .font(formatter.font(.bold))
                                .frame(width: 30, height: 30)
                                .background(formatter.color(.primaryBG))
                        }
                    }
                }
                Spacer(minLength: 10)
                Text("Answer today's question, see how others did")
                    .font(formatter.font(.regular, fontSize: .small))
                    .multilineTextAlignment(.trailing)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(formatter.color(.secondaryFG))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(formatter.color(.secondaryAccent), lineWidth: 2)
        )
        .padding(.horizontal, 4)
    }
}

