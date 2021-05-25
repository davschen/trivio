//
//  HomePageView.swift
//  Trivio!
//
//  Created by David Chen on 5/24/21.
//

import Foundation
import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var masterHandler: MasterHandler
    @ObservedObject var buildVM = BuildViewModel()
    @ObservedObject var exploreVM = ExploreViewModel()
    @ObservedObject var gamesVM = GamesViewModel()
    @ObservedObject var participantsVM = ParticipantsViewModel()
    @ObservedObject var profileVM = ProfileViewModel()
    @ObservedObject var reportVM = ReportViewModel()
    @ObservedObject var searchVM = SearchViewModel()
    
    var formatter = MasterHandler()
    
    var body: some View {
        VStack (spacing: 0) {
            ZStack (alignment: .bottomLeading) {
                Color("MainBG")
                    .edgesIgnoringSafeArea(.all)
                switch gamesVM.menuChoice {
                case .explore:
                    ExploreView()
                        .environmentObject(gamesVM)
                        .environmentObject(exploreVM)
                        .environmentObject(participantsVM)
                        .environmentObject(profileVM)
                case .game:
                    GameplayView()
                        .environmentObject(buildVM)
                        .environmentObject(gamesVM)
                        .environmentObject(participantsVM)
                        .environmentObject(profileVM)
                case .participants:
                    ParticipantsView()
                        .environmentObject(participantsVM)
                case .gamepicker:
                    GamePickerView()
                        .environmentObject(gamesVM)
                        .environmentObject(participantsVM)
                        .environmentObject(profileVM)
                        .environmentObject(searchVM)
                case .reports:
                    ReportsView()
                        .environmentObject(reportVM)
                default:
                    ProfileView()
                        .environmentObject(buildVM)
                        .environmentObject(gamesVM)
                        .environmentObject(participantsVM)
                        .environmentObject(profileVM)
                        .environmentObject(reportVM)
                        .environmentObject(searchVM)
                }
                if formatter.deviceType == .iPhone {
                    Button (action: {
                        gamesVM.showingTabBar.toggle()
                    }) {
                        ZStack {
                            Color.white
                                .opacity(0.2)
                                .frame(width: 40, height: 40)
                            Image(systemName: "chevron.up")
                        }
                        .clipShape(Circle())
                        .rotationEffect(Angle(degrees: gamesVM.showingTabBar ? 180 : 0))
                    }
                    .padding()
                }
            }
            if gamesVM.showingTabBar {
                TabBarView()
                    .environmentObject(gamesVM)
            }
        }
        .animation(.easeInOut)
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBarView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @State var hasHack = UserDefaults.standard.value(forKey: "hasHack") as? Bool ?? false
    
    var formatter = MasterHandler()
    
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
                            gamesVM.showingTabBar.toggle()
                        }
                    }
                Image(systemName: gamesVM.menuChoice == .profile ? "person.circle.fill" : "person.circle")
                    .foregroundColor(gamesVM.menuChoice == .profile ? .blue : .gray)
                    .onTapGesture {
                        gamesVM.menuChoice = .profile
                    }
            }
            
        }
        .font(.system(size: 20))
        .padding(.vertical, 15)
        .padding(.bottom, 10)
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .background(Color("DarkGray"))
        .shadow(color: Color.black.opacity(0.1), radius: 10)
        .edgesIgnoringSafeArea(.all)
    }
}
