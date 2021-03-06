//
//  SignInView.swift
//  Trivio
//
//  Created by David Chen on 3/2/21.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

struct SignInView: View {
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
            HStack {
                VStack (alignment: .leading, spacing: 20) {
                    Spacer()
                    HStack {
                        Text("Welcome to")
                            .foregroundColor(formatter.color(.highContrastWhite))
                        Text("Trivio!")
                            .foregroundColor(formatter.color(.secondaryAccent))
                        Spacer()
                    }
                    .font(formatter.font(fontSize: .extraLarge))
                    VStack (alignment: .leading) {
                        Text("If it’s your first time here, please sign up by tapping on the button below.")
                        Text("Our Terms of Agreement can be found here.")
                            .underline()
                            .onTapGesture {
                                let url = URL.init(string: "https://www.privacypolicies.com/live/3779e433-e05a-43db-8ca5-9d6df7e7a136")
                                guard let privURL = url, UIApplication.shared.canOpenURL(privURL) else { return }
                                UIApplication.shared.open(privURL)
                            }
                    }
                    .font(formatter.font(.regular, fontSize: .small))
                    Button {
                        isLogin.toggle()
                    } label: {
                        Text(isLogin ? "Sign Up" : "Log In")
                            .font(formatter.font())
                            .padding()
                            .padding(.horizontal, 30)
                            .background(RoundedRectangle(cornerRadius: 5).stroke(formatter.color(.highContrastWhite), lineWidth: 3))
                    }

                }
                .padding(80)
                .keyboardAware()
                Spacer()
                VStack (alignment: .leading, spacing: formatter.padding()) {
                    AuthHUDView(signInStage: $signInStage, isLogin: $isLogin)
                        .padding(.trailing, 100)
                    switch signInStage {
                    case .enterNumber:
                        AuthEnterNumberView(signInStage: $signInStage, number: $number, ID: $ID, alert: $alert, alertMessage: $alertMessage, isLogin: $isLogin)
                    case .verifyNumber:
                        AuthVerifyNumberView(isLoggedIn: $isLoggedIn, signInStage: $signInStage, number: $number, code: $code, ID: $ID, alert: $alert, alertMessage: $alertMessage, isLogin: $isLogin)
                    default:
                        AuthNameUsernameView(isLoggedIn: $isLoggedIn, signInStage: $signInStage, name: $name, username: $username, isLogin: $isLogin)
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.4)
                .background(formatter.color(.primaryFG))
            }
            .animation(.easeInOut)
            .edgesIgnoringSafeArea(.all)
            AlertView(alertStyle: .standard, titleText: formatter.alertTitle, subtitleText: formatter.alertSubtitle, hasCancel: formatter.hasCancel, actionLabel: formatter.actionLabel, action: {
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

struct AuthHUDView: View {
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
        ZStack (alignment: .bottomTrailing) {
            VStack (alignment: .leading, spacing: 20) {
                Spacer()
                Text(isLogin ? "Log In" : "Sign Up")
                    .font(formatter.font(fontSize: .extraLarge))
                HStack (spacing: 0) {
                    if signInStage != .enterNumber {
                        Button {
                            switch signInStage {
                            case .verifyNumber:
                                signInStage = .enterNumber
                            default:
                                signInStage = .verifyNumber
                            }
                        } label: {
                            HStack (spacing: 3) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Back")
                            }
                            .font(formatter.font())
                            .padding(.trailing)
                        }
                    }
                    Text(text)
                        .font(formatter.font(.regular))
                    Spacer()
                }
            }
            .padding(30)
            .padding(.trailing, 30)
            .foregroundColor(formatter.color(.highContrastWhite))
            .background(formatter.color(.primaryAccent))
            .clipShape(RoundedCorners(br: 70))
            Image("CircleGrid")
                .offset(x: 50, y: -85)
        }
    }
}

struct AuthEnterNumberView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var signInStage: SignInStage
    @Binding var number: String
    @Binding var ID: String
    @Binding var alert: Bool
    @Binding var alertMessage: String
    @Binding var isLogin: Bool
    
    @State var countryCode = "1"
    @State var showingPicker = false
    
    var body: some View {
        VStack (spacing: 15) {
            HStack (spacing: 15) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 20))
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 1, height: 20)
                HStack (spacing: 0) {
                    Text("+")
                    TextField("1", text: $countryCode)
                        .keyboardType(.numberPad)
                        .frame(width: 10)
                }
                TextField("Enter your number", text: $number)
                    .fixedSize(horizontal: false, vertical: true)
                    .keyboardType(.numberPad)
            }
            .font(formatter.font(fontSize: .mediumLarge))
            .foregroundColor(formatter.color(.highContrastWhite))
            .padding(.horizontal)
            .padding(.vertical, 20)
            .background(formatter.color(.secondaryFG))
            .accentColor(formatter.color(.secondaryAccent))
            .cornerRadius(5)
            Button {
                if hasValidEntry() {
                    formatter.resignKeyboard()
                    signInStage = .verifyNumber
                    PhoneAuthProvider.provider().verifyPhoneNumber("+" + countryCode + number, uiDelegate: nil) { (ID, err) in
                        if err != nil {
                            formatter.setAlertSettings(alertTitle: "Oops!", alertSubtitle: (err?.localizedDescription)!, hasCancel: false, actionLabel: "Got it")
                            return
                        }
                        self.ID = ID!
                    }
                }
            } label: {
                Text("Continue")
                    .font(formatter.font(fontSize: .mediumLarge))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(formatter.color(isLogin ? .primaryAccent : .secondaryAccent))
                    .cornerRadius(5)
            }
            .opacity(hasValidEntry() ? 1 : 0.5)
            Spacer()
                .frame(height: 100)
            Text("Your personal information will never be used to contact you. It’s simply used for user verification, then we never touch it again.")
                .font(formatter.font(.regular, fontSize: .small))
                .padding(.bottom, 60)
        }
        .padding(30)
        .keyboardAware(heightFactor: 0.7)
    }
    
    func hasValidEntry() -> Bool {
        return countryCode.count >= 1 && number.count >= 10
    }
}

