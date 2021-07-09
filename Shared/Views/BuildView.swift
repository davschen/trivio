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
    @EnvironmentObject var searchVM: SearchViewModel
    @EnvironmentObject var buildVM: BuildViewModel
    @State var showingEdit = false
    @State var editingName = false
    @State var showingSaveDraft = false
    @State var categoryIndex = 0
    @Environment(\.colorScheme) var colorScheme
    var isDJ: Bool {
        return buildVM.buildStage == .djRound || buildVM.buildStage == .djRoundDD
    }
    
    var isShowingGrid: Bool {
        return !showingEdit && !editingName && !showingSaveDraft
    }
    
    var body: some View {
        ZStack {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
            VStack (alignment: .leading, spacing: 0) {
                HStack {
                    let stepString = self.buildVM.stepStringHandler()
                    if isShowingGrid {
                        Button(action: {
                            formatter.setAlertSettings(alertAction: {
                                buildVM.showingBuildView.toggle()
                            },
                            alertTitle: "Save Before Leaving?",
                            alertSubtitle: "If you go leave without saving, all of your progress will be lost",
                            hasCancel: true,
                            actionLabel: "Leave without saving",
                            hasSecondaryAction: true,
                            secondaryAction: {
                                if buildVM.isEditing && !buildVM.isEditingDraft {
                                    buildVM.writeToFirestore { (success) in
                                        if success {
                                            buildVM.showingBuildView.toggle()
                                        }
                                    }
                                } else {
                                    showingSaveDraft.toggle()
                                }
                            },
                            secondaryActionLabel: buildVM.isEditing ? "Save" : "Save draft")
                        }, label: {
                            Image(systemName: "chevron.left")
                                .font(formatter.deviceType == .iPad ? .largeTitle : .subheadline)
                        })
                    }
                    Text("\(buildVM.isEditing ? "Edit" : "Build") - \(stepString)")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 50))
                        .minimumScaleFactor(0.1)
                    Spacer()
                    HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                        Button(action: {
                            if buildVM.isEditing && !buildVM.isEditingDraft {
                                buildVM.writeToFirestore { (success) in
                                    if success {
                                        buildVM.showingBuildView.toggle()
                                    }
                                }
                            } else {
                                showingSaveDraft.toggle()
                            }
                        }) {
                            Text("Save")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                                .minimumScaleFactor(0.1)
                                .padding(.all, formatter.deviceType == .iPad ? 15 : 10)
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(formatter.cornerRadius(5))
                        }
                        Button(action: {
                            if self.buildVM.nextPermitted() {
                                self.buildVM.nextButtonHandler()
                            }
                        }, label: {
                            Text(buildVM.buildStage == .details ? "Finish" : "Next")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                                .minimumScaleFactor(0.1)
                                .padding(.all, formatter.deviceType == .iPad ? 15 : 10)
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(formatter.cornerRadius(5))
                                .opacity(self.buildVM.nextPermitted() ? 1 : 0.4)
                        })
                        
                        if buildVM.processPending {
                            ProgressView()
                                .padding(.leading, 5)
                        }
                    }
                }
                HUDView(showingEdit: $showingEdit, editingName: $editingName)
                ZStack {
                    if buildVM.buildStage == .finalJeopardy {
                        FinalJeopardyFillView()
                    } else if buildVM.buildStage == .details {
                        BuildDetailsView()
                    } else {
                        if isShowingGrid {
                            HStack (spacing: formatter.deviceType == .iPad ? 5 : 2) {
                                ForEach(0..<(isDJ ? self.buildVM.djCategories.count : self.buildVM.jCategories.count), id: \.self) { i in
                                    let toShow = isDJ ? buildVM.djCategoriesShowing : buildVM.jCategoriesShowing
                                    if i <= (toShow.count - 1) && toShow[i] {
                                        CategoryView(showingEdit: $showingEdit,
                                                     categoryIndex: $categoryIndex,
                                                     category: (isDJ ? $buildVM.djCategories[i] : $buildVM.jCategories[i]),
                                                     editingName: $editingName,
                                                     index: i)
                                    }
                                }
                            }
                        } else if self.showingEdit {
                            EditClueResponseView(category: isDJ ? $buildVM.djCategories[categoryIndex] : $buildVM.jCategories[categoryIndex],
                                                 showingEdit: $showingEdit,
                                                 index: self.buildVM.editingIndex)
                        } else if self.editingName {
                            EditCategoryNameView(category: isDJ ? $buildVM.djCategories[categoryIndex] : $buildVM.jCategories[categoryIndex],
                                                 editingName: $editingName)
                        }
                        if showingSaveDraft {
                            SaveDraftView(showingSaveDraft: $showingSaveDraft)
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct CategoryView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @Binding var showingEdit: Bool
    @Binding var categoryIndex: Int
    @Binding var category: Category
    @Binding var editingName: Bool
    @State var index: Int
    @State var isHeld = -1
    
    var isDJ: Bool {
        return buildVM.buildStage == .djRound
    }
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack (spacing: formatter.deviceType == .iPad ? 10 : 5) {
            Text(self.category.name.isEmpty ? "ADD NAME" : self.category.name.uppercased())
                .font(formatter.customFont(weight: category.name.isEmpty ? "Bold Italic" : "Bold", iPadSize: formatter.shrink(iPadSize: 20)))
                .foregroundColor(Color.white.opacity(self.category.name.isEmpty ? 0.5 : 1))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.1)
                .padding(.horizontal, 5)
                .frame(maxWidth: .infinity)
                .frame(height: formatter.deviceType == .iPad ? 150 : 60)
                .background(Color("MainFG"))
                .cornerRadius(formatter.cornerRadius(5))
                .onTapGesture {
                    if buildVM.buildStage == .jeopardyRoundDD || buildVM.buildStage == .djRoundDD {
                        return
                    }
                    self.editingName.toggle()
                    if isDJ {
                        buildVM.djCategories[index].setIndex(index: index)
                    } else {
                        buildVM.jCategories[index].setIndex(index: index)
                    }
                    self.categoryIndex = index
                }
            VStack (spacing: formatter.deviceType == .iPad ? 5 : 2) {
                ForEach(0..<category.clues.count) { i in
                    let amount = buildVM.moneySections[i]
                    let clue = category.clues[i]
                    let response = category.responses[i]
                    BuildCellView(showingEdit: $showingEdit, isHeld: $isHeld, categoryIndex: $categoryIndex, category: $category, index: $index, i: i, amount: amount, clue: clue, response: response)
                }
            }
        }
    }
}

