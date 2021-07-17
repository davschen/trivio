//
//  ProfileView.swift
//  Trivio
//
//  Created by David Chen on 3/22/21.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    @State var isShowingMenu = true
    @State var menuOffset: CGFloat = 0
    @State var editOn = false
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack {
            if !buildVM.showingBuildView {
                HStack (spacing: 30) {
                    // Menu
                    VStack {
                        AccountInfoView()
                        ProfileMenuSelectionView()
                        Spacer()
                        ProfileBottomButtonsView()
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.25)
                    .padding([.leading, .vertical], 30)
                    ZStack {
                        if !editOn {
                            switch profileVM.menuSelectedItem {
                            case "Summary":
                                SummaryView()
                            case "My Drafts":
                                DraftsView()
                            case "Past Games":
                                ReportsView()
                            default:
                                MySetsView()
                            }
                        } else {
                            Spacer()
                        }
                    }
                    .padding([.trailing, .top], 30)
                }
            } else {
                BuildView()
                    .environmentObject(searchVM)
                    .environmentObject(buildVM)
            }
        }
    }
}

struct AccountInfoView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading) {
                Text("\(profileVM.name)")
                    .font(formatter.font(.bold, fontSize: .large))
                    .foregroundColor(formatter.color(.highContrastWhite))
                Text("@\(profileVM.username)")
                    .font(formatter.font(.regular, fontSize: .medium))
                    .foregroundColor(formatter.color(.highContrastWhite))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
            
            Button(action: {
                
            }, label: {
                Text("Upgrade my Account")
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .font(formatter.font(.bold, fontSize: .medium))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(5)
            })
            
            Button(action: {
                
            }, label: {
                Text("Edit Info")
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .font(formatter.font(.bold, fontSize: .medium))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(.secondaryFG))
                    .cornerRadius(5)
            })
        }
        .padding()
        .background(formatter.color(.primaryFG))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}

struct ProfileMenuSelectionView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        ScrollView (.vertical) {
            VStack {
                Spacer()
                    .frame(height: 15)
                menuSelectionView(label: "Summary")
                menuSelectionView(label: "My Sets")
                menuSelectionView(label: "My Drafts")
                menuSelectionView(label: "Past Games")
            }
        }
    }
    
    func menuSelectionView(label: String) -> some View {
        Text(label)
            .font(formatter.font())
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(formatter.color(profileVM.menuSelectedItem == label ? .primaryAccent : .primaryBG))
            .cornerRadius(5)
            .onTapGesture {
                profileVM.menuSelectedItem = label
            }
    }
}

struct ProfileBottomButtonsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                buildVM.start()
            }, label: {
                HStack {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 15, weight: .bold))
                    Text("Build a Set")
                        .font(formatter.font())
                }
                .foregroundColor(formatter.color(.highContrastWhite))
                .padding()
                .frame(maxWidth: .infinity)
                .background(formatter.color(.secondaryAccent))
                .cornerRadius(5)
            })
            
            Button(action: {
                profileVM.logOut()
            }, label: {
                HStack {
                    Image(systemName: "gear")
                        .font(.system(size: 15, weight: .bold))
                    Text("Settings")
                        .font(formatter.font())
                }
                .foregroundColor(formatter.color(.highContrastWhite))
                .padding()
                .frame(maxWidth: .infinity)
                .background(formatter.color(.secondaryFG))
                .cornerRadius(5)
            })
        }
    }
}

struct ProfileMenuView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @Binding var editOn: Bool
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView (.vertical, showsIndicators: false) {
                VStack {
                    ProfileAvatarView(editOn: $editOn)
                    Spacer()
                        .frame(height: 30)
                    menuOptionView(label: "My Sets")
                    menuOptionView(label: "Drafts")
                    menuOptionView(label: "Past Games")
                    Spacer()
                        .frame(height: geometry.size.height * 0.30)
                    Button {
                        profileVM.logOut() 
                    } label: {
                        Text("Log Out")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(5)
                    }
                }
                .padding()
            }
        }
    }
    
    func menuOptionView(label: String) -> some View {
        Text(label)
            .font(formatter.customFont(weight: "Bold", iPadSize: 30))
            .padding(formatter.padding())
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(profileVM.menuSelectedItem == label ? 1 : 0.4))
            .cornerRadius(5)
            .onTapGesture {
                profileVM.menuSelectedItem = label
            }
    }
}

struct ProfileAvatarView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @State var valid = false
    @Binding var editOn: Bool
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        let binding = Binding<String>(get: {
            self.profileVM.username
        }, set: {
            self.profileVM.username = $0
            profileVM.checkUsernameValid()
        })
        VStack {
            if formatter.deviceType == .iPad {
                Text(profileVM.getInitials(name: profileVM.name))
                    .font(formatter.customFont(weight: "Bold", iPadSize: 60))
                    .frame(width: formatter.shrink(iPadSize: 150, factor: 1.5), height: formatter.shrink(iPadSize: 150, factor: 1.5))
                    .background(Color("MainFG"))
                    .clipShape(Circle())
            }
            NameTextFieldView(text: $profileVM.name, editOn: $editOn, label: "Name", placeholder: "Edit your name") {
                profileVM.writeKeyValueToFirestore(key: "name", value: profileVM.name)
            }
            UsernameTextFieldView(text: binding, editOn: $editOn, label: "Username", placeholder: "Edit your username") {
                profileVM.writeKeyValueToFirestore(key: "username", value: profileVM.username.lowercased())
            }
        }
    }
}

