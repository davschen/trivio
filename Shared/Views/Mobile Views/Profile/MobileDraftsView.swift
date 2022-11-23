//
//  MobileDraftsView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileDraftsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var expandedSetID = ""
    
    var body: some View {
        if profileVM.drafts.count > 0 {
            VStack (spacing: 3) {
                ForEach(profileVM.drafts, id: \.self) { draft in
                    MobileDraftCellView(expandedSetID: $expandedSetID, draft: draft)
                        .onAppear {
                            guard let firstSetID = profileVM.drafts.first?.id else { return }
                            expandedSetID = firstSetID
                        }
                }
            }
        } else {
            MobileEmptyListView(label: "No drafts! Come back here when you save a draft.")
                .padding(.vertical)
        }
    }
}

struct MobileDraftCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var expandedSetID: String
    
    var draft: CustomSetCherry
    var setID: String {
        return draft.id ?? "NID"
    }
    
    @State var isPresentingBuildView = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack (spacing: 4) {
                if !draft.isPublic {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .bold))
                }
                Text("\(draft.title)")
                    .font(formatter.font(fontSize: .mediumLarge))
                    .lineLimit(1)
                Spacer()
            }
            Text("\(draft.hasTwoRounds ? "2 rounds" : "1 round"), \(draft.numClues) clues")
                .font(formatter.font(.regular))
            Text("Draft created on \(gamesVM.dateFormatter.string(from: draft.dateCreated))")
                .foregroundColor(formatter.color(.lowContrastWhite))
            .font(formatter.font(.regular))
            .foregroundColor(formatter.color(.highContrastWhite))
            
            if expandedSetID == setID {
                HStack (spacing: 5) {
                    Button(action: {
                        isPresentingBuildView.toggle()
                        buildVM.edit(customSet: draft)
                    }, label: {
                        ZStack {
                            Text("Edit")
                                .foregroundColor(formatter.color(.highContrastWhite))
                                .font(formatter.font(fontSize: .medium))
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .frame(height: 45)
                                .background(formatter.color(.primaryAccent))
                                .cornerRadius(5)
                            NavigationLink (isActive: $isPresentingBuildView) {
                                MobileBuildView()
                            } label: { EmptyView() }
                                .hidden()
                        }
                    })
                    Button(action: {
                        formatter.setAlertSettings(alertAction: {
                            buildVM.deleteSet(customSet: draft)
                        }, alertTitle: "Are You Sure?", alertSubtitle: "You're about to delete your draft named \"\(draft.title)\" — deleting a draft is irreversible.", hasCancel: true, actionLabel: "Yes, delete my draft")
                    }, label: {
                        Text("Delete")
                            .foregroundColor(formatter.color(.highContrastWhite))
                            .font(formatter.font(fontSize: .medium))
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(formatter.color(.primaryBG))
                            .cornerRadius(5)
                    })
                }
            }
        }
        .padding(.horizontal, 15).padding(.vertical, 20)
        .background(formatter.color(expandedSetID == setID ? .secondaryFG : .primaryFG))
        .contentShape(Rectangle())
        .onTapGesture {
            expandedSetID = setID
        }
    }
}

