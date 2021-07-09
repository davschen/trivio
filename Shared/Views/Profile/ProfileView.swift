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
                HStack (spacing: 20) {
                    // Menu
                    VStack {
                        AccountInfoView()
                        ProfileMenuSelectionView()
                        Spacer()
                        ProfileBottomButtonsView()
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.25)
                    .padding(30)
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



struct MySetsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State var idSelected = ""
    
    var body: some View {
        VStack {
            if (formatter.deviceType == .iPad && !gamesVM.selectedEpisode.isEmpty) || (formatter.deviceType == .iPhone && gamesVM.previewViewShowing) {
                GamePreviewView()
            }
            if gamesVM.customSets.count > 0 {
                if formatter.deviceType == .iPad || (formatter.deviceType == .iPhone && !gamesVM.previewViewShowing) {
                    VStack (spacing: 4) {
                        CustomSetView(isMine: true, customSets: gamesVM.customSets)
                    }
                }
            } else {
                HStack {
                    Text("You haven't made any sets yet — tap the button below to build one")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                        .foregroundColor(Color("MainAccent"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, formatter.padding(size: 40))
                .padding(formatter.padding())
                .background(Color.gray.opacity(0.5))
                .cornerRadius(5)
            }
            Spacer()
            Button {
                buildVM.start()
            } label: {
                HStack {
                    Image(systemName: "hammer")
                    Text("Build A Set")
                }
                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                .foregroundColor(Color("MainAccent"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.gray.opacity(0.4))
                .cornerRadius(formatter.shrink(iPadSize: 10))
            }
        }
    }
}

struct CustomSetView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State var offsetID = ""
    var isMine: Bool
    var customSets: [CustomSet]
    let cellKeyDict = CellKeyDict()
    
    var body: some View {
        GeometryReader { geometry in
            VStack (alignment: .leading, spacing: 5) {
                HStack (spacing: 10) {
                    Spacer()
                        .frame(width: 1)
                    Text("TITLE")
                        .tracking(2)
                        .frame(width: geometry.frame(in: .global).width * cellKeyDict.getProportion(of: .title), alignment: .leading)
                    Text("TAGS")
                        .tracking(2)
                        .frame(width: geometry.frame(in: .global).width * cellKeyDict.getProportion(of: .tags), alignment: .leading)
                    Image(systemName: "star")
                        .frame(width: geometry.frame(in: .global).width * cellKeyDict.getProportion(of: .rating), alignment: .leading)
                    Text("CLUES")
                        .tracking(2)
                        .frame(width: geometry.frame(in: .global).width * cellKeyDict.getProportion(of: .numclues), alignment: .leading)
                    Text("PLAYS")
                        .tracking(2)
                        .frame(width: geometry.frame(in: .global).width * cellKeyDict.getProportion(of: .numplays), alignment: .leading)
                    Spacer()
                    Image(systemName: "calendar")
                        .frame(width: geometry.frame(in: .global).width * cellKeyDict.getProportion(of: .date), alignment: .leading)
                        .offset(x: -13)
                    if isMine {
                        Text("")
                            .frame(width: geometry.frame(in: .global).width * cellKeyDict.getProportion(of: .edit), alignment: .leading)
                    }
                }
                .font(formatter.customFont(weight: "Medium", iPadSize: formatter.shrink(iPadSize: 14, factor: 1.5)))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
            }
        }
    }
}

struct CustomSetCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var set: CustomSet
    var isMine: Bool
    var setID: String {
        return set.id ?? "NID"
    }
    var played: Bool {
        return profileVM.beenPlayed(gameID: setID)
    }
    var selected: Bool {
        return gamesVM.selectedEpisode == setID
    }
    var rating: String {
        if set.rating == 0 {
            return "N/A"
        } else {
            return "\(String(format: "%.01f", round(set.rating * 10) / 10.0))/5"
        }
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            HStack {
                if !set.isPublic {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .bold))
                }
                Text("\(set.title)")
                    .font(formatter.font(fontSize: .mediumLarge))
                Spacer()
            }
            HStack {
                Text("\(set.numclues) clues")
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 10)
                HStack (spacing: 3) {
                    Text("\(rating)")
                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .bold))
                }
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 10)
                Text("\(set.plays) plays")
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 10)
                Text("\(gamesVM.dateFormatter.string(from: set.dateCreated))")
            }
            .font(formatter.font(.regular, fontSize: .small))
            .foregroundColor(formatter.color(.highContrastWhite))
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                    ForEach(set.tags, id: \.self) { tag in
                        Text("#" + tag.uppercased())
                            .font(formatter.font(fontSize: .small))
                            .foregroundColor(formatter.color(.primaryFG))
                            .padding(7)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
            }
            HStack {
                Button(action: {
                    buildVM.edit(gameID: setID)
                    buildVM.isEditingDraft = false
                }, label: {
                    Text("Edit")
                        .foregroundColor(formatter.color(.highContrastWhite))
                        .font(formatter.font(fontSize: .medium))
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.primaryAccent))
                        .cornerRadius(5)
                })
                Button(action: {
                    formatter.setAlertSettings(alertAction: {
                        buildVM.deleteSet(setID: setID)
                        gamesVM.deleteSet(setID: setID)
                        gamesVM.setEpisode(ep: "")
                    }, alertTitle: "Are You Sure?", alertSubtitle: "Deleting your set is irreversible. Your set \"\(set.title)\" has been played \(set.plays) times with a rating of \(String(format: "%.01f", round(set.rating * 10) / 10.0)) out of 5.", hasCancel: true, actionLabel: "Delete")
                }, label: {
                    Text("Delete")
                        .foregroundColor(formatter.color(.highContrastWhite))
                        .font(formatter.font(fontSize: .medium))
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.lowContrastWhite).opacity(0.5))
                        .cornerRadius(5)
                })
            }
        }
        .padding()
        .frame(width: 400)
        .background(formatter.color(.secondaryFG))
        .cornerRadius(10)
    }
}

