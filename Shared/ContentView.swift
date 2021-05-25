//
//  ContentView.swift
//  Shared
//
//  Created by David Chen on 5/23/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var isLoggedIn = UserDefaults.standard.value(forKey: "isLoggedIn") as? Bool ?? false
    
    var body: some View {
        ZStack {
            if !isLoggedIn {
                SignInView(isLoggedIn: $isLoggedIn)
                    .foregroundColor(.white)
            } else {
                HomePageView()
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("LogInStatusChange"), object: nil, queue: .main) { (_) in
                let isLoggedIn = UserDefaults.standard.value(forKey: "isLoggedIn") as? Bool ?? false
                self.isLoggedIn = isLoggedIn
            }
        }
    }
}

struct HomePageView: View {
    @ObservedObject var buildVM = BuildViewModel()
    @ObservedObject var exploreVM = ExploreViewModel()
    @ObservedObject var gamesVM = GamesViewModel()
    @ObservedObject var participantsVM = ParticipantsViewModel()
    @ObservedObject var reportVM = ReportViewModel()
    @ObservedObject var searchVM = SearchViewModel()
    
    @State var hasHack = UserDefaults.standard.value(forKey: "hasHack") as? Bool ?? false
    
    var body: some View {
        VStack (spacing: 0) {
            ZStack {
                Color("MainBG")
                    .edgesIgnoringSafeArea(.all)
                switch gamesVM.menuChoice {
                case .explore:
                    ExploreView()
                        .environmentObject(gamesVM)
                        .environmentObject(exploreVM)
                        .environmentObject(participantsVM)
                case .game:
                    GameplayView()
                        .environmentObject(buildVM)
                        .environmentObject(gamesVM)
                        .environmentObject(participantsVM)
                case .participants:
                    ParticipantsView()
                        .environmentObject(participantsVM)
                case .gamepicker:
                    GamePickerView()
                        .environmentObject(gamesVM)
                        .environmentObject(participantsVM)
                        .environmentObject(searchVM)
                case .reports:
                    ReportsView()
                        .environmentObject(reportVM)
                default:
                    ProfileView()
                        .environmentObject(buildVM)
                        .environmentObject(gamesVM)
                        .environmentObject(participantsVM)
                        .environmentObject(reportVM)
                        .environmentObject(searchVM)
                }
            }
            HStack (spacing: 30) {
                Image(systemName: gamesVM.menuChoice == .explore ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    .foregroundColor(gamesVM.menuChoice == .explore ? .blue : .gray)
                    .onTapGesture {
                        self.gamesVM.menuChoice = .explore
                    }
                if hasHack {
                    Image(systemName: gamesVM.menuChoice == .gamepicker ? "square.grid.3x2.fill" : "square.grid.3x2")
                        .foregroundColor(gamesVM.menuChoice == .gamepicker ? .blue : .gray)
                        .onTapGesture {
                            self.gamesVM.menuChoice = .gamepicker
                        }
                }
                Image(systemName: gamesVM.menuChoice == .participants ? "person.3.fill" : "person.3")
                    .foregroundColor(gamesVM.menuChoice == .participants ? .blue : .gray)
                    .onTapGesture {
                        self.gamesVM.menuChoice = .participants
                    }
                Image(systemName: gamesVM.menuChoice == .game ? "gamecontroller.fill" : "gamecontroller")
                    .foregroundColor(gamesVM.menuChoice == .game ? .blue : .gray)
                    .onTapGesture {
                        self.gamesVM.menuChoice = .game
                    }
                Image(systemName: gamesVM.menuChoice == .profile ? "person.circle.fill" : "person.circle")
                    .foregroundColor(gamesVM.menuChoice == .profile ? .blue : .gray)
                    .onTapGesture {
                        self.gamesVM.menuChoice = .profile
                    }
            }
            .font(.system(size: 20))
            .padding(.vertical, 15)
            .padding(.bottom, 10)
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(Color("DarkGray"))
            .shadow(color: Color.black.opacity(0.1), radius: 10)
        }
        .animation(.easeInOut)
        .edgesIgnoringSafeArea(.all)
        .foregroundColor(.white)
    }
}

enum MenuChoice {
    case explore, gamepicker, participants, game, reports, profile
}

