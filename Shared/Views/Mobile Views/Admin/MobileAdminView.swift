//
//  MobileAdminView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/29/22.
//

import Foundation
import SwiftUI
import Introspect

struct MobileAdminView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack (spacing: 25) {
                    HStack {
                        Text("Trivia Deck Clue Submissions")
                            .font(formatter.font(.bold, fontSize: .regular))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding()
                    .background(formatter.color(.secondaryFG))
                    MobileAdminTriviaPackReviewView()
                    HStack {
                        Text("VIP Tracker")
                            .font(formatter.font(.bold, fontSize: .regular))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding()
                    .background(formatter.color(.secondaryFG))
                    VStack (spacing: 5) {
                        MobileAdminVIPLookupView()
                        MobileAdminVIPStatusPanelView()
                    }
                    .padding(.horizontal)
                    MobileAdminActivityView()
                        .padding(.bottom, 30)
                }
            }
        }
        .withBackButton()
        .navigationTitle("Admin Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .withBackground()
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MobileAdminTriviaPackReviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var isWritingRejectionNote = false
    @State var rejectionNote = ""
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/YY"
        return df
    }
    
    func rejectTriviaDeckClue() {
        if let triviaDeckClue = profileVM.triviaDeckCluesToReview.first {
            profileVM.rejectTriviaDeckClue(triviaDeckClue: triviaDeckClue, rejectionNote: rejectionNote)
            isWritingRejectionNote.toggle()
            rejectionNote.removeAll()
        }
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text("\(profileVM.triviaDeckCluesToReview.count) trivia deck clues to review")
                .padding(.leading)
            if profileVM.triviaDeckCluesToReview.count > 0 {
                Group {
                    VStack (spacing: 10) {
                        if let triviaDeckClue = profileVM.triviaDeckCluesToReview.first {
                            Text(triviaDeckClue.category)
                            Spacer(minLength: 10)
                            Text(triviaDeckClue.clue)
                                .frame(maxWidth: .infinity)
                                .font(formatter.bigCaslonFont(sizeFloat: 18))
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                            Text(triviaDeckClue.response.uppercased())
                                .font(formatter.bigCaslonFont(sizeFloat: 18))
                                .foregroundColor(formatter.color(.secondaryAccent))
                                .multilineTextAlignment(.center)
                            Spacer(minLength: 10)
                            Text("Submitted by \(triviaDeckClue.authorUsername) on \(dateFormatter.string(from: triviaDeckClue.submittedDate))")
                                .font(formatter.font(.regularItalic, fontSize: .regular))
                        }
                    }
                    .padding(20)
                    .background(formatter.color(.primaryFG))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    if isWritingRejectionNote {
                        VStack (spacing: 3) {
                            HStack {
                                Text("Rejection Note")
                                    .font(formatter.font(fontSize: .regular))
                                Spacer()
                                Button {
                                    isWritingRejectionNote.toggle()
                                } label: {
                                    Text("Cancel")
                                        .font(formatter.font(fontSize: .regular))
                                        .foregroundColor(formatter.color(.secondaryAccent))
                                }
                            }
                            Text("\(rejectionNote.count)/100 characters")
                                .font(formatter.font(.regular, fontSize: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack (alignment: .bottom, spacing: 20) {
                                MobileMultilineTextField("Your kind rejection note here...", text: $rejectionNote) {
                                    rejectTriviaDeckClue()
                                }
                                .offset(x: -5)
                                Button {
                                    rejectTriviaDeckClue()
                                } label: {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 20))
                                        .offset(y: -10)
                                }
                            }
                        }
                        .padding()
                        .background(formatter.color(.primaryFG))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    } else {
                        HStack (spacing: 5) {
                            Button {
                                isWritingRejectionNote.toggle()
                            } label: {
                                Text("Reject")
                                    .foregroundColor(formatter.color(.red))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                                    .background(formatter.color(.primaryFG))
                                    .clipShape(RoundedCorner(radius: 10, corners: [.bottomLeft, .topLeft]))
                            }
                            Button {
                                if let triviaDeckClue = profileVM.triviaDeckCluesToReview.first {
                                    profileVM.approveTriviaDeckClue(triviaDeckClue: triviaDeckClue)
                                }
                            } label: {
                                Text("Approve")
                                    .foregroundColor(formatter.color(.green))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                                    .background(formatter.color(.primaryFG))
                                    .clipShape(RoundedCorner(radius: 10, corners: [.bottomRight, .topRight]))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
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
        .cornerRadius(10)
    }
}

struct MobileAdminVIPStatusPanelView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 25) {
            Text("VIP status panel")
                .font(formatter.font(fontSize: .medium))
            VStack (spacing: 7) {
                HStack {
                    Text("VIP name")
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
                            Text(name)
                            Spacer()
                            Text(username)
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
        .cornerRadius(10)
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
                VStack (alignment: .leading, spacing: 3) {
                    Text("Recent activity")
                        .font(formatter.font(fontSize: .mediumLarge))
                    Text("Limited to 50")
                        .font(formatter.font(.regular, fontSize: .medium))
                }
                Spacer()
                Button {
                    profileVM.purgeAndPullAllUserRecords()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(Font.system(size: 20))
                }
            }
            .padding(.horizontal)
            VStack {
                HStack {
                    Text("Username")
                        .frame(width: 140, alignment: .leading)
                        .lineLimit(1)
                    Text("Last logged in")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Revisits")
                        .multilineTextAlignment(.trailing)
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
                                .frame(width: 140, alignment: .leading)
                                .font(formatter.font(.bold, fontSize: .regular))
                                .lineLimit(1)
                            Text(dateFormatter.string(from: myUserRecord.mostRecentSession))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(myUserRecord.numTrackedSessions)")
                                .multilineTextAlignment(.trailing)
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
        df.dateFormat = "MM-dd-yy HH:mm"
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
                            .cornerRadius(5)
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
                                .frame(width: 140, alignment: .leading)
                            Text("Last logged in")
                            Text("Revisits")
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
                                        .frame(width: 140, alignment: .leading)
                                        .font(formatter.font(.bold, fontSize: .regular))
                                        .lineLimit(1)
                                    Text(dateFormatter.string(from: myUserRecord.mostRecentSession))
                                        .lineLimit(1)
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
