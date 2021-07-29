//
//  MobileSetPreviewView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI
import Shimmer

struct MobileSetPreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @State var userViewActive = false
    
    var isCustom: Bool {
        return !gamesVM.queriedUserName.isEmpty
    }
    
    var customSet: CustomSet {
        return gamesVM.customSet
    }
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (alignment: .leading, spacing: 15) {
                VStack (alignment: .leading) {
                    Text("\(gamesVM.title)")
                        .font(formatter.font(fontSize: .large))
                    Text("Created on \(gamesVM.dateFormatter.string(from: customSet.dateCreated))")
                        .font(formatter.font(.regularItalic))
                    MobileUserProfileButtonView(userViewActive: $userViewActive, set: customSet)
                    Button(action: {
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                        gamesVM.menuChoice = .game
                        gamesVM.reset()
                    }, label: {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text("Play This Set")
                        }
                        .font(formatter.font())
                        .foregroundColor(formatter.color(.primaryFG))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.highContrastWhite))
                        .cornerRadius(5)
                    })
                }
                
                MobileGamePreviewView(searchQuery: exploreVM.capSplit)
                
                VStack (alignment: .leading, spacing: 15) {
                    
                    Text("About This Set")
                        .font(formatter.font(fontSize: .semiLarge))
                        .padding(.horizontal)
                    
                    HStack (spacing: 20) {
                        
                        // Plays counter
                        VStack {
                            Text("\(customSet.plays)")
                                .font(formatter.font(fontSize: .large))
                            Text("Plays")
                                .padding(10)
                                .background(formatter.color(.primaryAccent))
                                .clipShape(Capsule())
                        }
                        
                        // Clues counter
                        VStack {
                            Text("\(customSet.numclues)")
                                .font(formatter.font(fontSize: .large))
                            Text("Clues")
                                .padding(10)
                                .background(formatter.color(.primaryAccent))
                                .clipShape(Capsule())
                        }
                        
                        // Rating counter
                        VStack {
                            Text("\(String(customSet.rating.description.prefix(3)))")
                                .font(formatter.font(fontSize: .large))
                            Text("Rating")
                                .padding(10)
                                .background(formatter.color(.primaryAccent))
                                .clipShape(Capsule())
                        }
                    }
                    .font(formatter.font(fontSize: .small))
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(.secondaryFG))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    ScrollView (.horizontal, showsIndicators: false) {
                        HStack (spacing: 3) {
                            Spacer()
                                .frame(width: 15)
                            ForEach(customSet.tags, id: \.self) { tag in
                                Text("#" + tag.uppercased())
                                    .font(formatter.font(.boldItalic, fontSize: .small))
                                    .foregroundColor(formatter.color(.primaryFG))
                                    .padding(7)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                            }
                            Spacer()
                                .frame(width: 15)
                        }
                    }
                }
                .padding(.vertical)
                .background(formatter.color(.primaryFG))
                .cornerRadius(10)
            }
            .padding()
        }
        .withBackButton()
        .redacted(reason: customSet.title.isEmpty ? .placeholder : [])
        .shimmering(active: customSet.title.isEmpty)
    }
}
