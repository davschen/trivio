//
//  MobileBuildHeaderView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileBuildHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var showingEdit: Bool
    @Binding var editingName: Bool
    @Binding var showingSaveDraft: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                setSaveDraftAlert()
            }, label: {
                Image(systemName: "xmark")
                    .font(formatter.iconFont(.medium))
            })
            Text("\(buildVM.isEditing ? "Edit" : "Build")")
                .font(formatter.font(fontSize: .large))
            
            Spacer()
            
            // Save and Next/Finish buttons
            HStack (spacing: 5) {
                if buildVM.currentDisplay == .grid {
                    Button(action: {
                        if buildVM.isEditing && !buildVM.isEditingDraft {
                            formatter.setAlertSettings(alertAction: {
                                formatter.hapticFeedback(style: .soft, intensity: .strong)
                                buildVM.saveDraft()
                            }, alertTitle: "Save and Leave?", alertSubtitle: "Choose whether you want to leave or stay after saving.", hasCancel: true, actionLabel: "Stay", hasSecondaryAction: true, secondaryAction: {
                                buildVM.saveDraft()
                                buildVM.showingBuildView.toggle()
                            }, secondaryActionLabel: "Leave")
                        } else {
                            buildVM.currentDisplay = .saveDraft
                        }
                    }) {
                        ZStack {
                            Text("Save")
                        }
                        .font(formatter.font(fontSize: .regular))
                        .foregroundColor(formatter.color(.primaryFG))
                        .padding()
                        .background(formatter.color(.highContrastWhite))
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    func setSaveDraftAlert() {
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
                buildVM.saveDraft(isExiting: true)
                showingSaveDraft.toggle()
            }
        },
        secondaryActionLabel: buildVM.isEditing ? "Save" : "Save draft")
    }
}
