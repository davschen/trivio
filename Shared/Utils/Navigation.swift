//
//  Navigation.swift
//  Trivio!
//
//  Created by David Chen on 7/25/21.
//

import Foundation
import SwiftUI

struct WithHeader: ViewModifier {
    let formatter = MasterHandler()
    
    var header: String
    
    func body(content: Content) -> some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.top)
            content
                .navigationBarTitle(header, displayMode: .automatic)
                .background(formatter.color(.primaryBG))
                .animation(.easeInOut)
        }
    }
}

struct WithBackground: ViewModifier {
    let formatter = MasterHandler()
    
    func body(content: Content) -> some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.top)
            content
                .background(formatter.color(.primaryBG))
                .animation(.easeInOut)
        }
    }
}

struct WithBackButton: ViewModifier {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let formatter = MasterHandler()
    
    func body(content: Content) -> some View {
        content
            .background(formatter.color(.primaryBG))
            .animation(.easeInOut)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: formatter.buttonBack {
                presentationMode.wrappedValue.dismiss()
            })
    }
}

extension View {
    func withBackButton() -> some View {
        self.modifier(WithBackButton())
    }
    
    func withHeader(_ header: String) -> some View {
        self.modifier(WithHeader(header: header))
    }
    
    func withBackground() -> some View {
        self.modifier(WithBackground())
    }
}

class Theme {
    static func navigationBarColors(background : UIColor?,
                                    titleColor : UIColor? = nil, tintColor : UIColor? = nil ) {
        
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = background ?? .clear
        
        navigationAppearance.titleTextAttributes = [
            .foregroundColor: titleColor ?? .black,
            .font: UIFont(name: "Metropolis-Bold", size: 16)!
        ]
        navigationAppearance.largeTitleTextAttributes = [
            .foregroundColor: titleColor ?? .black,
            .font: UIFont(name: "Metropolis-Bold", size: 24)!
        ]
        
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        UINavigationBar.appearance().tintColor = tintColor ?? titleColor ?? .black
    }
}
