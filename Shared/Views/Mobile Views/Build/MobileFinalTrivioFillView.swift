//
//  MobileFinalTrivioFillView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileFinalTrivioFillView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    
    @EnvironmentObject var formatter: MasterHandler
    
    @State var categoryName = ""
    @State var finalClue = ""
    @State var finalResponse = ""
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (alignment: .leading, spacing: 15) {
                VStack (alignment: .leading, spacing: 3) {
                    Text("Category name")
                        .font(formatter.font(fontSize: .medium))
                        .padding(.top, 20)
                    ZStack (alignment: .leading) {
                        if categoryName.isEmpty {
                            Text("Untitled")
                                .font(formatter.font(.boldItalic, fontSize: .medium))
                                .foregroundColor(formatter.color(.lowContrastWhite))
                        }
                        TextField("", text: $categoryName) { editingChanged in
                            buildVM.fjCategory = categoryName
                        }
                    }
                    .font(formatter.font(.bold, fontSize: .medium))
                    .padding(20)
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(5)
                    .onAppear {
                        categoryName = buildVM.fjCategory
                        finalClue = buildVM.fjClue
                        finalResponse = buildVM.fjResponse
                    }
                }
                
                VStack (alignment: .leading, spacing: 3) {
                    Text("Clue")
                        .font(formatter.font(fontSize: .medium))
                    MobileMultilineTextField("Type your clue", text: $finalClue) {
                        buildVM.fjClue = finalClue
                    }
                    .accentColor(formatter.color(.secondaryAccent))
                    .padding(10)
                    .background(formatter.color(.secondaryFG))
                    .cornerRadius(5)
                }
                
                VStack (alignment: .leading, spacing: 3) {
                    Text("Correct response")
                        .font(formatter.font(fontSize: .medium))
                        .foregroundColor(formatter.color(.secondaryAccent))
                    MobileMultilineTextField("Type your response", text: $finalResponse) {
                        buildVM.fjResponse = finalResponse
                    }
                    .accentColor(formatter.color(.secondaryAccent))
                    .padding(10)
                    .background(formatter.color(.secondaryFG))
                    .cornerRadius(5)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

