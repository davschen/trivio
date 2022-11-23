//
//  DraftsView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/16/21.
//

import Foundation
import SwiftUI

struct DraftsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    let columns = [GridItem](repeating: GridItem(spacing: 15), count: 3)
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("My Drafts")
                .font(formatter.font(fontSize: .extraLarge))
                .foregroundColor(formatter.color(.highContrastWhite))
            if profileVM.drafts.count > 0 {
                ScrollView (.vertical) {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(profileVM.drafts, id: \.self) { draft in
                            DraftCellView(draft: draft)
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .cornerRadius(5)
            } else {
                EmptyListView(label: "No drafts! Come back here when you save a draft.")
                    .padding(.vertical, 30)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct DraftCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var draft: CustomSetCherry
    var setID: String {
        return draft.id ?? "NID"
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            HStack {
                if !draft.isPublic {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .bold))
                }
                Text("\(draft.title)")
                    .font(formatter.font(fontSize: .mediumLarge))
                Spacer()
            }
            HStack {
                Text("\(draft.numClues) clues")
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 10)
                Text("\(gamesVM.dateFormatter.string(from: draft.dateCreated))")
            }
            .font(formatter.font(.regular, fontSize: .small))
            .foregroundColor(formatter.color(.highContrastWhite))
            HStack {
                Button(action: {
                    buildVM.edit(customSet: draft)
                }, label: {
                    Text("Edit")
                        .foregroundColor(formatter.color(.highContrastWhite))
                        .font(formatter.font(fontSize: .medium))
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.primaryAccent))
                        .cornerRadius(5)
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
                        .background(formatter.color(.lowContrastWhite).opacity(0.5))
                        .cornerRadius(5)
                })
            }
        }
        .padding()
        .background(formatter.color(.secondaryFG))
        .cornerRadius(10)
        .onTapGesture {
            buildVM.edit(customSet: draft)
        }
    }
}
