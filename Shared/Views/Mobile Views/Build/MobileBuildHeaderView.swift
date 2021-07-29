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
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var showingEdit: Bool
    @Binding var editingName: Bool
    @Binding var showingSaveDraft: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                setSaveDraftAlert()
            }, label: {
                Image(systemName: "chevron.left")
                    .font(formatter.iconFont(.mediumLarge))
            })
            Text("\(buildVM.isEditing ? "Edit" : "Build")")
                .font(formatter.font(fontSize: .large))
            
            Spacer()
            
            // Save and Next/Finish buttons
            HStack {
                if buildVM.currentDisplay == .grid {
                    Button(action: {
                        if buildVM.isEditing && !buildVM.isEditingDraft {
                            buildVM.writeToFirestore { (success) in
                                if success {
                                    buildVM.showingBuildView.toggle()
                                    
                                }
                            }
                        } else {
                            buildVM.currentDisplay = .saveDraft
                        }
                    }) {
                        ZStack {
                            if buildVM.processPending {
                                LoadingView(color: .primaryFG)
                            } else {
                                Text("Save")
                            }
                        }
                        .font(formatter.font(fontSize: .medium))
                        .foregroundColor(formatter.color(.primaryFG))
                        .padding(10)
                        .background(formatter.color(.highContrastWhite))
                        .cornerRadius(5)
                    }
                }
                Button(action: {
                    if buildVM.nextPermitted() {
                        buildVM.nextButtonHandler()
                    }
                }, label: {
                    ZStack {
                        if buildVM.processPending {
                            LoadingView(color: .primaryFG)
                        } else {
                            Text(buildVM.buildStage == .details ? "Publish" : "Next")
                        }
                    }
                    .font(formatter.font(fontSize: .medium))
                    .foregroundColor(formatter.color(.primaryFG))
                    .padding(10)
                    .background(formatter.color(buildVM.nextPermitted() ? .highContrastWhite : .lowContrastWhite))
                    .cornerRadius(5)
                })
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
                showingSaveDraft.toggle()
            }
        },
        secondaryActionLabel: buildVM.isEditing ? "Save" : "Save draft")
    }
}

struct MobileBuildTickerView: View {
    var body: some View {
        HStack (alignment: .bottom, spacing: 3) {
            MobileProgressTextDotView(buildStage: .trivioRound)
            MobileProgressTextDotView(buildStage: .trivioRoundDD)
            MobileProgressTextDotView(buildStage: .dtRound)
            MobileProgressTextDotView(buildStage: .dtRoundDD)
            MobileProgressTextDotView(buildStage: .finalTrivio)
            MobileProgressTextDotView(buildStage: .details)
        }
    }
}

struct MobileProgressTextDotView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    let buildStageIndexDict = BuildStageIndexDict()
    let buildStage: BuildStage
    
    var buildStageIndex: Int {
        return buildStageIndexDict.getIndex(from: buildStage)
    }
    
    var buildVMStageIndex: Int {
        return buildStageIndexDict.getIndex(from: buildVM.buildStage)
    }
    
    var body: some View {
        Capsule()
            .frame(height: 5)
            .frame(maxWidth: buildStageIndex == buildVMStageIndex ? .infinity : 5)
            .offset(y: -3)
            .foregroundColor(formatter.color(buildStageIndex > buildVMStageIndex ? .lowContrastWhite : .highContrastWhite))
            .animation(.easeInOut(duration: 1))
    }
}

