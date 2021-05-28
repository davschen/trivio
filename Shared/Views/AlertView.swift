//
//  AlertView.swift
//  Trivio!
//
//  Created by David Chen on 5/27/21.
//

import Foundation
import SwiftUI

struct AlertView: View {
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
    
    var body: some View {
        ZStack {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
                .opacity(formatter.showingAlert ? 0.75 : 0)
            ZStack {
                switch alertStyle {
                case .view:
                    Text("")
                case .loading:
                    VStack {
                        ProgressView()
                    }
                    .padding(50)
                    .background(Color("MainFG"))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                default:
                    VStack {
                        VStack {
                            VStack {
                                Text(titleText)
                                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                Text(subtitleText)
                                    .font(formatter.customFont(weight: "Medium", iPadSize: 15))
                            }
                            .padding(.bottom, 20)
                            Button {
                                action()
                                formatter.dismissAlert()
                            } label: {
                                Text(actionLabel)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.5))
                                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                    .foregroundColor(Color("MainAccent"))
                                    .cornerRadius(5)
                            }
                        }
                        .padding(30)
                        .background(Color("MainFG"))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        if hasCancel {
                            Button {
                                formatter.dismissAlert()
                            } label: {
                                Text("Cancel")
                                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            }
                            .padding()
                        }
                    }
                }
            }
            .frame(width: 300)
            .offset(y: formatter.showingAlert ? 0 : UIScreen.main.bounds.height)
        }
    }
}

enum AlertStyle {
    case standard, view, loading
}
