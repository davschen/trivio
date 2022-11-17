//
//  BuildDetailsView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct BuildDetailsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @State var selectedTag = ""
    @State var showingInstructions = false
    
    var body: some View {
        ZStack {
            ScrollView (.vertical) {
                VStack (alignment: .leading, spacing: 20) {
                    HStack {
                        VStack {
                            Text("Preview")
                                .font(formatter.font(.regularItalic))
                            BuildCustomSetPreviewView()
                                .frame(width: 400)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    VStack (alignment: .leading, spacing: 3) {
                        Text("TITLE")
                            .font(formatter.font(fontSize: .large))
                        TextField("Title your set", text: $buildVM.currCustomSet.title)
                            .accentColor(formatter.color(.secondaryAccent))
                            .font(formatter.font(fontSize: .large))
                            .padding(20)
                            .background(formatter.color(.lowContrastWhite))
                            .cornerRadius(10)
                    }
                    
                    VStack (alignment: .leading, spacing: 5) {
                        HStack {
                            Text("TAGS")
                                .font(formatter.font(fontSize: .large))
                            Button {
                                showingInstructions.toggle()
                            } label: {
                                Image(systemName: showingInstructions ? "questionmark.circle.fill" : "questionmark.circle")
                                    .font(.system(size: 25, weight: .bold))
                            }
                            Spacer()
                        }
                        
                        // Tags view
                        FlexibleView(data: buildVM.currCustomSet.tags, spacing: 8, alignment: .leading) { item in
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
                            .font(formatter.font(.boldItalic))
                            .padding(10)
                            .background(formatter.color(selectedTag == item ? .highContrastWhite : .lowContrastWhite))
                            .clipShape(Capsule())
                            .onTapGesture {
                                selectedTag = selectedTag == item ? "" : item
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(formatter.color(buildVM.tag.isEmpty ? .lowContrastWhite : .highContrastWhite))
                                .onTapGesture {
                                    buildVM.addTag()
                                }
                            TextField("ADD TAG", text: $buildVM.tag)
                                .accentColor(formatter.color(.secondaryAccent))
                                .font(formatter.font(.boldItalic, fontSize: .large))
                        }
                        .padding(20)
                        .background(formatter.color(.lowContrastWhite))
                        .cornerRadius(10)
                        
                        if showingInstructions {
                            Text("Tags are single words that describe your set. If your set is public, tags will help people discover your set. You must have at least two tags.")
                                .font(formatter.font(.regularItalic))
                        }
                    }
                    HStack (spacing: 10) {
                        Image(systemName: "checkmark")
                            .padding(5)
                            .background(RoundedRectangle(cornerRadius: 4).stroke(formatter.color(.highContrastWhite), lineWidth: 5))
                            .background(formatter.color(buildVM.currCustomSet.isPublic ? .highContrastWhite : .primaryAccent))
                            .foregroundColor(formatter.color(.primaryAccent))
                            .cornerRadius(4)
                            .onTapGesture {
                                buildVM.currCustomSet.isPublic.toggle()
                            }
                        
                        Text("Make this set available to the public")
                            .font(formatter.font())
                    }
                }
                .padding(30)
                .keyboardAware()
            }
            .background(formatter.color(.primaryAccent))
            .cornerRadius(30)
        }
    }
}

struct BuildCustomSetPreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            HStack {
                if !buildVM.currCustomSet.isPublic {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .bold))
                }
                Text("\(buildVM.currCustomSet.title.isEmpty ? "No Title" : buildVM.currCustomSet.title)")
                    .font(formatter.font(fontSize: .mediumLarge))
                    .foregroundColor(formatter.color(buildVM.currCustomSet.title.isEmpty ? .lowContrastWhite : .highContrastWhite))
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
                HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                    ForEach(buildVM.currCustomSet.tags, id: \.self) { tag in
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