// Some sugary code for determining size elements of custom cell views
enum CellElementType {
    case title, tags, rating, numclues, numplays, avgScore, date, edit
}

struct CellKeyDict {
    func getProportion(of element: CellElementType) -> CGFloat {
        switch element {
        case .title:
            return 0.2
        case .tags:
            return 0.2
        case .rating:
            return 0.1
        case .numclues:
            return 0.07
        case .numplays:
            return 0.07
        case .date:
            return 0.1
        default:
            return 0.05
        }
    }
}

struct CellElementView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @Binding var offsetID: String
    var cellElementType: CellElementType
    var set: CustomSet
    @State var geometry: GeometryProxy
    var isMine: Bool
    
    let cellKeyDict = CellKeyDict()
    
    var rating: String {
        if set.rating == 0 {
            return "N/A"
        } else {
            return "\(String(format: "%.01f", round(set.rating * 10) / 10.0))/5"
        }
    }
    var setID: String {
        return set.id ?? "NID"
    }
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack {
            switch cellElementType {
            case .title:
                HStack (spacing: 3) {
                    if !set.isPublic {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                    }
                    Text(set.title)
                }
            case .tags:
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                        ForEach(set.tags, id: \.self) { tag in
                            Text("#" + tag.uppercased())
                                .font(formatter.customFont(weight: "Bold Italic", iPadSize: 12))
                                .foregroundColor(Color("Darkened"))
                                .padding(3)
                                .background(Color.white)
                                .cornerRadius(3)
                                .minimumScaleFactor(0.1)
                        }
                    }
                }
            case .rating:
                Text(rating)
            case .numclues:
                Text("\(set.numclues)")
            case .numplays:
                Text("\(set.plays)")
            case .date:
                Text(gamesVM.dateFormatter.string(from: set.dateCreated))
            default:
                Button {
                    offsetID = offsetID == setID ? "" : setID
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(Angle(degrees: 90))
                        .padding(.horizontal, 2)
                }
            }
        }
        .frame(width: geometry.frame(in: .global).width * cellKeyDict.getProportion(of: cellElementType), alignment: .leading)
    }
}

struct DraftsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading) {
                Text("Drafts")
                    .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                Text("Tap to continue editing")
                    .font(formatter.customFont(weight: "Bold", iPadSize: 15))
            }
            if profileVM.drafts.count > 0 {
                ScrollView (.vertical) {
                    VStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                        ForEach(profileVM.drafts, id: \.self) { draft in
                            HStack {
                                Text(draft.title)
                                Spacer()
                                Text(gamesVM.dateFormatter.string(from: draft.dateCreated))
                                Button {
                                    formatter.setAlertSettings(alertAction: {
                                        if let id = draft.id {
                                            buildVM.deleteSet(isDraft: true, setID: id)
                                        }
                                    }, alertTitle: "Are You Sure?", alertSubtitle: "You're about to delete your draft named \"\(draft.title)\" — deleting a draft is irreversible.", hasCancel: true, actionLabel: "Yes, delete my draft")
                                } label: {
                                    Image(systemName: "trash.fill")
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                                        .padding(.leading, 5)
                                }
                            }
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            .padding(formatter.padding())
                            .background(Color("MainFG"))
                            .cornerRadius(5)
                            .onTapGesture {
                                if let id = draft.id {
                                    buildVM.edit(isDraft: true, gameID: id)
                                    buildVM.isEditingDraft = true
                                } else {
                                    formatter.setAlertSettings(alertTitle: "Whoops", alertSubtitle: "Set has no ID", hasCancel: true, actionLabel: "kk.")
                                }
                            }
                        }
                    }
                }
                .cornerRadius(5)
            } else {
                EmptyListView(label: "No drafts! Come back here when you save a draft.")
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
