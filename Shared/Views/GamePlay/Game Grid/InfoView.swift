//
//  InfoView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct InfoView: View {
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
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
                .opacity(showInfoView ? 0.6 : 0)
                .onTapGesture {
                    showInfoView.toggle()
                }
            VStack (alignment: .leading) {
                ZStack {
                    Button {
                        showInfoView.toggle()
                    } label: {
                        Text("Cancel")
                            .font(formatter.font(fontSize: .small))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text("Game Info")
                        .font(formatter.font(fontSize: .large))
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(formatter.color(.secondaryFG))
                ScrollView (.vertical) {
                    VStack (alignment: .leading) {
                        Text("\(gamesVM.title)")
                            .font(formatter.font(fontSize: .large))
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
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.4)
            .background(formatter.color(.primaryFG))
            .cornerRadius(30)
            .offset(y: self.showInfoView ? 0 : UIScreen.main.bounds.height)
        }
    }
}