struct BuildCellView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @Binding var showingEdit: Bool
    @Binding var isHeld: Int
    @Binding var categoryIndex: Int
    @Binding var category: Category
    @Binding var index: Int
    var i: Int
    var amount: String
    var clue: String
    var response: String
    var isDJ: Bool {
        return buildVM.buildStage == .djRound || buildVM.buildStage == .djRoundDD
    }
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack {
            if isHeld == i {
                HStack {
                    VStack (alignment: .leading) {
                        VStack (alignment: .leading, spacing: 0) {
                            Text("CLUE")
                                .padding(2)
                                .background(Color.white.opacity(0.4))
                                .cornerRadius(3)
                            Text(buildVM.cluePreview)
                        }
                        VStack (alignment: .leading, spacing: 0) {
                            Text("RESPONSE")
                                .padding(2)
                                .background(Color.white.opacity(0.4))
                                .cornerRadius(3)
                            Text(buildVM.responsePreview)
                        }
                    }
                    .font(formatter.customFont(weight: "Bold", iPadSize: formatter.shrink(iPadSize: 14)))
                    Spacer()
                }
                .padding(10)
            } else {
                ZStack {
                    Text("$\(amount)")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 40))
                        .minimumScaleFactor(0.1)
                        .foregroundColor((clue.isEmpty || response.isEmpty) ? Color("LoMainAccent") : Color("MainAccent"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    if (buildVM.buildStage == .jeopardyRound) || (buildVM.buildStage == .djRound) {
                        VStack {
                            HStack {
                                Spacer(minLength: 0)
                                Image(systemName: (clue.isEmpty || response.isEmpty) ? "plus.circle.fill" : "pencil.circle.fill")
                                    .font(formatter.deviceType == .iPad ? .title : .subheadline)
                                    .foregroundColor(.white)
                                    .opacity(category.name.isEmpty ? 0 : 0.5)
                                    .padding(5)
                            }
                            Spacer(minLength: 0)
                        }
                        .minimumScaleFactor(0.1)
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 5).stroke(
            (buildVM.buildStage == .jeopardyRound || buildVM.buildStage == .djRound) ? Color("MainFG") : Color.white,
            lineWidth: self.buildVM.isDailyDouble(i: category.index, j: i) ? formatter.shrink(iPadSize: 10) : 0
        ))
        .background((clue.isEmpty || response.isEmpty) ? Color("LoMainFG") : Color("MainFG"))
        .cornerRadius(formatter.cornerRadius(5))
        .onTapGesture {
            if buildVM.buildStage == .jeopardyRoundDD
                || buildVM.buildStage == .djRoundDD
                && !(category.clues[i].isEmpty || category.responses[i].isEmpty) {
                buildVM.addDailyDouble(i: category.index, j: i)
            } else if !category.name.isEmpty {
                showingEdit.toggle()
                buildVM.setEditingIndex(index: i)
                categoryIndex = index
            }
        }
        .onLongPressGesture(minimumDuration: 1, pressing: { inProgress in
            if (!clue.isEmpty || !response.isEmpty) {
                buildVM.setPreviews(clue: clue, response: response)
                isHeld = inProgress ? i : -1
            }
        }) {
            isHeld = -1
        }
    }
}

