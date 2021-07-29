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
    
    init() {
        UINavigationBar.appearance().tintColor = UIColor(formatter.color(.highContrastWhite))
        UINavigationBar.appearance().barTintColor = UIColor(formatter.color(.primaryFG))
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(formatter.color(.highContrastWhite)), NSAttributedString.Key.font: UIFont(name: "Metropolis-Bold", size: 40)!]
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor(formatter.color(.highContrastWhite)), NSAttributedString.Key.font: UIFont(name: "Metropolis-Bold", size: 20)!]
        UINavigationBar.appearance().backgroundColor = UIColor(formatter.color(.primaryBG))
        
        UITabBar.appearance().barTintColor = UIColor(formatter.color(.primaryFG))
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Metropolis-Bold", size: 10)!], for: .normal)
        
        UIScrollView.appearance().keyboardDismissMode = .interactive
    }
    
    var body: some View {
        ZStack {
            if formatter.deviceType == .iPad {
                if !isLoggedIn {
                    SignInView(isLoggedIn: $isLoggedIn)
                        .foregroundColor(.white)
                        .environmentObject(formatter)
                } else {
                    HomePageView()
                }
            } else if formatter.deviceType == .iPhone {
                if !isLoggedIn {
                    MobileSignInView(isLoggedIn: $isLoggedIn)
                        .foregroundColor(.white)
                        .environmentObject(formatter)
                } else {
                    MobileHomePageView()
                }
            }
        }
        .foregroundColor(formatter.color(.highContrastWhite))
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
    case explore, gamepicker, game, reports, profile
}

