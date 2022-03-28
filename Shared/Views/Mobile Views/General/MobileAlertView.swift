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
                    VStack {
                        
                        // Alert box with 1-2 action buttons
                        VStack (spacing: 10) {
                            VStack {
                                Text(titleText)
                                    .font(formatter.font(fontSize: .mediumLarge))
                                Text(subtitleText)
                                    .font(formatter.font(.regular, fontSize: .small))
                            }
                            .padding(.bottom, 20)
                            ActionButtonView(action: {
                                action()
                                formatter.dismissAlert()
                            }, label: actionLabel)
                            if hasSecondaryAction {
                                ActionButtonView(action: {
                                    secondaryAction()
                                    formatter.dismissAlert()
                                }, label: secondaryActionLabel)
                            }
                        }
                        .padding()
                        .background(formatter.color(.secondaryFG))
                        .cornerRadius(10)
                        .shadow(color: formatter.color(.primaryBG).opacity(0.8), radius: 10)
                        
                        // Cancel button
                        if hasCancel {
                            Button {
                                formatter.hapticFeedback(style: .soft, intensity: .strong)
                                formatter.dismissAlert()
                            } label: {
                                Text("Cancel")
                                    .font(formatter.font(fontSize: .medium))
                            }
                            .padding()
                        }
                    }
                }
            }
            .padding(.horizontal, 30)
            .offset(y: formatter.showingAlert ? 0 : UIScreen.main.bounds.height)
        }
    }
    
    func ActionButtonView(action: @escaping () -> (), label: String) -> some View {
        var body: some View {
            Button {
                action()
            } label: {
                Text(label)
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(formatter.color(.primaryAccent))
                    .font(formatter.font(fontSize: .medium))
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .clipShape(Capsule())
            }
        }
        return body
    }
}