struct HUDView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var showingEdit: Bool
    @Binding var editingName: Bool
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack (spacing: 30) {
                if buildVM.buildStage != .jeopardyRound {
                    Button {
                        self.buildVM.back()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(formatter.deviceType == .iPad ? .title : .subheadline)
                            Text(self.buildVM.backStringHandler())
                                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                        }
                        .foregroundColor(.white)
                    }
                }
                HStack {
                    Text("\(self.buildVM.descriptionHandler())")
                        .foregroundColor(Color("MainAccent"))
                    Spacer()
                        .frame(width: 30)
                    if buildVM.buildStage == .jeopardyRoundDD || buildVM.buildStage == .djRoundDD {
                        Text("Selection:")
                        Text("Random")
                            .padding(5)
                            .background(Color.gray.opacity(self.buildVM.isRandomDD ? 1 : 0))
                            .cornerRadius(5)
                            .onTapGesture {
                                if !self.buildVM.isRandomDD {
                                    self.buildVM.randomDDs()
                                }
                                self.buildVM.isRandomDD = true
                            }
                        Text("Manual")
                            .padding(5)
                            .background(Color.gray.opacity(self.buildVM.isRandomDD ? 0 : 1))
                            .cornerRadius(5)
                            .onTapGesture {
                                if self.buildVM.isRandomDD {
                                    self.buildVM.clearDailyDoubles()
                                }
                                self.buildVM.isRandomDD = false
                            }
                        Image(systemName: "checkmark.circle.fill")
                            .font(formatter.deviceType == .iPad ? .title : .subheadline)
                            .foregroundColor(Color.green.opacity(self.buildVM.ddsFilled() ? 1 : 0.2))
                    } else if buildVM.buildStage == .jeopardyRound || buildVM.buildStage == .djRound {
                        HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                            Text("Categories: ")
                            Button(action: {
                                buildVM.subtractCategory(index: 0, last: true)
                            }, label: {
                                Image(systemName: "minus")
                                    .foregroundColor(.white)
                                    .font(formatter.deviceType == .iPad ? .title2 : .subheadline)
                                    .frame(height: formatter.shrink(iPadSize: 50, factor: 1.7))
                                    .padding(.horizontal, formatter.shrink(iPadSize: 14))
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(3)
                            })
                            Text("\(buildVM.buildStage == .jeopardyRound ? buildVM.jRoundLen : buildVM.djRoundLen)")
                                .frame(height: formatter.shrink(iPadSize: 50, factor: 1.7))
                                .padding(.horizontal, formatter.shrink(iPadSize: 20))
                                .background(Color.white.opacity(0.4))
                                .cornerRadius(3)
                            Button(action: {
                                buildVM.addCategory()
                            }, label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(formatter.deviceType == .iPad ? .title2 : .subheadline)
                                    .frame(height: formatter.shrink(iPadSize: 50, factor: 1.7))
                                    .padding(.horizontal, formatter.shrink(iPadSize: 14))
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(3)
                            })
                        }
                        .padding(.vertical, 7)
                        .opacity((editingName || showingEdit) ? 0 : 1)
                    }
                }
                .font(formatter.customFont(weight: "Bold", iPadSize: formatter.shrink(iPadSize: 20, factor: 1.5)))
            }
        }
        .padding(formatter.padding())
        .frame(height: formatter.shrink(iPadSize: 60, factor: 1.7))
        .background(Color.white.opacity(0.1))
        .cornerRadius(formatter.cornerRadius(5))
        .padding(.vertical, 5)
    }
}

