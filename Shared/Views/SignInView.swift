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
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
            HStack {
                VStack (alignment: .leading, spacing: 20) {
                    Spacer()
                    HStack {
                        Text("Welcome to")
                            .foregroundColor(formatter.color(.highContrastWhite))
                        Text("Trivio!")
                            .foregroundColor(formatter.color(.secondaryFG))
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
                        
                    } label: {
                        Text("Sign Up")
                            .font(formatter.font())
                            .padding()
                            .padding(.horizontal, 30)
                            .background(RoundedRectangle(cornerRadius: 5).stroke(formatter.color(.highContrastWhite), lineWidth: 3))
                    }

                }
                .padding(80)
                Spacer()
                VStack (alignment: .leading, spacing: formatter.padding()) {
                    AuthHUDView(signInStage: $signInStage, isLogin: $isLogin)
                    switch signInStage {
                    case .enterNumber:
                        AuthEnterNumberView(signInStage: $signInStage, countryCode: $countryCode, number: $number, ID: $ID, alert: $alert, alertMessage: $alertMessage)
                    case .verifyNumber:
                        AuthVerifyNumberView(isLoggedIn: $isLoggedIn, signInStage: $signInStage, number: $number, code: $code, ID: $ID, alert: $alert, alertMessage: $alertMessage)
                    default:
                        AuthNameUsernameView(isLoggedIn: $isLoggedIn, signInStage: $signInStage, name: $name, username: $username)
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.3)
                .background(formatter.color(.primaryFG))
            }
            .animation(.easeInOut)
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
        ZStack {
            VStack (alignment: .leading, spacing: 20) {
                Spacer()
                Text(signInStage != .nameUsername ? (isLogin ? "Login" : "Sign up") : "Sign up")
                    .font(formatter.font(fontSize: .extraLarge))
                HStack {
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
                    }
                    Spacer()
                        .frame(width: formatter.padding())
                    Text(text)
                        .font(formatter.font(.regular))
                    Spacer()
                }
            }
            .padding(30)
            .padding(.trailing, 30)
            .foregroundColor(formatter.color(.highContrastWhite))
            .background(formatter.color(.secondaryFG))
            .clipShape(RoundedCorners(br: 70))
        }
        HStack {
            Spacer()
            Image("CircleGrid")
                .offset(x: 30, y: -50)
        }
    }
}

struct LoginSignUpView: View {
    @EnvironmentObject var formatter: MasterHandler
    @Binding var signInStage: SignInStage
    @Binding var isLogin: Bool
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Login or Sign up")
                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                .padding(10)
                .background(Color.white.opacity(0.5))
                .cornerRadius(5)
            Spacer()
                .frame(height: 10)
            Button {
                signInStage = .enterNumber
                isLogin = true
            } label: {
                Text("Login")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("LoMainFG"))
                    .clipShape(Capsule())
            }
            Button {
                signInStage = .enterNumber
                isLogin = false
            } label: {
                Text("Sign up")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("MainFG"))
                    .clipShape(Capsule())
                    .foregroundColor(Color("MainAccent"))
            }
            Text("By signing up, you agree to Trivio!'s Privacy Policy")
                .underline()
                .font(formatter.customFont(iPadSize: 15))
                .onTapGesture {
                    let url = URL.init(string: "https://www.privacypolicies.com/live/3779e433-e05a-43db-8ca5-9d6df7e7a136")
                    guard let privURL = url, UIApplication.shared.canOpenURL(privURL) else { return }
                    UIApplication.shared.open(privURL)
                }
        }
        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
        .foregroundColor(.white)
        .padding(.horizontal, formatter.padding())
    }
}

struct AuthEnterNumberView: View {
    @EnvironmentObject var formatter: MasterHandler
    @Binding var signInStage: SignInStage
    @Binding var countryCode: CountryCode
    @Binding var number: String
    @Binding var ID: String
    @Binding var alert: Bool
    @Binding var alertMessage: String
    @State var showingPicker = false
    
