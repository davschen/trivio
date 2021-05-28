//
//  HomePageView.swift
//  Trivio!
//
//  Created by David Chen on 5/24/21.
//

import Foundation
import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    var body: some View {
        VStack (spacing: 0) {
            ZStack (alignment: .bottomLeading) {
                Color("MainBG")
                    .edgesIgnoringSafeArea(.all)
                MainView()
                    .environmentObject(buildVM)
                    .environmentObject(exploreVM)
                    .environmentObject(gamesVM)
                    .environmentObject(participantsVM)
                    .environmentObject(profileVM)
                    .environmentObject(reportVM)
                    .environmentObject(searchVM)
                if formatter.deviceType == .iPhone && !formatter.showingAlert {
                    HStack {
                        Button (action: {
                            formatter.showingTabBar.toggle()
                        }) {
                            ZStack {
                                Color.white
                                    .opacity(0.2)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "chevron.up")
                            }
                            .clipShape(Circle())
                            .rotationEffect(Angle(degrees: formatter.showingTabBar ? 180 : 0))
                        }
                        .offset(x: -30)
                        .padding()
                    }
                }
                AlertView(alertStyle: .standard, titleText: formatter.alertTitle, subtitleText: formatter.alertSubtitle, hasCancel: formatter.hasCancel, actionLabel: formatter.actionLabel, action: {
                    formatter.alertAction()
                })
            }
            .padding(formatter.shrink(iPadSize: 30, factor: 3))
            if formatter.showingTabBar {
                TabBarView()
                    .environmentObject(gamesVM)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MainView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    var body: some View {
        switch gamesVM.menuChoice {
        case .explore:
            ExploreView()
        case .game:
            GameplayView()
        case .participants:
            ParticipantsView()
        case .gamepicker:
            GamePickerView()
        case .reports:
            ReportsView()
        default:
            ProfileView()
        }
    }
}

struct TabBarView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @State var hasHack = UserDefaults.standard.value(forKey: "hasHack") as? Bool ?? false
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack {
            HStack (spacing: 30) {
                Image(systemName: gamesVM.menuChoice == .explore ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    .foregroundColor(gamesVM.menuChoice == .explore ? .blue : .gray)
                    .onTapGesture {
                        gamesVM.menuChoice = .explore
                    }
                if hasHack {
                    Image(systemName: gamesVM.menuChoice == .gamepicker ? "square.grid.3x2.fill" : "square.grid.3x2")
                        .foregroundColor(gamesVM.menuChoice == .gamepicker ? .blue : .gray)
                        .onTapGesture {
                            gamesVM.menuChoice = .gamepicker
                        }
                }
                Image(systemName: gamesVM.menuChoice == .participants ? "person.3.fill" : "person.3")
                    .foregroundColor(gamesVM.menuChoice == .participants ? .blue : .gray)
                    .onTapGesture {
                        gamesVM.menuChoice = .participants
                    }
                Image(systemName: gamesVM.menuChoice == .game ? "gamecontroller.fill" : "gamecontroller")
                    .foregroundColor(gamesVM.menuChoice == .game ? .blue : .gray)
                    .onTapGesture {
                        gamesVM.menuChoice = .game
                        if formatter.deviceType == .iPhone {
                            formatter.showingTabBar.toggle()
                        }
                    }
                Image(systemName: gamesVM.menuChoice == .profile ? "person.circle.fill" : "person.circle")
                    .foregroundColor(gamesVM.menuChoice == .profile ? .blue : .gray)
                    .onTapGesture {
                        gamesVM.menuChoice = .profile
                        if formatter.deviceType == .iPhone {
                            formatter.showingTabBar.toggle()
                        }
                    }
            }
        }
        .font(.system(size: 20))
        .padding(.bottom, 10)
        .frame(height: formatter.shrink(iPadSize: 70, factor: 1.3))
        .frame(maxWidth: .infinity)
        .background(Color("DarkGray"))
        .shadow(color: Color.black.opacity(0.1), radius: 10)
        .edgesIgnoringSafeArea(.all)
    }
}