struct EditClueResponseView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @Binding var category: Category
    @Binding var showingEdit: Bool
    @State var index: Int
    @State var isPreview = false
    @State var swapToIndex = -1
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack {
            ScrollView (.vertical) {
                VStack (alignment: .leading) {
                    HStack {
                        Spacer()
                        Text("\(self.category.name.uppercased()) - $\(buildVM.moneySections[index])")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            .foregroundColor(.white)
                            .padding(formatter.padding())
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                            .padding(formatter.padding())
                        Spacer()
                    }
                    VStack (alignment: .leading, spacing: 5) {
                        Text("CLUE")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                            .padding(formatter.padding())
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                        MultilineTextField("Enter a clue", text: $category.clues[index], color: Color("MainAccent")) {
                            
                        }
                        .accentColor(.white)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(5)
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack (alignment: .leading, spacing: 5) {
                        Text("CORRECT RESPONSE")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                            .foregroundColor(Color("MainAccent"))
                            .padding(formatter.padding())
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                        MultilineTextField("Enter a response", text: $category.responses[index]) {
                            
                        }
                        .accentColor(.white)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(5)
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showingEdit.toggle()
                        }, label: {
                            Text("Done")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                .foregroundColor(Color("MainAccent"))
                                .padding()
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(5.0)
                        })
                    }
                }
                VStack (alignment: .leading) {
                    VStack (alignment: .leading, spacing: 3) {
                        HStack {
                            Text("SWAP (Category: \(category.name.uppercased()))")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                                .padding(formatter.padding())
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(5)
                            if swapToIndex != -1 {
                                Button {
                                    buildVM.swap(currentIndex: index, swapToIndex: swapToIndex, categoryIndex: category.index)
                                    swapToIndex = -1
                                } label: {
                                    Text("GO!")
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                                        .foregroundColor(Color("MainAccent"))
                                        .padding(formatter.padding())
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(5)
                                }
                            }
                        }
                        Text("Tap on the tile you'd like to swap with. Hold to preview.")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                    }
                    HStack (spacing: formatter.deviceType == .iPad ? nil : 5) {
                        ForEach(0..<category.clues.count, id: \.self) { i in
                            SwapBlockView(clueIndex: i, editingIndex: $index, preSwapIndex: $swapToIndex, amount: buildVM.moneySections[i], clue: category.clues[i], response: category.responses[i])
                        }
                    }
                    .frame(height: formatter.shrink(iPadSize: 150))
                }
            }
            .padding(.horizontal, formatter.padding())
        }
        .background(Color("MainFG"))
        .cornerRadius(5)
        .keyboardAware()
    }
}