struct AuthVerifyNumberView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var isLoggedIn: Bool
    @Binding var signInStage: SignInStage
    @Binding var number: String
    @Binding var code: String
    @Binding var ID: String
    @Binding var alert: Bool
    @Binding var alertMessage: String
    @Binding var isLogin: Bool
    
    @State var isLoading = false
    
    var db = Firestore.firestore()
    
    var body: some View {
        VStack (spacing: 15) {
            HStack (spacing: 15) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 1, height: 20)
                TextField("Enter Valid Code", text: $code)
                    .fixedSize(horizontal: false, vertical: true)
                    .keyboardType(.numberPad)
            }
            .font(formatter.font(fontSize: .mediumLarge))
            .foregroundColor(formatter.color(.highContrastWhite))
            .padding(.horizontal)
            .padding(.vertical, 20)
            .background(formatter.color(.secondaryFG))
            .accentColor(formatter.color(.secondaryAccent))
            .cornerRadius(5)
            Button {
                isLoading = true
                if hasValidCode() {
                    formatter.resignKeyboard()
                    let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.code)
                    Auth.auth().signIn(with: credential) { (result, error) in
                        if error != nil {
                            formatter.setAlertSettings(alertAction: {
                                formatter.resignKeyboard()
                                isLoading = false
                            }, alertTitle: "Oops!", alertSubtitle: (error?.localizedDescription)!, hasCancel: false, actionLabel: "Got it")
                            return
                        }
                        guard let myUID = Auth.auth().currentUser?.uid else { return }
                        let docref = self.db.collection("users").document(myUID)
                        docref.getDocument { (doc, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            if let doc = doc {
                                NotificationCenter.default.post(name: NSNotification.Name("LogInStatusChange"), object: nil)
                                if !doc.exists {
                                    signInStage = .nameUsername
                                } else {
                                    Auth.auth().addStateDidChangeListener { (auth, user) in
                                        if user?.uid == myUID {
                                            self.checkUsernameExists(uid: myUID, completion: { complete in
                                                UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                                                NotificationCenter.default.post(name: NSNotification.Name("LogInStatusChange"), object: nil)
                                            })
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } label: {
                HStack (spacing: 15) {
                    if isLoading {
                        LoadingView()
                            .padding(.vertical, 10)
                    } else {
                        Text("Continue")
                    }
                }
                .font(formatter.font(fontSize: .mediumLarge))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(formatter.color(isLogin ? .primaryAccent : .secondaryAccent))
                .cornerRadius(5)
            }
            .opacity(hasValidCode() ? 1 : 0.5)
            Spacer()
                .frame(height: 100)
        }
        .padding(30)
        .keyboardAware(heightFactor: 0.7)
    }
    
    func hasValidCode() -> Bool {
        return self.code.count == 6
    }
    
    func checkUsernameExists(uid: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(uid).getDocument { (docSnap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = docSnap else { return }
            if let _ = doc.get("username") as? String {
                completion(true)
            }
        }
    }
}

struct AuthNameUsernameView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var isLoggedIn: Bool
    @Binding var signInStage: SignInStage
    @Binding var name: String
    @Binding var username: String
    @Binding var isLogin: Bool
    
    @State var usernameValid = false
    @State var isLoading = false
    
    var db = Firestore.firestore()
    
    var nameValid: Bool {
        return !name.isEmpty
    }
    
    var allValid: Bool {
        return nameValid && usernameValid && checkForbiddenChars().isEmpty
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            VStack (alignment: .leading, spacing: 3) {
                HStack (spacing: 15) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 1, height: 20)
                    TextField("Name", text: $name)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .font(formatter.font(fontSize: .mediumLarge))
                .foregroundColor(formatter.color(.highContrastWhite))
                .padding(.horizontal)
                .padding(.vertical, 20)
                .background(formatter.color(.secondaryFG))
                .accentColor(formatter.color(.secondaryAccent))
                .cornerRadius(5)
            }
            
            VStack (alignment: .leading, spacing: 3) {
                HStack (spacing: 15) {
                    Image(systemName: "at")
                        .font(.system(size: 20))
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 1, height: 20)
                    TextField("Username", text: $username)
                        .fixedSize(horizontal: false, vertical: true)
                        .onChange(of: username) { change in
                            checkUsernameValid()
                        }
                }
                .font(formatter.font(fontSize: .mediumLarge))
                .foregroundColor(formatter.color(.highContrastWhite))
                .padding(.horizontal)
                .padding(.vertical, 20)
                .background(formatter.color(.secondaryFG))
                .accentColor(formatter.color(.secondaryAccent))
                .cornerRadius(5)
                
                if !username.isEmpty && !usernameValid {
                    Text("That username already exists")
                        .font(formatter.font(.boldItalic))
                        .foregroundColor(formatter.color(.secondaryAccent))
                } else if !checkForbiddenChars().isEmpty {
                    Text("Your username cannot contain a \(checkForbiddenChars()).")
                        .font(formatter.font(.boldItalic))
                        .foregroundColor(formatter.color(.secondaryAccent))
                }
            }
            .onReceive(timer) { time in
                if !username.isEmpty {
                    checkUsernameValid()
                }
            }
            Spacer()
                .frame(height: formatter.padding(size: 30))
            Button {
                if allValid {
                    isLoading = true
                    usernameFinishedUploading { success in
                        UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                        NotificationCenter.default.post(name: NSNotification.Name("LogInStatusChange"), object: nil)
                    }
                }
            } label: {
                HStack {
                    if isLoading {
                        LoadingView()
                            .padding(.vertical, 10)
                    } else {
                        Text("Enter Trivio!")
                    }
                }
                .font(formatter.font(fontSize: .mediumLarge))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(formatter.color(isLogin ? .primaryAccent : .secondaryAccent))
                .cornerRadius(5)
                .opacity(allValid ? 1 : 0.5)
            }
            Spacer()
                .frame(height: 100)
        }
        .padding(30)
        .keyboardAware(heightFactor: 0.7)
    }
    
    func checkUsernameExists(completion: @escaping (Bool) -> Void) {
        let docRef = db.collection("users")
            .whereField("username", isEqualTo: username.lowercased())
        docRef.addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            if let _ = data.first {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func checkUsernameValid() {
        checkUsernameExists { (success) -> Void in
            if success && !username.isEmpty {
                self.usernameValid = true
            } else {
                self.usernameValid = false
            }
        }
    }
    
    func checkForbiddenChars() -> String {
        var forbiddenReport = ""
        let forbiddenChars: [Character] = [" ", "/", "-", "&", "$", "#", "@", "!", "%", "^", "*", "(", ")", "+"]
        for char in forbiddenChars {
            if username.contains(String(char)) {
                forbiddenReport = String(char)
            }
        }
        if forbiddenReport.isEmpty {
            return ""
        } else {
            return forbiddenReport == " " ? "space" : "'" + forbiddenReport + "'"
        }
    }
    
    func usernameFinishedUploading(completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
        userRef.setData([
            "name" : name,
            "username" : username.lowercased()
        ], merge: true)
        userRef.addSnapshotListener { docSnap, error in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = docSnap else { return }
            let myUID = Auth.auth().currentUser?.uid
            if myUID == doc.documentID {
                completion(true)
            }
        }
    }
}

struct LoadingView: View {
    @EnvironmentObject var formatter: MasterHandler
    @State var timeElapsed = 0
    
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    var color: ColorType = .highContrastWhite
    
    var ticker: Int {
        return timeElapsed % 3
    }
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 7, height: 7)
                .foregroundColor(formatter.color(color))
                .offset(y: ticker == 0 ? -10 : 0)
            Circle()
                .frame(width: 7, height: 7)
                .foregroundColor(formatter.color(color))
                .offset(y: ticker == 1 ? -10 : 0)
            Circle()
                .frame(width: 7, height: 7)
                .foregroundColor(formatter.color(color))
                .offset(y: ticker == 2 ? -10 : 0)
        }
        .animation(Animation.easeInOut(duration: 0.25))
        .onReceive(timer) { time in
            timeElapsed += 1
        }
    }
}

enum SignInStage {
    case enterNumber, verifyNumber, nameUsername
}
