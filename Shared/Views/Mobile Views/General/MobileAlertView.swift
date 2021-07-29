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
                    .shadow(radius: 10)
                default:
                    VStack {
                        VStack {
                            VStack (spacing: 15) {
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
                        .padding(20)
                        .background(formatter.color(.secondaryFG))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        if hasCancel {
                            Button {
                                formatter.hapticFeedback(style: .soft, intensity: .strong)
                                formatter.dismissAlert()
                            } label: {
                                Text("Cancel")
                                    .font(formatter.font(fontSize: .mediumLarge))
                                    .foregroundColor(formatter.color(.highContrastWhite))
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
                    .padding()
                    .background(formatter.color(.primaryAccent))
                    .font(formatter.font(fontSize: .mediumLarge))
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .cornerRadius(5)
            }
        }
        return body
    }
}
