//
//  EditClueResponseView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct EditClueResponseView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var category: Category
    
    @State var swapToIndex = -1
    @State var showingPreview = false
    @State var showingInstructions = false
    
    var body: some View {
        VStack (spacing: 0) {
            
            // Category name header
            ZStack {
                if showingPreview {
                    Button {
                        showingPreview.toggle()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 30, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                    }
                }
                Text("\(self.category.name.uppercased()) - $\(buildVM.moneySections[buildVM.editingIndex])")
                    .font(formatter.font(fontSize: .mediumLarge))
                    .padding(20)
                    .background(formatter.color(.lowContrastWhite))
                    .cornerRadius(5)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(20)
            .background(formatter.color(.primaryAccent))
            
            if showingPreview {
                BuildPreviewClueResponseView(categoryName: category.name,
                                             clue: category.clues[buildVM.editingIndex],
                                             response: category.responses[buildVM.editingIndex])
            } else {
                ScrollView (.vertical, showsIndicators: false) {
                    
                    // Clue and response textfields with titles
                    VStack (alignment: .leading, spacing: 20) {
                        VStack (alignment: .leading, spacing: 5) {
                            Text("CLUE")
                                .font(formatter.font(fontSize: .large))
                            MultilineTextField("ENTER A CLUE", text: $category.clues[buildVM.editingIndex]) {
                                
                            }
                            .accentColor(formatter.color(.secondaryAccent))
                            .background(formatter.color(.lowContrastWhite))
                            .cornerRadius(10)
                        }
                        VStack (alignment: .leading, spacing: 5) {
                            Text("CORRECT RESPONSE")
                                .font(formatter.font(fontSize: .large))
                                .foregroundColor(formatter.color(.secondaryAccent))
                            MultilineTextField("ENTER A RESPONSE", text: $category.responses[buildVM.editingIndex]) {
                                
                            }
                            .accentColor(formatter.color(.secondaryAccent))
                            .background(formatter.color(.lowContrastWhite))
                            .cornerRadius(10)
                        }
                    }
                    
                    // Preview and Done buttons
                    HStack (spacing: 10) {
                        Spacer()
                        
                        Button(action: {
                            showingPreview.toggle()
                        }, label: {
                            Text("Preview")
                                .font(formatter.font())
                                .padding(20)
                                .padding(.horizontal, 20)
                                .background(formatter.color(.lowContrastWhite))
                                .clipShape(Capsule())
                        })
                        
                        Button(action: {
                            buildVM.currentDisplay = .grid
                        }, label: {
                            Text("Done")
                                .font(formatter.font())
                                .padding(20)
                                .padding(.horizontal, 20)
                                .background(formatter.color(.lowContrastWhite))
                                .clipShape(Capsule())
                        })
                    }
                    
                    VStack (alignment: .leading) {
                        VStack (alignment: .leading, spacing: 3) {
                            HStack {
                                Text("SWAP")
                                    .font(formatter.font(fontSize: .large))
                                if swapToIndex != -1 {
                                    Button {
                                        buildVM.swap(currentIndex: buildVM.editingIndex, swapToIndex: swapToIndex, categoryIndex: category.index)
                                        swapToIndex = -1
                                    } label: {
                                        Text("GO!")
                                            .font(formatter.font(fontSize: .large))
                                            .foregroundColor(formatter.color(.secondaryAccent))
                                    }
                                }
                                Button {
                                    showingInstructions.toggle()
                                } label: {
                                    Image(systemName: showingInstructions ? "questionmark.circle.fill" : "questionmark.circle")
                                        .font(.system(size: 25, weight: .bold))
                                }
                            }
                            if showingInstructions {
                                Text("Tap on the tile you'd like to swap with. Hold to preview.")
                                    .font(formatter.font(.regularItalic))
                            }
                        }
                        
                        HStack (spacing: formatter.deviceType == .iPad ? nil : 5) {
                            ForEach(0..<category.clues.count, id: \.self) { i in
                                SwapCellView(editingIndex: $buildVM.editingIndex, preSwapIndex: $swapToIndex, clueIndex: i, amount: buildVM.moneySections[i], clue: category.clues[i], response: category.responses[i])
                            }
                        }
                        .frame(height: 120)
                    }
                    .padding(.bottom, 30)
                }
                .padding([.horizontal], 30)
            }
        }
        .background(formatter.color(.primaryAccent))
        .cornerRadius(30)
        .keyboardAware()
    }
}

struct BuildPreviewClueResponseView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @State var isShowingResponse = false
    
    var categoryName: String
    var clue: String
    var response: String
    
    var body: some View {
        VStack {
            Spacer()
            VStack (spacing: 30) {
                Text(clue.uppercased())
                    .multilineTextAlignment(.center)
                
                if isShowingResponse {
                    Text(response.uppercased())
                        .foregroundColor(formatter.color(.secondaryAccent))
                        .multilineTextAlignment(.center)
                }
            }
            .font(formatter.font(fontSize: .large))
            Spacer()
            Button {
                isShowingResponse.toggle()
            } label: {
                Text(isShowingResponse ? "Hide Response" : "Show Response")
                    .font(formatter.font(fontSize: .mediumLarge))
                    .padding(20)
                    .padding(.horizontal, 20)
                    .background(formatter.color(.lowContrastWhite).opacity(isShowingResponse ? 1 : 0.5))
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(30)
    }
}
