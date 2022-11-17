//
//  MobileBuildDetailsView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileBuildDetailsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @State var selectedTag = ""
    @State var showingInstructions = false
    @State var setTitle = ""
    @State var setDescription = ""
    @State var tagString = ""
    
    init() {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (alignment: .leading, spacing: 20) {
                Text("Settings")
                    .font(formatter.font(fontSize: .mediumLarge))
                    .padding(.top, 20)
                VStack (alignment: .leading, spacing: 5) {
                    HStack (alignment: .top, spacing: 4) {
                        Text("Let's give your set a title")
                            .font(formatter.font(.regularItalic, fontSize: .regular))
                        Circle()
                            .frame(width: 5, height: 5)
                            .foregroundColor(formatter.color(.red))
                    }
                    ZStack (alignment: .leading) {
                        if setTitle.isEmpty {
                            Text("Untitled")
                                .foregroundColor(formatter.color(.lowContrastWhite))
                                .font(formatter.font(.boldItalic, fontSize: .mediumLarge))
                        }
                        TextField("", text: $setTitle, onEditingChanged: { newTitle in
                            buildVM.setName = setTitle
                        })
                        .accentColor(formatter.color(.secondaryAccent))
                        .font(formatter.font(fontSize: .mediumLarge))
                        .frame(height: 60)
                    }
                    .padding(.horizontal)
                    .background(formatter.color(.primaryFG))
                    .cornerRadius(5)
                    .onAppear {
                        setTitle = buildVM.setName
                        setDescription = buildVM.setDescription
                    }
                }
                VStack (alignment: .leading, spacing: 5) {
                    Text("(Optional) Add a description for your set")
                        .font(formatter.font(.regularItalic, fontSize: .regular))
                    VStack (spacing: 2) {
                        ZStack (alignment: .leading) {
                            if setDescription.isEmpty {
                                Text("Description")
                                    .font(formatter.font(.boldItalic))
                                    .foregroundColor(formatter.color(.lowContrastWhite))
                            }
                            MobileMultilineTextField("", text: $setDescription) {
                                buildVM.setDescription = setDescription
                            }
                            .accentColor(formatter.color(.highContrastWhite))
                            .offset(x: -5)
                        }
                        
                        Rectangle()
                            .fill(formatter.color(.highContrastWhite))
                            .frame(maxWidth: .infinity)
                            .frame(height: 2)
                            .offset(y: -5)
                    }
                }
                VStack (alignment: .leading, spacing: 3) {
                    HStack (alignment: .bottom) {
                        HStack (alignment: .top, spacing: 4) {
                            Text("Add one or more tags")
                                .font(formatter.font(.regularItalic, fontSize: .regular))
                            Circle()
                                .frame(width: 5, height: 5)
                                .foregroundColor(formatter.color(.red))
                        }
                        Spacer()
                        Button {
                            showingInstructions.toggle()
                        } label: {
                            Image(systemName: showingInstructions ? "questionmark.circle.fill" : "questionmark.circle")
                                .font(formatter.iconFont(.small))
                        }
                    }
                    
                    // Tags view
                    FlexibleView(data: buildVM.tags, spacing: 3, alignment: .leading) { item in
                        HStack (spacing: 0) {
                            Text("#")
                            Text(verbatim: item.uppercased())
                            if selectedTag == item {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 15, weight: .bold))
                                    .onTapGesture {
                                        buildVM.removeTag(tag: item)
                                    }
                                    .padding(.leading, 5)
                            }
                        }
                        .foregroundColor(formatter.color(selectedTag == item ? .primaryFG : .highContrastWhite))
                        .font(formatter.font(.boldItalic, fontSize: .small))
                        .padding(selectedTag == item ? 6 : 10)
                        .background(formatter.color(selectedTag == item ? .highContrastWhite : .secondaryFG))
                        .clipShape(Capsule())
                        .padding(.vertical, 2)
                        .animation(.easeInOut(duration: 0.1))
                        .onTapGesture {
                            selectedTag = selectedTag == item ? "" : item
                        }
                    }
                    .frame(minWidth: 300)
                    
                    HStack {
                        TextField("Tag", text: $tagString, onEditingChanged: { editingChanged in
                            buildVM.tag = tagString
                            formatter.hapticFeedback(style: .rigid, intensity: .weak)
                            buildVM.addTag()
                            tagString = ""
                            // insurance
                            buildVM.setDescription = setDescription
                        })
                        .accentColor(formatter.color(.secondaryAccent))
                        .font(formatter.font(.boldItalic, fontSize: .mediumLarge))
                        Spacer()
                        Text("Add")
                            .font(formatter.font(fontSize: .medium))
                            .foregroundColor(formatter.color(.secondaryAccent))
                            .opacity(tagString.isEmpty ? 0.4 : 1)
                            .onTapGesture {
                                buildVM.tag = tagString
                                formatter.hapticFeedback(style: .rigid, intensity: .weak)
                                buildVM.addTag()
                                tagString = ""
                            }
                    }
                    .padding()
                    .background(formatter.color(.primaryFG))
                    .cornerRadius(5)
                    
                    if showingInstructions {
                        Text("Tags are single words that describe your set. If your set is public, tags will help people discover your set. You must have at least one tag.")
                            .font(formatter.font(.regularItalic, fontSize: .small))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                VStack (alignment: .leading) {
                    Text("How many rounds in this game?")
                        .font(formatter.font(.regularItalic, fontSize: .regular))
                    HStack {
                        Text("1")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(formatter.color(!buildVM.hasTwoRounds ? .primaryAccent : .primaryFG))
                            .cornerRadius(5)
                            .onTapGesture {
                                buildVM.hasTwoRounds = false
                            }
                        Text("2")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(formatter.color(buildVM.hasTwoRounds ? .primaryAccent : .primaryFG))
                            .cornerRadius(5)
                            .onTapGesture {
                                buildVM.hasTwoRounds = true
                            }
                    }
                    .font(formatter.font(fontSize: .mediumLarge))
                    .foregroundColor(formatter.color(.secondaryAccent))
                }
                HStack {
                    VStack (alignment: .leading) {
                        Text("Round 1 Categories")
                            .font(formatter.font(.regularItalic, fontSize: .regular))
                        HStack (spacing: 2) {
                            Text("\(buildVM.jRoundLen)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Button {
                                buildVM.subtractRound1()
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(formatter.iconFont(.medium))
                                    .opacity(buildVM.jRoundLen == 3 ? 0.4 : 1)
                            }
                            Button {
                                buildVM.addRound1()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(formatter.iconFont(.medium))
                                    .opacity(buildVM.jRoundLen == 6 ? 0.4 : 1)
                            }
                        }
                        .font(formatter.font(fontSize: .mediumLarge))
                        .padding()
                        .background(formatter.color(.primaryFG))
                        .cornerRadius(5)
                    }
                    if buildVM.hasTwoRounds {
                        VStack (alignment: .leading) {
                            Text("Round 2 Categories")
                                .font(formatter.font(.regularItalic, fontSize: .regular))
                            HStack (spacing: 2) {
                                Text("\(buildVM.djRoundLen)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Button {
                                    buildVM.subtractRound2()
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(formatter.iconFont(.medium))
                                        .opacity(buildVM.djRoundLen == 3 ? 0.4 : 1)
                                }
                                Button {
                                    buildVM.addRound2()
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(formatter.iconFont(.medium))
                                        .opacity(buildVM.djRoundLen == 6 ? 0.4 : 1)
                                }
                            }
                            .font(formatter.font(fontSize: .mediumLarge))
                            .padding()
                            .background(formatter.color(.primaryFG))
                            .cornerRadius(5)
                        }
                    }
                }
                HStack (spacing: 10) {
                    ZStack(alignment: (buildVM.isPublic ? .trailing : .leading)) {
                        Capsule()
                            .frame(width: 30, height: 15)
                            .foregroundColor(formatter.color(buildVM.isPublic ? .secondaryAccent : .primaryFG))
                        Circle()
                            .frame(width: 15, height: 15)
                    }
                    .animation(.easeInOut(duration: 0.1), value: UUID().uuidString)
                    .onTapGesture {
                        buildVM.isPublic.toggle()
                    }
                    
                    Text("\(buildVM.isPublic ? "Public: anyone can play this set" : "Private: only I can see this set")")
                        .font(formatter.font(.regular))
                }
                Text("Tip: Each category is considered complete when it has one or more clues. So, if you’re stuck on a category, just finish one clue and move on. You can always come back to it later, or you can leave it empty!")
                    .font(formatter.font(.regularItalic, fontSize: .regular))
            }
            .keyboardAware()
        }
    }
}

struct MobileBuildCustomSetPreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            HStack {
                if !buildVM.isPublic {
                    Image(systemName: "lock.fill")
                        .font(formatter.iconFont())
                }
                Text("\(buildVM.setName.isEmpty ? "No Title" : buildVM.setName)")
                    .font(formatter.font(fontSize: .mediumLarge))
                    .foregroundColor(formatter.color(buildVM.setName.isEmpty ? .lowContrastWhite : .highContrastWhite))
                Spacer()
            }
            HStack {
                Text("\(buildVM.getNumClues()) clues")
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 10)
                HStack (spacing: 3) {
                    Text("N/A")
                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .bold))
                }
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 10)
                Text("\(gamesVM.dateFormatter.string(from: Date()))")
            }
            .font(formatter.font(.regular, fontSize: .small))
            .foregroundColor(formatter.color(.highContrastWhite))
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: 3) {
                    ForEach(buildVM.tags, id: \.self) { tag in
                        Text("#" + tag.uppercased())
                            .font(formatter.font(.boldItalic, fontSize: .small))
                            .foregroundColor(formatter.color(.primaryFG))
                            .padding(7)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(formatter.color(.secondaryFG))
        .cornerRadius(10)
    }
}

