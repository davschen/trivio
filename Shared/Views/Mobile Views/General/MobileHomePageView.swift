//
//  MobileHomePageView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileHomePageView: View {
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
                MobileMainView()
                    .environmentObject(formatter)
                    .environmentObject(buildVM)
                    .environmentObject(exploreVM)
                    .environmentObject(gamesVM)
                    .environmentObject(participantsVM)
                    .environmentObject(profileVM)
                    .environmentObject(reportVM)
                    .environmentObject(searchVM)
                MobileAlertView(alertStyle: .standard, titleText: formatter.alertTitle, subtitleText: formatter.alertSubtitle, hasCancel: formatter.hasCancel, actionLabel: formatter.actionLabel, action: {
                    formatter.alertAction()
                }, hasSecondaryAction: formatter.hasSecondaryAction, secondaryAction: {
                    formatter.secondaryAction()
                }, secondaryActionLabel: formatter.secondaryActionLabel)
                .environmentObject(formatter)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MobileMainView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    var body: some View {
        TabView(selection: $gamesVM.menuChoice) {
            MobileExploreView()
                .tabItem {
                    MobileTabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "magnifyingglass", selectedIconName: "magnifyingglass", myMenuChoice: .explore)
                }
                .tag(MenuChoice.explore)
            if gamesVM.isVIP {
                MobileGamePickerView()
                    .withBackground()
                    .tabItem {
                        MobileTabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "lock.open", selectedIconName: "lock.open.fill", myMenuChoice: .gamepicker)
                    }
                    .tag(MenuChoice.gamepicker)
            }
            MobileGameView()
                .withBackground()
                .tabItem {
                    MobileTabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "gamecontroller", selectedIconName: "gamecontroller.fill", myMenuChoice: .game)
                }
                .tag(MenuChoice.game)
            MobileProfileView()
                .tabItem {
                    MobileTabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "person.circle", selectedIconName: "person.circle.fill", myMenuChoice: .profile)
                }
                .tag(MenuChoice.profile)
        }
        .accentColor(formatter.color(.highContrastWhite))
    }
}

struct MobileTabBarView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @State var isVIP = UserDefaults.standard.value(forKey: "isVIP") as? Bool ?? false
    
    var body: some View {
        ZStack {
            HStack {
                MobileTabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "magnifyingglass", selectedIconName: "magnifyingglass", myMenuChoice: .explore)
                Spacer(minLength: 0)
                if isVIP {
                    MobileTabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "lock.open", selectedIconName: "lock.open.fill", myMenuChoice: .gamepicker)
                    Spacer(minLength: 0)
                }
                MobileTabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "gamecontroller", selectedIconName: "gamecontroller.fill", myMenuChoice: .game)
                Spacer(minLength: 0)
                MobileTabBarItemView(menuChoice: $gamesVM.menuChoice, deselectedIconName: "person.circle", selectedIconName: "person.circle.fill", myMenuChoice: .profile)
            }
        }
        .frame(height: 90)
        .padding(.bottom, 10)
        .padding(.horizontal, 40)
        .background(formatter.color(.primaryFG))
        .shadow(color: Color.black.opacity(0.1), radius: 10)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MobileTabBarItemView: View {
    @EnvironmentObject var formatter: MasterHandler
    @Binding var menuChoice: MenuChoice
    
    let deselectedIconName: String
    let selectedIconName: String
    let myMenuChoice: MenuChoice
    
    var tabItemLabel: String {
        switch myMenuChoice {
        case .explore: return "Explore"
        case .game: return "Play"
        case .profile: return "Profile"
        default: return "Unlocked"
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: self.menuChoice == myMenuChoice ? selectedIconName : deselectedIconName)
                .font(formatter.iconFont(.large))
            Text(tabItemLabel)
                .font(formatter.font(fontSize: .small))
        }
    }
}
