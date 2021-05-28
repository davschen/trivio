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
    @ObservedObject var formatter = MasterHandler()
    @ObservedObject var buildVM = BuildViewModel()
    @ObservedObject var exploreVM = ExploreViewModel()
    @ObservedObject var gamesVM = GamesViewModel()
    @ObservedObject var participantsVM = ParticipantsViewModel()
    @ObservedObject var profileVM = ProfileViewModel()
    @ObservedObject var reportVM = ReportViewModel()
    @ObservedObject var searchVM = SearchViewModel()
    
    var body: some View {
        ZStack {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
            
            if !isLoggedIn {
                SignInView(isLoggedIn: $isLoggedIn)
                    .foregroundColor(.white)
                    .environmentObject(formatter)
            } else {
                HomePageView()
                    .environmentObject(formatter)
                    .environmentObject(buildVM)
                    .environmentObject(exploreVM)
                    .environmentObject(gamesVM)
                    .environmentObject(participantsVM)
                    .environmentObject(profileVM)
                    .environmentObject(reportVM)
                    .environmentObject(searchVM)
            }
        }
        .foregroundColor(.white)
        .animation(.easeInOut)
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("LogInStatusChange"), object: nil, queue: .main) { (_) in
                let isLoggedIn = UserDefaults.standard.value(forKey: "isLoggedIn") as? Bool ?? false
                self.isLoggedIn = isLoggedIn
            }
        }
    }
}

enum MenuChoice {
    case explore, gamepicker, participants, game, reports, profile
}