struct NameTextFieldView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @Binding var text: String
    @Binding var editOn: Bool
    @State var editingName = false
    var label: String
    var placeholder: String
    var perform: () -> ()
    var nameValid: Bool {
        return !text.isEmpty
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .tracking(2)
                .font(formatter.customFont(weight: "Bold", iPadSize: formatter.shrink(iPadSize: 14, factor: 1.5)))
            ZStack {
                if editingName {
                    ZStack (alignment: .leading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundColor(.gray)
                        }
                        TextField(placeholder, text: $text)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .font(formatter.customFont(weight: "Bold", iPadSize: 14))
                } else {
                    HStack {
                        Text(text)
                            .padding(.horizontal)
                            .padding(.vertical, 15)
                            .font(formatter.customFont(weight: "Bold", iPadSize: 14))
                        Spacer()
                    }
                }
                
                HStack {
                    Spacer()
                    Button {
                        if !text.isEmpty {
                            editingName.toggle()
                            editOn.toggle()
                            perform()
                        }
                    } label: {
                        Image(systemName: editingName ? "checkmark" : "pencil")
                            .font(.system(size: formatter.deviceType == .iPad ? 20 : 15))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(editingName ? Color.green.opacity(nameValid ? 1 : 0.4) : nil)
                            .clipShape(Circle())
                            .padding(.horizontal, 7)
                            .background(Circle().stroke(Color.white, lineWidth: 0.5))
                    }
                }
            }
            .background(RoundedRectangle(
                cornerRadius: 5, style: .continuous
            ).stroke(Color.white.opacity(editingName ? 1 : 0.5), lineWidth: 2))
            .accentColor(.white)
            if !nameValid {
                Text("Your name cannot be blank")
                    .font(formatter.customFont(weight: "Bold", iPadSize: 12))
                    .foregroundColor(.red)
            }
        }
    }
}

struct UsernameTextFieldView: View {
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @Binding var text: String
    // edit on tracks if user is editing either name or username. If so, I change the opacity of the right hand side to 0
    // editingUsername tracks if the username is being edited
    @Binding var editOn: Bool
    @State var editingUsername = false
    var label: String
    var placeholder: String
    var perform: () -> ()
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack (alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .tracking(2)
                .font(formatter.customFont(weight: "Bold", iPadSize: formatter.shrink(iPadSize: 14, factor: 1.5)))
            ZStack {
                if editingUsername {
                    ZStack (alignment: .leading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundColor(.gray)
                        }
                        TextField(placeholder, text: $text)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .font(formatter.customFont(weight: "Bold", iPadSize: 14))
                } else {
                    HStack {
                        Text(text)
                            .padding(.horizontal)
                            .padding(.vertical, 15)
                            .font(formatter.customFont(weight: "Bold", iPadSize: 14))
                        Spacer()
                    }
                }
                
                HStack {
                    Spacer()
                    Button {
                        if !editingUsername {
                            editingUsername.toggle()
                            editOn.toggle()
                        } else {
                            profileVM.checkUsernameValidWithHandler { (success) in
                                if success {
                                    editingUsername.toggle()
                                    editOn.toggle()
                                    perform()
                                } else {
                                    profileVM.checkUsernameValid()
                                }
                            }
                        }
                    } label: {
                        Image(systemName: editingUsername ? "checkmark" : "pencil")
                            .font(.system(size: formatter.deviceType == .iPad ? 20 : 15))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(editingUsername ? Color.green.opacity(profileVM.usernameValid ? 1 : 0.4) : nil)
                            .clipShape(Circle())
                            .padding(.horizontal, 7)
                            .background(Circle().stroke(Color.white, lineWidth: 0.5))
                    }
                }
            }
            .background(RoundedRectangle(
                cornerRadius: 5, style: .continuous
            ).stroke(Color.white.opacity(editingUsername ? 1 : 0.5), lineWidth: 2))
            .accentColor(.white)
            .onAppear {
                profileVM.checkUsernameValid()
            }
            if !profileVM.username.isEmpty && !profileVM.usernameValid {
                Text("That username already exists")
                    .font(formatter.customFont(weight: "Bold", iPadSize: 12))
                    .foregroundColor(.red)
            } else if !profileVM.checkForbiddenChars().isEmpty {
                Text("Your username cannot contain a \(profileVM.checkForbiddenChars()).")
                    .font(formatter.customFont(weight: "Bold", iPadSize: 12))
                    .foregroundColor(.red)
            }
        }
    }
}

struct EmptyListView: View {
    @EnvironmentObject var formatter: MasterHandler
    var label: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(formatter.customFont(weight: "Italic", iPadSize: 20))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
    }
}
