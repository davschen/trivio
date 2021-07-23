//
//  HomePageView.swift
//  Trivio!
//
//  Created by David Chen on 5/24/21.
//

import Foundation
import SwiftUI

struct HomePageView: View {
    @ObservedObject var formatter = MasterHandler()
    @ObservedObject var buildVM = BuildViewModel()
    @ObservedObject var exploreVM = ExploreViewModel()
    @ObservedObject var gamesVM = GamesViewModel()
    @ObservedObject var participantsVM = ParticipantsViewModel()
    @ObservedObject var profileVM = ProfileViewModel()
    @ObservedObject var reportVM = ReportViewModel()
    @ObservedObject var searchVM = SearchViewModel()
    
    var body: some View {
        VStack (spacing: 0) {
            ZStack (alignment: .bottomLeading) {
                formatter.color(.primaryBG)
                    .edgesIgnoringSafeArea(.all)
                MainView()
                    .environmentObject(formatter)
                    .environmentObject(buildVM)
                    .environmentObject(exploreVM)
                    .environmentObject(gamesVM)
                    .environmentObject(participantsVM)
                    .environmentObject(profileVM)
                    .environmentObject(reportVM)
                    .environmentObject(searchVM)
                if formatter.deviceType == .iPhone && !formatter.showingAlert {
                    Button (action: {
                        formatter.showingTabBar.toggle()
                    }) {
                        HStack (spacing: 3) {
                            Text("Menu")
                            Image(systemName: "chevron.up")
                                .rotationEffect(Angle(degrees: formatter.showingTabBar ? 180 : 0))
                        }
                        .padding(formatter.padding())
                        .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                        .background(Color.white.opacity(0.4))
                        .clipShape(Capsule())
                    }
                }
                AlertView(alertStyle: .standard, titleText: formatter.alertTitle, subtitleText: formatter.alertSubtitle, hasCancel: formatter.hasCancel, actionLabel: formatter.actionLabel, action: {
                    formatter.alertAction()
                }, hasSecondaryAction: formatter.hasSecondaryAction, secondaryAction: {
                    formatter.secondaryAction()
                }, secondaryActionLabel: formatter.secondaryActionLabel)
                .environmentObject(formatter)
            }
            
            if formatter.showingTabBar {
                TabBarView()
                    .environmentObject(formatter)
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
                .transition(.identity)
        case .game:
            GameView()
                .transition(.identity)
        case .gamepicker:
            GamePickerView()
                .transition(.identity)
        case .reports:
            ReportsView()
                .transition(.identity)
        default:
            ProfileView()
                .transition(.identity)
        }
    }
}

struct TabBarView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @State var isVIP = UserDefaults.standard.value(forKey: "isVIP") as? Bool ?? false
    
    var body: some View {
        ZStack {
            HStack (spacing: 70) {
                TabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "magnifyingglass", selectedIconName: "magnifyingglass", myMenuChoice: .explore)
                if isVIP {
                    TabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "square.grid.3x2", selectedIconName: "square.grid.3x2.fill", myMenuChoice: .gamepicker)
                }
                TabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "gamecontroller", selectedIconName: "gamecontroller.fill", myMenuChoice: .game)
                TabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "person.circle", selectedIconName: "person.circle.fill", myMenuChoice: .profile)
            }
        }
        .padding(.bottom, 10)
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(formatter.color(.primaryFG))
        .shadow(color: Color.black.opacity(0.1), radius: 10)
        .edgesIgnoringSafeArea(.all)
    }
}

struct TabBarItemView: View {
    @EnvironmentObject var formatter: MasterHandler
    @Binding var menuChoice: MenuChoice
    
    let deselectedIconName: String
    let selectedIconName: String
    let myMenuChoice: MenuChoice
    
    var body: some View {
        VStack {
            Image(systemName: self.menuChoice == myMenuChoice ? selectedIconName : deselectedIconName)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(formatter.color(self.menuChoice == myMenuChoice ? .highContrastWhite : .mediumContrastWhite))
                .onTapGesture {
                    self.menuChoice = myMenuChoice
                }
            if menuChoice == myMenuChoice {
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .transition(.offset(y: -10))
                    .padding(.top, 2)
            }
        }
    }
}