    var body: some View {
        VStack {
            HStack {
                Text("+" + countryCode.code)
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .font(formatter.font())
                    .background(formatter.color(.secondaryFG))
                    .cornerRadius(5)
                ZStack (alignment: .leading) {
                    if number.isEmpty {
                        Text("Enter your number")
                            .foregroundColor(.gray)
                    }
                    TextField("Enter your number", text: $number)
                        .fixedSize(horizontal: false, vertical: true)
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal)
                .padding(.vertical, 15)
                .font(formatter.font())
                .background(formatter.color(.secondaryFG))
                .accentColor(formatter.color(.secondaryAccent))
            }
            Spacer()
                .frame(height: formatter.padding(size: 30))
            Button {
                if hasValidEntry() {
                    formatter.resignKeyboard()
                    signInStage = .verifyNumber
                    PhoneAuthProvider.provider().verifyPhoneNumber("+" + self.countryCode.code + self.number, uiDelegate: nil) { (ID, err) in
                        if err != nil {
                            formatter.setAlertSettings(alertTitle: "Oops!", alertSubtitle: (err?.localizedDescription)!, hasCancel: false, actionLabel: "Got it")
                            return
                        }
                        self.ID = ID!
                    }
                }
            } label: {
                Text("Continue")
                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(formatter.color(.secondaryAccent))
                    .cornerRadius(5)
            }
            .opacity(hasValidEntry() ? 1 : 0.5)
        }
    }
    
    func hasValidEntry() -> Bool {
        return self.countryCode.code.count >= 1 && self.number.count >= 10
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
    @State var isLoading = false
    
    var db = Firestore.firestore()
    
    var body: some View {
        VStack {
            ZStack {
                ZStack (alignment: .leading) {
                    if number.isEmpty {
                        Text("Enter Valid Code")
                            .foregroundColor(.gray)
                    }
                    TextField("Enter Valid Code", text: $code)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal)
                .padding(.vertical, 15)
                .font(formatter.customFont(weight: "Medium", iPadSize: 14))
                .background(RoundedRectangle(
                    cornerRadius: 5, style: .continuous
                ).stroke(Color.white, lineWidth: 2))
                .accentColor(.white)
                HStack {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.green.opacity(hasValidCode() ? 1 : 0.3))
                        .clipShape(Circle())
                        .padding(.horizontal, 7)
                        .background(Circle().stroke(Color.white, lineWidth: 0.5))
                }
            }
            Spacer()
                .frame(height: formatter.padding(size: 30))
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
                HStack {
                    Text("Continue")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.horizontal, formatter.padding())
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("MainFG"))
                .clipShape(Capsule())
            }
            .opacity(hasValidCode() ? 1 : 0.5)
        }
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
        let binding = Binding<String>(get: {
            self.username
        }, set: {
            self.username = $0
            checkUsernameValid()
        })
        VStack {
            VStack (alignment: .leading, spacing: 3) {
                HStack {
                    Text("NAME")
                        .tracking(2)
                        .font(formatter.customFont(weight: "Medium", iPadSize: 14))
                    Spacer()
                }
                ZStack (alignment: .leading) {
                    if name.isEmpty {
                        Text("Enter Your Name")
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    TextField("Enter Your Name", text: $name)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, formatter.padding())
                .padding(.vertical, formatter.padding())
                .font(formatter.customFont(weight: "Medium", iPadSize: 14))
                .background(RoundedRectangle(
                    cornerRadius: 5, style: .continuous
                ).stroke(Color.white, lineWidth: 2))
                .accentColor(.white)
            }
            
            VStack (alignment: .leading, spacing: 3) {
                HStack {
                    Text("USERNAME")
                        .tracking(2)
                        .font(formatter.customFont(iPadSize: 14))
                    Spacer()
                }
                ZStack (alignment: .leading) {
                    if username.isEmpty {
                        Text("Enter Your Username")
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    HStack {
                        TextField("Enter Your Username", text: binding)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.white)
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.green.opacity(!username.isEmpty && usernameValid ? 1 : 0.3))
                            .clipShape(Circle())
                            .padding(.horizontal, 7)
                            .background(Circle().stroke(Color.white, lineWidth: 0.5))
                    }
                }
                .padding(.horizontal, formatter.padding())
                .padding(.vertical, formatter.padding())
                .font(formatter.customFont(weight: "Medium", iPadSize: 14))
                .background(RoundedRectangle(
                    cornerRadius: 5, style: .continuous
                ).stroke(Color.white, lineWidth: 2))
                .accentColor(.white)
                if !username.isEmpty && !usernameValid {
                    Text("That username already exists")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 12))
                        .foregroundColor(.red)
                } else if !checkForbiddenChars().isEmpty {
                    Text("Your username cannot contain a \(checkForbiddenChars()).")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 12))
                        .foregroundColor(.red)
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
                    self.usernameFinishedUploading { success in
                        UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                        NotificationCenter.default.post(name: NSNotification.Name("LogInStatusChange"), object: nil)
                    }
                }
            } label: {
                HStack {
                    Text("Enter Trivio!")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.horizontal, formatter.padding())
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("MainFG"))
                .clipShape(Capsule())
                .opacity(allValid ? 1 : 0.5)
            }
        }
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

enum SignInStage {
    case enterNumber, verifyNumber, nameUsername
}
