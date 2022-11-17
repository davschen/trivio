//
//  BuildView.swift
//  Trivio
//
//  Created by David Chen on 3/12/21.
//

import Foundation
import SwiftUI

struct BuildView: View {
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
            BuildHeaderView(showingEdit: $showingEdit, editingName: $editingName, showingSaveDraft: $showingSaveDraft)
            BuildHUDView()
            switch buildVM.currentDisplay {
            case .buildAll:
                EditClueResponseView(category: isDJ ? $buildVM.djCategories[categoryIndex] : $buildVM.jCategories[categoryIndex])
            case .finalTrivio:
                FinalTrivioFillView()
            case .settings:
                BuildDetailsView()
            case .saveDraft:
                SaveDraftView()
            default:
                BuildGridView(showingEdit: $showingEdit, categoryIndex: $categoryIndex)
            }
            Spacer(minLength: 0)
        }
        .padding([.horizontal, .bottom], 30)
        .padding(.top)
    }
}

struct BuildGridView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var showingEdit: Bool
    @Binding var categoryIndex: Int
    
    var isDJ: Bool {
        return buildVM.buildStage == .dtRound || buildVM.buildStage == .dtRoundDD
    }
    
    var body: some View {
        HStack (spacing: formatter.deviceType == .iPad ? 5 : 2) {
            ForEach(0..<(isDJ ? self.buildVM.djCategories.count : self.buildVM.jCategories.count), id: \.self) { i in
                let toShow = isDJ ? buildVM.djCategoriesShowing : buildVM.jCategoriesShowing
                if i <= (toShow.count - 1) && toShow[i] {
                    BuildCategoryView(categoryIndex: $categoryIndex,
                                      category: (isDJ ? $buildVM.djCategories[i] : $buildVM.jCategories[i]),
                                      index: i)
                }
            }
        }
    }
}
