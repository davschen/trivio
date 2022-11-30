//
//  MobileAlertView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileAlertView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    var alertType: AlertType = .warning
    var alertStyle: AlertStyle
    var titleText = ""
    var subtitleText = ""
    var hasCancel = false
    var actionLabel = ""
    var action: () -> () = { print("default alert") }
    var hasSecondaryAction = false
    var secondaryAction: () -> () = { print("secondary alert") }
    var secondaryActionLabel = ""
    
    var body: some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
                .opacity(formatter.showingAlert ? 0.9 : 0)
                .onTapGesture {
                    if hasCancel { formatter.dismissAlert() }
                }
            ZStack {
                switch alertStyle {
                case .view:
                    Text("")
                case .loading:
                    VStack {
                        LoadingView()
                    }
                    .padding(50)
                    .background(formatter.color(.secondaryFG))
                    .cornerRadius(20)
                default:
                    VStack (spacing: 10) {
                        Spacer()
                        
                        VStack (spacing: 5) {
                            VStack (spacing: 10) {
                                Image(systemName: alertType == .warning ? "exclamationmark.triangle" : "sparkles")
                                    .font(.system(size: 26))
                                    .padding(.bottom, 5)
                                Text(titleText)
                                    .font(formatter.fontFloat(sizeFloat: 17))
                                Text(subtitleText)
                                    .font(formatter.fontFloat(.regular, sizeFloat: 14))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                            }
                            .padding(20)
                            Button {
                                action()
                                formatter.dismissAlert()
                            } label: {
                                Text(actionLabel)
                                    .frame(maxWidth: .infinity)
                                    .padding(20)
                                    .background(formatter.color(.primaryAccent))
                                    .font(formatter.font(fontSize: .medium))
                                    .foregroundColor(formatter.color(.highContrastWhite))
                            }
                        }
                        .background(formatter.color(.primaryFG))
                        .cornerRadius(10)
                        
                        if hasSecondaryAction {
                            Button {
                                secondaryAction()
                                formatter.dismissAlert()
                            } label: {
                                Text(secondaryActionLabel)
                                    .frame(maxWidth: .infinity)
                                    .padding(20)
                                    .background(formatter.color(.primaryAccent))
                                    .font(formatter.font(fontSize: .medium))
                                    .foregroundColor(formatter.color(.highContrastWhite))
                            }
                        }
                        
                        // Cancel button
                        if hasCancel {
                            Button {
                                formatter.dismissAlert()
                            } label: {
                                Text("Cancel")
                                    .padding(20)
                                    .frame(maxWidth: .infinity)
                                    .background(formatter.color(.primaryFG))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom)
            .offset(y: formatter.showingAlert ? 0 : UIScreen.main.bounds.height + 100)
        }
    }
}

enum AlertType {
    case warning, tip
}