struct SwapBlockView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @State var isHeld = -1
    @State var clueIndex: Int
    @Binding var editingIndex: Int
    @Binding var preSwapIndex: Int
    
    var amount: String
    var clue: String
    var response: String
    
    var body: some View {
        ZStack {
            if isHeld == clueIndex {
                if !clue.isEmpty || !response.isEmpty {
                    HStack {
                        VStack (alignment: .leading) {
                            VStack (alignment: .leading, spacing: 0) {
                                Text("CLUE")
                                    .padding(2)
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(3)
                                Text(buildVM.cluePreview)
                                    .lineLimit(1)
                            }
                            VStack (alignment: .leading, spacing: 0) {
                                Text("RESPONSE")
                                    .padding(2)
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(3)
                                Text(buildVM.responsePreview)
                                    .lineLimit(1)
                            }
                        }
                        .font(formatter.customFont(weight: "Bold", iPadSize: formatter.shrink(iPadSize: 14)))
                        Spacer()
                    }
                    .padding(10)
                } else {
                    Text("This Tile is Empty")
                        .font(formatter.customFont(weight: "Bold Italic", iPadSize: formatter.shrink(iPadSize: 20)))
                        .foregroundColor(.white.opacity(0.75))
                }
                
            } else {
                Text("$\(amount)")
                    .font(formatter.customFont(weight: "Bold", iPadSize: 40))
                    .foregroundColor((clue.isEmpty || response.isEmpty) ? Color("LoMainAccent") : Color("MainAccent"))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 5).stroke(preSwapIndex == clueIndex ? Color.white : Color.clear, lineWidth: preSwapIndex == clueIndex ? 10 : 0))
        .background(editingIndex == clueIndex ? Color("LoMainFG") : Color("MainFG"))
        .cornerRadius(formatter.cornerRadius(5))
        .shadow(radius: 5)
        .padding([.bottom, .horizontal], 5)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            if preSwapIndex == clueIndex {
                preSwapIndex = -1
            } else if clueIndex != editingIndex {
                preSwapIndex = clueIndex
            }
        }
        .onLongPressGesture(minimumDuration: 1, pressing: { inProgress in
            buildVM.setPreviews(clue: clue, response: response)
            isHeld = inProgress ? clueIndex : -1
        }) {
            isHeld = -1
        }
    }
}

struct EditCategoryNameView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @Binding var category: Category
    @Binding var editingName: Bool
    @State var offsetValue: CGFloat = 0
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack (spacing: formatter.shrink(iPadSize: 20)) {
            CategoryLargeView(categoryName: category.name)
            Text("CATEGORY NAME")
                .font(formatter.customFont(weight: "Bold", iPadSize: 50))
            HStack {
                HStack {
                    TextField("Add a category name", text: $category.name, onCommit: {
                        editingName.toggle()
                    })
                    .accentColor(.white)
                    .foregroundColor(.white)
                    .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .onTapGesture {
                            category.name.removeAll()
                        }
                }
                .padding(formatter.padding())
                .background(Color.white.opacity(0.1))
                .cornerRadius(5)
                Button(action: {
                    editingName.toggle()
                }, label: {
                    Text("Done")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                        .foregroundColor(Color("MainAccent"))
                        .padding(formatter.padding())
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(5.0)
                })
            }
            .padding(.horizontal, 30)
            .frame(width: UIScreen.main.bounds.width / 2)
            .keyboardAware()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("MainFG"))
        .cornerRadius(5)
    }
}

struct FinalJeopardyFillView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack {
            ScrollView (.vertical) {
                VStack (alignment: .leading) {
                    HStack {
                        Spacer()
                        CategoryLargeView(categoryName: buildVM.fjCategory)
                        Spacer()
                    }
                    Text("CATEGORY")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(5)
                    HStack {
                        TextField("Add a category name", text: $buildVM.fjCategory)
                            .accentColor(.white)
                            .foregroundColor(.white)
                            .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .onTapGesture {
                                self.buildVM.fjCategory.removeAll()
                            }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(5)
                    Spacer()
                        .frame(height: 20)
                    Text("CLUE")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(5)
                    MultilineTextField("Enter a clue", text: $buildVM.fjClue, color: Color("MainAccent")) {
                        
                    }
                    .accentColor(.white)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(5)
                    Spacer()
                        .frame(height: 20)
                    Text("CORRECT RESPONSE")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                        .foregroundColor(Color("MainAccent"))
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(5)
                    MultilineTextField("Enter a response", text: $buildVM.fjResponse) {
                        
                    }
                    .accentColor(.white)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(5)
                }
                .padding()
            }
        }
        .background(Color("MainFG"))
        .cornerRadius(10)
        .keyboardAware()
    }
}

