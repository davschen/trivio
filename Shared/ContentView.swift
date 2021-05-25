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
    @ObservedObject var masterHandler = MasterHandler()
    
    var body: some View {
        ZStack {
            if !isLoggedIn {
                SignInView(isLoggedIn: $isLoggedIn)
                    .foregroundColor(.white)
                    .environmentObject(masterHandler)
            } else {
                HomePageView()
                    .environmentObject(masterHandler)
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

enum MenuChoice {
    case explore, gamepicker, participants, game, reports, profile
}

