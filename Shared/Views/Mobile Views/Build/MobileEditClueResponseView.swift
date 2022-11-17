//
//  MobileEditClueResponseView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileEditClueResponseView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var category: CustomSetCategory
    
    @State var swapToIndex = -1
    @State var showingPreview = false
    @State var showingInstructions = false
    
    var body: some View {
        VStack (spacing: 0) {
            
            // Category name header
            ZStack {
                VStack {
                    Text("\(category.name.uppercased())")
                    Text("$\(buildVM.moneySections[buildVM.editingClueIndex])")
                        .foregroundColor(formatter.color(.secondaryAccent))
                }
                .font(formatter.font())
                .multilineTextAlignment(.center)
                .padding()
                .background(formatter.color(.lowContrastWhite))
                .cornerRadius(5)
                .padding(.horizontal)
                if showingPreview {
                    Button {
                        showingPreview.toggle()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(formatter.iconFont(.mediumLarge))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(formatter.color(.primaryAccent))
            
            if showingPreview {
                MobileBuildPreviewClueResponseView(categoryName: category.name,
                                             clue: category.clues[buildVM.editingClueIndex],
                                             response: category.responses[buildVM.editingClueIndex])
            } else {
                ScrollView (.vertical, showsIndicators: false) {
                    
                    // Clue and response textfields with titles
                    VStack (alignment: .leading, spacing: 20) {
                        VStack (alignment: .leading, spacing: 5) {
                            Text("CLUE")
                                .font(formatter.font(fontSize: .mediumLarge))
                            MobileMultilineTextField("ENTER A CLUE", text: $category.clues[buildVM.editingClueIndex]) {
                                
                            }
                            .accentColor(formatter.color(.secondaryAccent))
                            .background(formatter.color(.lowContrastWhite))
                            .cornerRadius(5)
                        }
                        VStack (alignment: .leading, spacing: 5) {
                            Text("CORRECT RESPONSE")
                                .font(formatter.font(fontSize: .mediumLarge))
                                .foregroundColor(formatter.color(.secondaryAccent))
                            MobileMultilineTextField("ENTER A RESPONSE", text: $category.responses[buildVM.editingClueIndex]) {
                                
                            }
                            .accentColor(formatter.color(.secondaryAccent))
                            .background(formatter.color(.lowContrastWhite))
                            .cornerRadius(5)
                        }
                    }
                    
                    // Preview and Done buttons
                    HStack (spacing: 5) {
                        Spacer()
                        
                        Button(action: {
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
                            showingPreview.toggle()
                        }, label: {
                            Text("Preview")
                                .font(formatter.font())
                                .padding()
                                .padding(.horizontal)
                                .background(formatter.color(.lowContrastWhite))
                                .clipShape(Capsule())
                        })
                        
                        Button(action: {
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
                            buildVM.currentDisplay = .grid
                        }, label: {
                            Text("Done")
                                .font(formatter.font())
                                .padding()
                                .padding(.horizontal)
                                .background(formatter.color(.lowContrastWhite))
                                .clipShape(Capsule())
                        })
                    }
                    
                    VStack (alignment: .leading) {
                        VStack (alignment: .leading, spacing: 3) {
                            HStack {
                                Text("SWAP")
                                    .font(formatter.font(fontSize: .mediumLarge))
                                if swapToIndex != -1 {
                                    Button {
                                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                                        buildVM.swap(currentIndex: buildVM.editingCategoryIndex, swapToIndex: swapToIndex, categoryIndex: category.index)
                                        swapToIndex = -1
                                    } label: {
                                        Text("GO!")
                                            .font(formatter.font(fontSize: .mediumLarge))
                                            .foregroundColor(formatter.color(.secondaryAccent))
                                    }
                                }
                                Button {
                                    showingInstructions.toggle()
                                } label: {
                                    Image(systemName: showingInstructions ? "questionmark.circle.fill" : "questionmark.circle")
                                        .font(formatter.iconFont(.small))
                                }
                            }
                            if showingInstructions {
                                Text("Tap on the tile you'd like to swap with. Hold to preview.")
                                    .font(formatter.font(.regularItalic))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        ScrollView (.horizontal, showsIndicators: false) {
                            HStack (spacing: formatter.deviceType == .iPad ? nil : 5) {
                                ForEach(0..<category.clues.count, id: \.self) { i in
                                    Text("Hi I am now defunct")
                                }
                            }
                            .frame(height: 80)
                        }
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal)
            }
        }
        .background(formatter.color(.primaryAccent))
        .cornerRadius(20)
    }
}

struct MobileBuildPreviewClueResponseView: View {
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
                    .minimumScaleFactor(0.5)
                
                if isShowingResponse {
                    Text(response.uppercased())
                        .foregroundColor(formatter.color(.secondaryAccent))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                }
            }
            .font(formatter.font(fontSize: .mediumLarge))
            Spacer()
            Button {
                formatter.hapticFeedback(style: .soft, intensity: .strong)
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