struct BuildDetailsView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @State var selectedTag = ""
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack {
            ScrollView (.vertical) {
                VStack (alignment: .leading) {
                    Text("TITLE")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(5)
                    TextField("Title your set", text: $buildVM.setName)
                        .accentColor(.white)
                        .foregroundColor(.white)
                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(5)
                    Spacer()
                        .frame(height: 20)
                    VStack (alignment: .leading, spacing: 3) {
                        Text("TAGS")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                            .frame(alignment: .leading)
                        Text("Tags are single words that describe your set. If your set is public, tags will help people discover your set. You must have at least two tags.")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            .frame(alignment: .leading)
                        FlexibleView(data: buildVM.tags, spacing: 8, alignment: .leading) { item in
                            HStack (spacing: 0) {
                                Text("#")
                                Text(verbatim: item.uppercased())
                                if selectedTag == item {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .onTapGesture {
                                            buildVM.removeTag(tag: item)
                                        }
                                        .padding(.leading, 5)
                                }
                            }
                            .foregroundColor(selectedTag == item ? Color("MainBG") : Color("MainAccent"))
                            .font(formatter.customFont(weight: "Bold Italic", iPadSize: 20))
                            .padding(10)
                            .background(Color.white.opacity(selectedTag == item ? 1 : 0.4))
                            .cornerRadius(5)
                            .onTapGesture {
                                selectedTag = selectedTag == item ? "" : item
                            }
                        }
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(formatter.deviceType == .iPad ? .largeTitle : .title3)
                                .onTapGesture {
                                    buildVM.addTag()
                                }
                            TextField("Add tag", text: $buildVM.tag)
                                .accentColor(.white)
                                .foregroundColor(.white)
                                .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(5)
                        .padding(.top, 15)
                    }
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        Text("Make this set public?")
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(5)
                        Text("Yes")
                            .padding(10)
                            .background(Color.white.opacity(buildVM.isPublic ? 0.1 : 0))
                            .cornerRadius(5)
                            .onTapGesture {
                                buildVM.isPublic = true
                            }
                        Text("No")
                            .padding(10)
                            .background(Color.white.opacity(buildVM.isPublic ? 0 : 0.1))
                            .cornerRadius(5)
                            .onTapGesture {
                                buildVM.isPublic = false
                            }
                    }
                    .foregroundColor(.white)
                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                }
                .padding(30)
            }
            .background(Color("MainFG"))
            .cornerRadius(10)
            .keyboardAware()
        }
    }
}

struct SaveDraftView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @Binding var showingSaveDraft: Bool
    
    var body: some View {
        ZStack {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
                .opacity(0.5)
            VStack {
                Text("SAVE DRAFT")
                    .font(formatter.customFont(weight: "Bold", iPadSize: 50))
                HStack {
                    HStack {
                        TextField("Title your draft", text: $buildVM.setName, onCommit: {
                            buildVM.saveDraft()
                            showingSaveDraft.toggle()
                        })
                        .accentColor(.white)
                        .foregroundColor(.white)
                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .onTapGesture {
                                buildVM.setName.removeAll()
                            }
                    }
                    .padding(formatter.padding())
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(5)
                    Button(action: {
                        showingSaveDraft.toggle()
                        buildVM.saveDraft()
                    }, label: {
                        HStack {
                            Text("Save")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            if buildVM.processPending {
                                ProgressView()
                                    .padding(.leading, 5)
                            }
                        }
                        .foregroundColor(Color("MainAccent"))
                        .padding(formatter.padding())
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(5.0)
                    })
                    Button {
                        showingSaveDraft.toggle()
                    } label: {
                        Text("Cancel")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                    }
                    .padding(formatter.padding())
                }
                .padding(formatter.padding())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("MainFG"))
            .cornerRadius(10)
            .padding(formatter.padding())
            .keyboardAware()
        }
    }
}

struct CategoryLargeView: View {
    var categoryName: String
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        HStack {
            Spacer()
            Text(categoryName.uppercased())
                .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.1)
                .frame(width: formatter.shrink(iPadSize: 300), height: formatter.shrink(iPadSize: 150))
                .padding(5)
                .background(Color("MainFG"))
                .cornerRadius(5)
                .shadow(radius: 10)
                .padding()
            Spacer()
        }
    }
}
