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
    
    @State var showingEdit = false
    @State var editingName = false
    @State var showingSaveDraft = false
    @State var categoryIndex = 0
    
    var isDJ: Bool {
        return buildVM.buildStage == .dtRound || buildVM.buildStage == .dtRoundDD
    }
    
    var isShowingGrid: Bool {
        return !showingEdit && !editingName && !showingSaveDraft
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            MobileBuildHeaderView(showingEdit: $showingEdit, editingName: $editingName, showingSaveDraft: $showingSaveDraft)
            MobileBuildHUDView()
                .padding(.horizontal)
            MobileBuildTickerView()
                .padding(.horizontal)
            switch buildVM.currentDisplay {
            case .clueResponse:
                MobileEditClueResponseView(category: isDJ ? $buildVM.djCategories[categoryIndex] : $buildVM.jCategories[categoryIndex])
                    .padding(.horizontal)
            case .categoryName:
                MobileEditCategoryNameView(category: isDJ ? $buildVM.djCategories[categoryIndex] : $buildVM.jCategories[categoryIndex])
                    .padding(.horizontal)
            case .finalTrivio:
                MobileFinalTrivioFillView()
                    .padding(.horizontal)
            case .finishingTouches:
                MobileBuildDetailsView()
                    .padding(.horizontal)
            case .saveDraft:
                MobileSaveDraftView()
                    .padding(.horizontal)
            default:
                MobileBuildGridView(showingEdit: $showingEdit, categoryIndex: $categoryIndex)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical)
    }
}

struct MobileBuildGridView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var showingEdit: Bool
    @Binding var categoryIndex: Int
    
    var isDJ: Bool {
        return buildVM.buildStage == .dtRound || buildVM.buildStage == .dtRoundDD
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text(buildVM.stepStringHandler())
                .font(formatter.font(fontSize: .mediumLarge))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal)
            ScrollViewReader { scrollView in
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack (spacing: 5) {
                        Spacer()
                            .frame(width: 12)
                        ForEach(0..<(isDJ ? self.buildVM.djCategories.count : self.buildVM.jCategories.count), id: \.self) { i in
                            let toShow = isDJ ? buildVM.djCategoriesShowing : buildVM.jCategoriesShowing
                            if i <= (toShow.count - 1) && toShow[i] {
                                MobileBuildCategoryView(categoryIndex: $categoryIndex,
                                                  category: (isDJ ? $buildVM.djCategories[i] : $buildVM.jCategories[i]),
                                                  index: i).id(i)
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

