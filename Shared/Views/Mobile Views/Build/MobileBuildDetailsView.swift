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
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text(buildVM.stepStringHandler())
                .font(formatter.font(fontSize: .mediumLarge))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            ScrollView (.vertical) {
                VStack (alignment: .leading, spacing: 20) {
                    HStack {
                        VStack {
                            Text("Preview")
                                .font(formatter.font(.regularItalic))
                            MobileBuildCustomSetPreviewView()
                                .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    VStack (alignment: .leading, spacing: 3) {
                        Text("TITLE")
                            .font(formatter.font(fontSize: .mediumLarge))
                        TextField("Title your set", text: $buildVM.setName)
                            .accentColor(formatter.color(.secondaryAccent))
                            .font(formatter.font(fontSize: .mediumLarge))
                            .padding()
                            .background(formatter.color(.lowContrastWhite))
                            .cornerRadius(5)
                    }
                    
                    VStack (alignment: .leading, spacing: 5) {
                        HStack {
                            Text("TAGS")
                                .font(formatter.font(fontSize: .mediumLarge))
                            Button {
                                showingInstructions.toggle()
                            } label: {
                                Image(systemName: showingInstructions ? "questionmark.circle.fill" : "questionmark.circle")
                                    .font(formatter.iconFont(.small))
                            }
                            Spacer()
                        }
                        
                        // Tags view
                        FlexibleView(data: buildVM.tags, spacing: 8, alignment: .leading) { item in
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
                                .font(formatter.iconFont(.mediumLarge))
                                .foregroundColor(formatter.color(buildVM.tag.isEmpty ? .lowContrastWhite : .highContrastWhite))
                                .onTapGesture {
                                    buildVM.addTag()
                                }
                            TextField("ADD TAG", text: $buildVM.tag)
                                .accentColor(formatter.color(.secondaryAccent))
                                .font(formatter.font(.boldItalic, fontSize: .mediumLarge))
                        }
                        .padding()
                        .background(formatter.color(.lowContrastWhite))
                        .cornerRadius(5)
                        
                        if showingInstructions {
                            Text("Tags are single words that describe your set. If your set is public, tags will help people discover your set. You must have at least two tags.")
                                .font(formatter.font(.regularItalic, fontSize: .small))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    HStack (spacing: 10) {
                        Image(systemName: "checkmark")
                            .font(formatter.iconFont(.small))
                            .padding(3)
                            .padding(.vertical, 1)
                            .background(RoundedRectangle(cornerRadius: 4).stroke(formatter.color(.highContrastWhite), lineWidth: 5))
                            .background(formatter.color(buildVM.isPublic ? .highContrastWhite : .primaryAccent))
                            .foregroundColor(formatter.color(.primaryAccent))
                            .cornerRadius(4)
                            .onTapGesture {
                                buildVM.isPublic.toggle()
                            }
                        
                        Text("Make this set available to the public")
                            .font(formatter.font())
                    }
                }
                .padding()
                .keyboardAware()
            }
            .background(formatter.color(.primaryAccent))
            .cornerRadius(20)
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
                HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
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

