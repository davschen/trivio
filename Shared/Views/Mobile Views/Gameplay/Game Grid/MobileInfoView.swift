//
//  MobileInfoView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileInfoView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @Binding var showInfoView: Bool
    
    var customSet: CustomSet {
        return gamesVM.customSet
    }
    
    var isCustom: Bool {
        return !gamesVM.queriedUserName.isEmpty
    }
    
    var body: some View {
        ZStack (alignment: .bottom) {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
                .opacity(showInfoView ? 0.9 : 0)
                .onTapGesture {
                    formatter.hapticFeedback(style: .soft)
                    showInfoView.toggle()
                }
            VStack (alignment: .leading) {
                ZStack {
                    Button {
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                        showInfoView.toggle()
                    } label: {
                        Text("Cancel")
                            .font(formatter.font(fontSize: .small))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text("Game Info")
                        .font(formatter.font(fontSize: .mediumLarge))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(formatter.color(.secondaryFG))
                ScrollView (.vertical, showsIndicators: false) {
                    VStack (alignment: .leading) {
                        Text("\(gamesVM.title)")
                            .font(formatter.font(fontSize: .semiLarge))
                        Text("Created by \(isCustom ? gamesVM.queriedUserName : "Trivio Official") on \(gamesVM.dateFormatter.string(from: isCustom ? customSet.dateCreated : gamesVM.date))")
                            .font(formatter.font(.regular))
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
                        .padding(.top)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .frame(maxWidth: .infinity)
            .background(formatter.color(.primaryFG))
            .cornerRadius(20)
            .offset(y: showInfoView ? 0 : UIScreen.main.bounds.height)
            .padding(.horizontal)
        }
    }
}

