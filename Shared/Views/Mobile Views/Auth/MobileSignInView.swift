//
//  MobileSignInView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseCore

struct MobileSignInView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var isLoggedIn: Bool
    
    @State var signInStage: SignInStage = .enterNumber
    @State var isLogin = false
    @State var isShowingVerify = false
    @State var countryCode = CountryCode(countryFullName: "United States", countryAbbreviation: "US", code: "1")
    @State var number = ""
    @State var code = ""
    @State var alertMessage = ""
    @State var ID = ""
    @State var alert = false
    @State var name = ""
    @State var username = ""
    @State var showGame = false
    
    var db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
            VStack (alignment: .leading, spacing: formatter.padding()) {
                MobileAuthHUDView(signInStage: $signInStage, isLogin: $isLogin)
                ScrollView(.vertical, showsIndicators: false) {
                    switch signInStage {
                    case .enterNumber:
                        MobileAuthEnterNumberView(signInStage: $signInStage, number: $number, ID: $ID, alert: $alert, alertMessage: $alertMessage, isLogin: $isLogin)
                    case .verifyNumber:
                        MobileAuthVerifyNumberView(isLoggedIn: $isLoggedIn, signInStage: $signInStage, number: $number, code: $code, ID: $ID, alert: $alert, alertMessage: $alertMessage, isLogin: $isLogin)
                    default:
                        MobileAuthNameUsernameView(isLoggedIn: $isLoggedIn, signInStage: $signInStage, name: $name, username: $username, isLogin: $isLogin)
                    }
                }
                .resignKeyboardOnDragGesture()
            }
            .frame(maxWidth: .infinity)
            .background(formatter.color(.primaryFG))
            .edgesIgnoringSafeArea(.all)
            
            MobileAlertView(alertStyle: .standard, titleText: formatter.alertTitle, subtitleText: formatter.alertSubtitle, hasCancel: formatter.hasCancel, actionLabel: formatter.actionLabel, action: {
                formatter.alertAction()
            })
        }
    }
    
    func hasValidEntry() -> Bool {
        return self.countryCode.code.count >= 1 && self.number.count >= 10
    }
    
    func hasValidCode() -> Bool {
        return self.code.count == 6
    }
}

struct MobileAuthHUDView: View {
    @EnvironmentObject var formatter: MasterHandler
    @Binding var signInStage: SignInStage
    @Binding var isLogin: Bool
    
    var text: String {
        switch signInStage {
        case .enterNumber:
            return "Enter your phone number"
        case .verifyNumber:
            return "Enter verification code"
        default:
            return "Enter your account info"
        }
    }
    
    var body: some View {
        ZStack (alignment: .bottom) {
            formatter.color(.primaryAccent)
                .edgesIgnoringSafeArea(.top)
                .frame(maxHeight: 150)
                .clipShape(RoundedCorners(bl: 30, br: 30))
            ZStack (alignment: .bottom) {
                if signInStage != .enterNumber {
                    Button {
                        formatter.setAlertSettings(alertAction: {
                            switch signInStage {
                            case .verifyNumber:
                                signInStage = .enterNumber
                            default:
                                signInStage = .verifyNumber
                            }
                        }, alertTitle: "Go Back?", alertSubtitle: "If you go back, you'll lose whatever sign in progress you made on this page.", hasCancel: true, actionLabel: "Yes, go back")
                        
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 25))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(maxHeight: 100, alignment: .bottom)
                            .padding(.bottom, 5)
                    }
                }
                Text("Sign In")
                    .font(formatter.font(fontSize: .large))
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 100, alignment: .bottom)
            }
            .padding()
            .foregroundColor(formatter.color(.highContrastWhite))
            .background(formatter.color(.primaryAccent))
            .frame(maxHeight: 150)
            .clipShape(RoundedCorners(bl: 30, br: 30))
        }
    }
}
