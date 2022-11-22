//
//  MobileBuildView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileBuildView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var editingName = false
    @State var showingSaveDraft = false
    @State var categoryIndex = 0
    
    var isDJ: Bool {
        return buildVM.buildStage == .dtRound || buildVM.buildStage == .dtRoundDD
    }
    
    init() {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            if buildVM.currentDisplay != .buildAll {
                MobileBuildHUDView()
            }
            switch buildVM.currentDisplay {
            case .settings:
                Text("")
                MobileBuildDetailsView()
                    .padding(.horizontal)
            case .buildAll:
                MobileBuildAllView(category: isDJ ? $buildVM.djCategories[categoryIndex] : $buildVM.jCategories[categoryIndex], categoryIndex: $categoryIndex)
            case .finalTrivio:
                MobileFinalTrivioFillView()
                    .padding(.horizontal)
            case .saveDraft:
                MobileSaveDraftView()
                    .padding(.horizontal)
            default:
                MobileBuildGridView(categoryIndex: $categoryIndex)
            }
            if buildVM.currentDisplay != .buildAll {
                MobileBuildFooterView()
                    .padding(.horizontal)
            }
        }
        .withBackButton()
        .withBackground()
        .navigationTitle(buildVM.currCustomSet.title.isEmpty ? "Build set" : buildVM.currCustomSet.title)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
        .toolbar {
            ToolbarItem {
                Button(action: {
                    buildVM.writeToFirestore()  
                }) {
                    ZStack {
                        Text(buildVM.dirtyBit == 0 ? "Saved" : "Save")
                    }
                    .font(formatter.font(fontSize: .regular))
                    .foregroundColor(formatter.color(.primaryFG))
                    .padding(.horizontal).padding(.vertical, 5)
                    .background(formatter.color(buildVM.dirtyBit == 0 ? .lowContrastWhite : .highContrastWhite))
                    .clipShape(Capsule())
                }
                .opacity(buildVM.currCustomSet.title.isEmpty ? 0 : 1)
                .disabled(buildVM.dirtyBit == 0)
            }
        }
    }
}

struct MobileBuildGridView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel

    @Binding var categoryIndex: Int
    
    @State var isShowingPreview = false
    @State var showsDuplexExplanation = false
    
    var isDJ: Bool {
        return buildVM.buildStage == .dtRound || buildVM.buildStage == .dtRoundDD
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            if buildVM.buildStage == .trivioRound || buildVM.buildStage == .dtRound {
                MobileBuildGridEntryView(isShowingPreview: $isShowingPreview)
                    .frame(height: 20)
            } else if buildVM.buildStage == .trivioRoundDD || buildVM.buildStage == .dtRoundDD {
                VStack (alignment: .leading) {
                    HStack {
                        Text("Duplex of the Day")
                        Button {
                            showsDuplexExplanation.toggle()
                        } label: {
                            Image(systemName: showsDuplexExplanation ? "questionmark.circle.fill" : "questionmark.circle")
                                .font(formatter.iconFont(.small))
                        }
                        Spacer()
                        Button {
                            buildVM.randomDDs()
                        } label: {
                            Text("Random")
                                .font(formatter.font(fontSize: .small))
                                .padding(5)
                                .frame(width: 70)
                                .background(formatter.color(.green))
                                .clipShape(Capsule())
                        }

                    }
                    .frame(height: 20)
                    if showsDuplexExplanation {
                        Text("Pick \(buildVM.buildStage == .trivioRoundDD ? "a" : "two") clue\(buildVM.buildStage == .trivioRoundDD ? "" : "s") to serve as your duplex of the day.")
                            .font(formatter.font(.regularItalic, fontSize: .small))
                    }
                }
                .padding(.horizontal)
            }
            ScrollViewReader { scrollView in
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack (spacing: 5) {
                        Spacer()
                            .frame(width: 12)
                        ForEach(0..<(isDJ ? self.buildVM.djCategories.count : self.buildVM.jCategories.count), id: \.self) { i in
                            let toShow = isDJ ? buildVM.round2CatsShowing : buildVM.round1CatsShowing
                            if i <= (toShow.count - 1) && toShow[i] {
                                MobileBuildCategoryView(
                                    categoryIndex: $categoryIndex,
                                    category: (isDJ ? $buildVM.djCategories[i] : $buildVM.jCategories[i]),
                                    isShowingPreview: $isShowingPreview,
                                    index: i
                                ).id(i)
                            }
                        }
                        Spacer()
                            .frame(width: 12)
                    }
                }
                .onAppear {
                    if buildVM.editingCategoryIndex != 0 {
                        scrollView.scrollTo(buildVM.editingCategoryIndex, anchor: .center)
                    }
                }
            }
        }
    }
}

struct MobileBuildGridEntryView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var isShowingPreview: Bool
    
    var isDJ: Bool {
        return buildVM.buildStage == .dtRound || buildVM.buildStage == .dtRoundDD
    }
    
    var body: some View {
        HStack (spacing: 2) {
            Text("Categories (\(isDJ ? buildVM.currCustomSet.round2Len : buildVM.currCustomSet.round1Len))")
                .font(formatter.font(fontSize: .medium))
            Button {
                buildVM.subtractCategory()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(formatter.iconFont(.small))
                    .opacity(isDJ ? (buildVM.currCustomSet.round2Len == 3 ? 0.4 : 1) : (buildVM.currCustomSet.round1Len == 3 ? 0.4 : 1))
            }
            Button {
                buildVM.addCategory()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(formatter.iconFont(.small))
                    .opacity(isDJ ? (buildVM.currCustomSet.round2Len == 6 ? 0.4 : 1) : (buildVM.currCustomSet.round1Len == 6 ? 0.4 : 1))
            }
            Spacer()
            Text("Preview")
                .font(formatter.font(fontSize: .medium))
                .padding(.trailing, 3)
            ZStack(alignment: (isShowingPreview ? .trailing : .leading)) {
                Capsule()
                    .frame(width: 30, height: 15)
                    .foregroundColor(formatter.color(isShowingPreview ? .secondaryAccent : .primaryFG))
                Circle()
                    .frame(width: 15, height: 15)
            }
            .onTapGesture {
                isShowingPreview.toggle()
            }
            .animation(Animation.easeIn(duration: 0.05))
        }
        .padding(.horizontal).padding(.top, 7)
    }
}

