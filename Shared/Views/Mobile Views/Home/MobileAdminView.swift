//
//  MobileAdminView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/29/22.
//

import Foundation
import SwiftUI

struct MobileAdminView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack (spacing: 15) {
                Spacer(minLength: 15)
                MobileAdminVIPLookupView()
                    .padding(.horizontal)
                MobileAdminVIPStatusPanelView()
                    .padding(.horizontal)
                MobileAdminActivityView()
            }
        }
        .withBackButton()
        .withBackground()
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MobileAdminVIPLookupView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    @State var vipLookupString = ""
    @State var hasSearched = false
    
    var body: some View {
        VStack (spacing: 0) {
            HStack (spacing: 7) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(formatter.color(.lowContrastWhite))
                ZStack (alignment: .leading) {
                    Text(vipLookupString.isEmpty ? "Username to assign VIP" : "")
                        .font(formatter.font(.regularItalic, fontSize: .medium))
                        .foregroundColor(formatter.color(.lowContrastWhite))
                    TextField("", text: $vipLookupString) {
                        exploreVM.queryUserRecord(username: vipLookupString)
                        hasSearched = true
                    }
                    .font(formatter.font(.regular, fontSize: .medium))
                }
                Button {
                    hasSearched = false
                    vipLookupString.removeAll()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                }
                .opacity(vipLookupString.isEmpty ? 0 : 1)
            }
            .padding()
            if hasSearched && !exploreVM.queriedUserRecords.isEmpty {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(formatter.color(.lowContrastWhite))
                    .padding(.leading)
                VStack {
                    HStack {
                        Text("Username")
                        Text("isVIP")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(formatter.font(fontSize: .small))
                    ForEach(exploreVM.queriedUserRecords, id: \.self) { userRecord in
                        HStack {
                            Text("\(userRecord.username)")
                                .font(formatter.font(.regular, fontSize: .mediumLarge))
                            Spacer()
                            ZStack(alignment: (userRecord.isVIP ? .trailing : .leading)) {
                                Capsule()
                                    .frame(width: 30, height: 15)
                                    .foregroundColor(formatter.color(userRecord.isVIP ? .secondaryAccent : .primaryBG))
                                Circle()
                                    .frame(width: 15, height: 15)
                            }
                            .animation(.easeInOut(duration: 0.1), value: UUID().uuidString)
                            .onTapGesture {
                                exploreVM.toggleUserRecordIsVIP(username: userRecord.username)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(formatter.color(.primaryFG))
        .cornerRadius(5)
    }
}

struct MobileAdminVIPStatusPanelView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 25) {
            Text("VIP status panel")
                .font(formatter.font(fontSize: .mediumLarge))
            VStack (spacing: 7) {
                HStack {
                    Text("Current VIP name")
                    Spacer()
                    Text("Username")
                }
                .font(formatter.font(fontSize: .small))
                .padding(.trailing)
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(formatter.color(.lowContrastWhite))
                ForEach(profileVM.currentVIPs.sorted(by: >), id: \.key) { username, name in
                    VStack {
                        HStack {
                            Text(username)
                            Spacer()
                            Text(name)
                        }
                        .font(formatter.font(.regular, fontSize: .regular))
                        .padding(.trailing)
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(formatter.color(.lowContrastWhite))
                    }
                }
            }
        }
        .padding([.vertical, .leading])
        .background(formatter.color(.secondaryFG))
        .cornerRadius(5)
    }
}

struct MobileAdminActivityView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm"
        return df
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 25) {
            HStack {
                Text("Recent activity")
                    .font(formatter.font(fontSize: .mediumLarge))
                Spacer()
                Text("Limit to 50")
                    .font(formatter.font(fontSize: .medium))
            }
            .padding(.horizontal)
            VStack {
                HStack {
                    Text("Username")
                        .frame(width: 120, alignment: .leading)
                    Text("Last logged in")
                    Text("Total sessions")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing)
                }
                .font(formatter.font(fontSize: .small))
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(formatter.color(.lowContrastWhite))
                ForEach(profileVM.allUserRecords, id: \.self) { myUserRecord in
                    VStack {
                        HStack {
                            Text(myUserRecord.username)
                                .frame(width: 120, alignment: .leading)
                                .font(formatter.font(.bold, fontSize: .regular))
                            Text(dateFormatter.string(from: myUserRecord.mostRecentSession))
                            Text("\(myUserRecord.numTrackedSessions)")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing)
                        }
                        .font(formatter.font(.regular, fontSize: .regular))
                        .padding(.top, 3)
                        .padding(.bottom, 2)
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(formatter.color(.lowContrastWhite))
                    }
                }
            }
            .padding(.leading)
        }
    }
}

struct MobileHomepageAdminPanelView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var isPresentingAdminView = false
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm"
        return df
    }
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading, spacing: 15) {
                HStack (alignment: .top) {
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Admin panel")
                            .font(formatter.font(fontSize: .medium))
                        Text("Hi. You are one of the creators of this universe. These are the statistics you are looking for.")
                            .font(formatter.font(.regular, fontSize: .regular))
                            .lineSpacing(4)
                    }
                    Spacer(minLength: 10)
                    Button {
                        isPresentingAdminView.toggle()
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 18))
                            .frame(width: 35, height: 35)
                            .background(formatter.color(.secondaryFG))
                            .cornerRadius(3)
                    }
                }
                .padding([.top, .horizontal])
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(formatter.color(.lowContrastWhite))
                VStack (alignment: .leading, spacing: 10) {
                    Text("Recent activity")
                        .font(formatter.font(fontSize: .medium))
                        .padding(.horizontal)
                    VStack {
                        HStack {
                            Text("Username")
                                .frame(width: 100, alignment: .leading)
                            Text("Last logged in")
                            Text("Total sessions")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing)
                        }
                        .font(formatter.font(fontSize: .small))
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(formatter.color(.lowContrastWhite))
                        ForEach(profileVM.allUserRecords.prefix(5), id: \.self) { myUserRecord in
                            VStack {
                                HStack {
                                    Text(myUserRecord.username)
                                        .frame(width: 100, alignment: .leading)
                                        .font(formatter.font(.bold, fontSize: .regular))
                                    Text(dateFormatter.string(from: myUserRecord.mostRecentSession))
                                    Text("\(myUserRecord.numTrackedSessions)")
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding(.trailing)
                                }
                                .font(formatter.font(.regular, fontSize: .regular))
                                .padding(.top, 3)
                                .padding(.bottom, 2)
                                Rectangle()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 1)
                                    .foregroundColor(formatter.color(.lowContrastWhite))
                            }
                        }
                    }
                    .padding([.top, .leading])
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                formatter.hapticFeedback(style: .light)
                isPresentingAdminView.toggle()
            }
            NavigationLink(destination: MobileAdminView()
                .navigationBarTitle("Admin Panels", displayMode: .inline),
                           isActive: $isPresentingAdminView,
                           label: { EmptyView() }).hidden()
        }
        .padding(.bottom)
        .background(formatter.color(.primaryFG))
        .cornerRadius(10)
    }
}
