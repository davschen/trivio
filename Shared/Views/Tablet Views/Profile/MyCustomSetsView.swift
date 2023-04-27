//
//  MyCustomSetsView.swift
//  Trivio!
//
//  Created by David Chen on 12/8/22.
//

import Foundation
import SwiftUI

struct MyCustomSetsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State var idSelected = ""
    
    @Binding var customSets: [CustomSetDurian]
    
    @State var expandedSetID = ""
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            if customSets.count > 0 {
                VStack (alignment: .leading, spacing: 3) {
                    ForEach(customSets, id: \.self) { customSet in
                        MyCustomSetCellView(expandedSetID: $expandedSetID, customSet: customSet)
                            .animation(.easeInOut(duration: 0.2))
                    }
                }
                .onAppear {
                    guard let firstSetID = customSets.first?.id else { return }
                    expandedSetID = expandedSetID.isEmpty ? firstSetID : expandedSetID
                }
            } else {
                EmptyListView(label: "You haven’t made any sets yet. Once you do, they’ll show up here.")
                    .padding(.horizontal)
            }
        }
        .keyboardAware()
    }
}

struct MyCustomSetCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var expandedSetID: String
    
    @State var isPresentingBuildView = false
    @State var setPreviewActive = false
    
    var isInUserView = false
    var customSet: CustomSetDurian
    var setID: String {
        return customSet.id ?? "NID"
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack (spacing: 2) {
                if !customSet.isPublic {
                    Image(systemName: "lock.fill")
                        .font(formatter.iconFont(.small))
                        .offset(x: -2, y: -1)
                }
                Text(customSet.title)
                    .font(formatter.font(fontSize: .mediumLarge))
                    .lineLimit(1)
                Spacer()
            }
            if !customSet.description.isEmpty {
                Text(customSet.description)
                    .font(formatter.font(.regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }
            HStack {
                Text("\(customSet.hasTwoRounds ? "2 rounds" : "1 round"), \(customSet.numClues) clues")
                Circle()
                    .frame(width: 5, height: 5)
                Text("\(customSet.plays) play" + "\(customSet.plays == 1 ? "" : "s")")
                Circle()
                    .frame(width: 5, height: 5)
                Text("\(gamesVM.dateFormatter.string(from: customSet.dateCreated))")
            }
            .font(formatter.font(.regular))
            .foregroundColor(formatter.color(.lowContrastWhite))
            
            if expandedSetID == setID {
                HStack (spacing: 10) {
                    Button {
                        setPreviewActive.toggle()
                        formatter.hapticFeedback(style: .light)
                        gamesVM.reset()
                        gamesVM.getCustomData(setID: setID)
                        participantsVM.resetScores()
                    } label: {
                        ZStack {
                            Image(systemName: "gamecontroller.fill")
                                .font(formatter.iconFont(.mediumLarge))
                                .foregroundColor(formatter.color(.primaryBG))
                                .font(formatter.iconFont(.small))
                                .frame(maxWidth: 80)
                                .frame(height: 55)
                                .background(formatter.color(.highContrastWhite))
                                .clipShape(Capsule())
                            NavigationLink(destination: GamePreviewView()
                                .navigationBarTitle("Set Preview", displayMode: .inline),
                                           isActive: $setPreviewActive,
                                           label: { EmptyView() }).hidden()
                        }
                    }

                    Button(action: {
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                        isPresentingBuildView.toggle()
                        buildVM.edit(customSet: customSet)
                    }, label: {
                        ZStack {
                            Text("Edit")
                                .font(formatter.font(fontSize: .medium))
                                .foregroundColor(formatter.color(.highContrastWhite))
                                .padding(10)
                                .frame(maxWidth: 150)
                                .frame(height: 55)
                                .background(formatter.color(.primaryAccent))
                                .clipShape(Capsule())
                            NavigationLink (isActive: $isPresentingBuildView) {
                                BuildView()
                            } label: { EmptyView() }
                                .hidden()
                        }
                    })
                    Button(action: {
                        formatter.setAlertSettings(alertAction: {
                            buildVM.deleteSet(customSet: customSet)
                        }, alertTitle: "Are You Sure?", alertSubtitle: "You're about to delete your set named \"\(customSet.title)\" — deleting a set is irreversible.", hasCancel: true, actionLabel: "Yes, delete my set")
                    }, label: {
                        Text("Delete")
                            .foregroundColor(formatter.color(.red))
                            .font(formatter.font(fontSize: .medium))
                            .padding(10)
                            .frame(maxWidth: 150)
                            .frame(height: 55)
                            .background(formatter.color(.primaryFG))
                            .clipShape(Capsule())
                    })
                }
            }
        }
        .padding(25)
        .background(formatter.color(expandedSetID == setID ? .secondaryFG : .primaryFG))
        .contentShape(Rectangle())
        .onTapGesture {
            formatter.hapticFeedback(style: .rigid, intensity: .weak)
            expandedSetID = setID
        }
    }
}
