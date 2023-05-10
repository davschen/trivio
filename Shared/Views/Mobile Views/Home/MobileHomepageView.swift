//
//  MobileExploreView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI
import StoreKit
import UniformTypeIdentifiers
import Combine

struct MobileHomepageView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var appStoreManager: AppStoreManager
    
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State private var headerVisible: Bool = true
    @State private var profileViewActive = false
    @State private var jeopardySeasonsViewActive = false
    @State private var willLoadMore = true
    
    var body: some View {
        NavigationView() {
            ZStack {
                ZStack {
                    if exploreVM.customSetsBatchIsLoading {
                        MobileEmptyHomepageView()
                            .shimmering()
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack (alignment: .leading, spacing: 30) {
                                VStack (alignment: .leading, spacing: 5) {
                                    HStack (spacing: 6) {
                                        Text("Trivia Decks")
                                            .font(formatter.font(.semiBold, fontSize: .mediumLarge))
                                            .kerning(-1.5)
                                        Text("NEW")
                                            .font(formatter.font(.boldItalic, fontSize: .micro))
                                            .padding(4)
                                            .padding(.horizontal, 4)
                                            .background(formatter.color(.primaryAccent))
                                            .clipShape(Capsule())
                                    }
                                    .padding(.horizontal, 10)
                                    ScrollView (.horizontal, showsIndicators: false) {
                                        HStack (spacing: 10) {
                                            MobileDailyChallengePreviewView()
                                            ForEach(exploreVM.allTriviaDecks, id: \.self) { triviaDeck in
                                                MobileTriviaDeckPreviewView(triviaDeck: triviaDeck, numFreshClues: 20)
                                            }
                                        }
                                        .frame(height: 200)
                                        .padding(.horizontal, 10)
                                    }
                                }
                                MobileHomepageFeedView(headerVisible: $headerVisible)
                                GeometryReader { geometry in
                                    Color.clear.preference(key: ScrollViewOffsetKey.self, value: geometry.frame(in: .named("scroll")).minY)
                                }
                                .frame(height: 1)
                            }
                            .padding(.top, 70)
                        }
                        .padding(.bottom)
                        .coordinateSpace(name: "scroll")
                        .onPreferenceChange(ScrollViewOffsetKey.self) { offset in //
                            // If the offset is less than 1, we're at the bottom of the ScrollView
                            if offset < 1000 && willLoadMore {
                                exploreVM.loadAdditionalPublicSets()
                                willLoadMore = false
                            }
                        }
                    }
                    VStack {
                        Spacer()
                        MobileExploreBuildPromptButtonView()
                    }
                    VStack {
                        MobileHomepageHeaderView(headerVisible: $headerVisible)
                        Spacer()
                    }
                    GeometryReader { reader in
                        formatter.color(buildVM.dirtyBit > 0 && !buildVM.currCustomSet.title.isEmpty ? .primaryFG : .primaryBG)
                            .frame(height: reader.safeAreaInsets.top, alignment: .top)
                            .ignoresSafeArea()
                    }
                }
                NavigationLink(destination: MobileProfileView()
                    .navigationBarTitle("Profile", displayMode: .inline),
                               isActive: $profileViewActive,
                               label: { EmptyView() }).isDetailLink(false).hidden()
                NavigationLink(destination: MobileJeopardySeasonsView()
                    .navigationBarTitle("All Seasons", displayMode: .inline),
                               isActive: $jeopardySeasonsViewActive,
                               label: { EmptyView() }).isDetailLink(false).hidden()
            }
            .navigationBarHidden(true)
            .withBackground()
            .animation(.easeInOut(duration: 0.2))
        }
    }
}

// Responsible for hiding the top bar when a user scrolls down
// The top bar reveals itself if a user scrolls up.
struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ScrollViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

extension Notification.Name {
    static let UIScrolledToBottomNotification = Notification.Name("UIScrolledToBottomNotification")
}

struct MobileEmptyHomepageView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack (alignment: .leading, spacing: 40) {
            VStack (alignment: .leading) {
                Rectangle()
                    .fill(formatter.color(.primaryFG))
                    .frame(width: 150, height: 25)
                    .cornerRadius(3)
                HStack {
                    Rectangle()
                        .fill(formatter.color(.primaryFG))
                        .frame(maxWidth: .infinity, minHeight: 180)
                        .cornerRadius(3)
                    Rectangle()
                        .fill(formatter.color(.primaryFG))
                        .frame(maxWidth: .infinity, minHeight: 180)
                        .cornerRadius(3)
                    Rectangle()
                        .fill(formatter.color(.primaryFG))
                        .frame(maxWidth: .infinity, minHeight: 180)
                        .cornerRadius(3)
                }
            }
            .padding(.horizontal, 10)
            VStack (alignment: .leading, spacing: 15) {
                Rectangle()
                    .fill(formatter.color(.primaryFG))
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .cornerRadius(3)
                VStack (alignment: .leading) {
                    HStack {
                        Rectangle()
                            .fill(formatter.color(.primaryFG))
                            .frame(width: 40, height: 25)
                            .cornerRadius(3)
                        Rectangle()
                            .fill(formatter.color(.primaryFG))
                            .frame(width: 40, height: 25)
                            .cornerRadius(3)
                    }
                    HStack {
                        Circle()
                            .fill(formatter.color(.primaryFG))
                            .frame(width: 50, height: 50)
                        VStack (alignment: .leading, spacing: 5) {
                            Rectangle()
                                .fill(formatter.color(.primaryFG))
                                .frame(maxWidth: .infinity, minHeight: 25)
                                .cornerRadius(3)
                            Rectangle()
                                .fill(formatter.color(.primaryFG))
                                .frame(maxWidth: .infinity, minHeight: 25)
                                .cornerRadius(3)
                            Rectangle()
                                .fill(formatter.color(.primaryFG))
                                .frame(maxWidth: .infinity, minHeight: 25)
                                .cornerRadius(3)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }
}

struct MobileDailyChallengePreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var hasPlayedDailyChallenge = false
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        let currentDate = Date()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: currentDate)
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            HStack (alignment: .top, spacing: 3) {
                Text("Daily Challenge")
                    .font(formatter.font(.bold, fontSize: .regular))
                    .lineLimit(1)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(formatter.color(.secondaryAccent))
                    .opacity(hasPlayedDailyChallenge ? 0 : 1)
            }
            Text("\(formattedDate)")
                .font(formatter.font(.regularItalic, fontSize: .regular))
            Spacer(minLength: 0)
            Text("Answer today's question and see how you stack up against the crowd.")
                .font(formatter.font(.regular, fontSize: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(2)
            Spacer(minLength: 0)
            Text("Streak: 8 days")
                .font(formatter.font(.regularItalic, fontSize: .regular))
        }
        .padding(15)
        .frame(width: 160)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Image("dailytrivio.bg")
                .resizable()
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(formatter.color(.highContrastWhite), lineWidth: 1)
                .opacity(hasPlayedDailyChallenge ? 0 : 1)
        )
    }
}

struct MobileTriviaDeckPreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    @State var triviaDeckGameplayViewActive = false
    
    var triviaDeck: TriviaDeck
    var numFreshClues: Int
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading, spacing: 5) {
                HStack (alignment: .top, spacing: 3) {
                    Text("\(triviaDeck.title)")
                        .lineLimit(1)
                        .font(formatter.font(.bold, fontSize: .regular))
                    Circle()
                        .frame(width: 5, height: 5)
                        .foregroundColor(formatter.color(.secondaryAccent))
                        .opacity(numFreshClues > 0 ? 1 : 0)
                }
                Text("\(numFreshClues) fresh clues")
                    .font(formatter.font(.regularItalic, fontSize: .regular))
                Spacer(minLength: 0)
                Text("\(triviaDeck.description)")
                    .font(formatter.font(.regular, fontSize: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(2)
            }
            .padding(15)
            .frame(width: 160)
            .frame(maxHeight: .infinity)
            .background(formatter.gradient(.primaryFG))
            .cornerRadius(10)
            .onTapGesture {
                triviaDeckGameplayViewActive.toggle()
                exploreVM.setCurrentTriviaDeck(triviaDeck: triviaDeck)
            }
            NavigationLink(destination: MobileTriviaDeckGameplayView(),
                           isActive: $triviaDeckGameplayViewActive,
                           label: { EmptyView() }
            ).isDetailLink(false).hidden()
        }
    }
}

struct MobileHomepageFeedView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    @Binding var headerVisible: Bool
    
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    
    private func handleScrollOffsetChange(_ newOffset: CGFloat) {
        let scrollDirection = newOffset - lastScrollOffset
        if scrollOffset > 0 {
            headerVisible = scrollDirection <= 0
        }
        lastScrollOffset = newOffset
    }
    
    var body: some View {
        VStack (spacing: 40) {
            ForEach(exploreVM.publicCustomSetsBatch.sorted(by: { $0.dateCreated > $1.dateCreated }), id: \.self) { customSetDurian in
                MobileHomepageCustomSetCellView(customSetDurian: customSetDurian)
                    .id(customSetDurian.id)
            }
        }
        .padding(.bottom, 150)
        .background(GeometryReader {
            Color.clear.preference(key: ViewOffsetKey.self,
                value: -$0.frame(in: .named("scroll")).origin.y)
        })
        .onPreferenceChange(ViewOffsetKey.self) {
            handleScrollOffsetChange($0)
            scrollOffset = $0
        }
    }
}

struct MobileHomepageCustomSetCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var currentCategoryIndex: Int = 0
    @State var scaleEffectFloat: CGFloat = 1
    @State var temporaryCustomSetIsLiked = false
    @State var currentLikedHeartOpacity: CGFloat = 0
    @State var setPreviewActive = false
    
    var customSetDurian: CustomSetDurian
    
    var body: some View {
        VStack (spacing: 0) {
            TabView(selection: $currentCategoryIndex) {
                ForEach(0..<customSetDurian.round1Len, id: \.self) { categoryIndex in
                    let categoryName = customSetDurian.round1CategoryNames[categoryIndex]
                    let clueSample = customSetDurian.round1Clues[categoryIndex]?.first ?? "NULL CLUE"
                    ZStack {
                        VStack {
                            VStack (spacing: 2) {
                                Text("\(categoryName.uppercased())")
                                    .id(categoryName)
                                    .font(formatter.font(.bold, fontSize: .small))
                                Text("for 200")
                                    .font(formatter.font(.bold, fontSize: .small))
                            }
                            .shadow(color: formatter.color(.primaryBG), radius: 10, x: 0, y: 5)
                            Spacer(minLength: 0)
                            Text("\(clueSample.uppercased())")
                                .id(clueSample)
                                .font(formatter.korinnaFont(sizeFloat: 20))
                                .shadow(color: formatter.color(.primaryBG), radius: 0, x: 2, y: 2)
                                .multilineTextAlignment(.center)
                                .lineLimit(5)
                                .padding(35)
                            Spacer(minLength: 0)
                        }
                        // Heart that shows up every time the user double taps
                        Image(systemName: "heart.fill")
                            .font(.system(size: 90))
                            .opacity(currentLikedHeartOpacity)
                            .scaleEffect(scaleEffectFloat)
                            .animation(.easeInOut(duration: 0.2))
                            .onChange(of: temporaryCustomSetIsLiked) { isLiked in
                                if !isLiked { return }
                                scaleEffectFloat = 0.7
                                currentLikedHeartOpacity = 1
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    currentLikedHeartOpacity = 0
                                }
                            }
                        NavigationLink(destination: MobileGamePreviewView(),
                                       isActive: $setPreviewActive,
                                       label: { EmptyView() }).hidden()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .frame(minHeight: 280, maxHeight: 300)
                    .background(formatter.gradient(.primaryAccent))
                    .opacity(currentCategoryIndex == categoryIndex ? 1 : 0.5)
                    .cornerRadius(5)
                    .scaleEffect(currentCategoryIndex == categoryIndex ? 1 : 0.95)
                    .tapRecognizer(tapSensitivity: 0.2, singleTapAction: selectSet, doubleTapAction: doubleTapAction)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(minHeight: 280, maxHeight: 300)
            HStack (spacing: 10) {
                // Like button icon
                Button {
                    formatter.hapticFeedback(style: .medium, intensity: .strong)
                    temporaryCustomSetIsLiked.toggle()
                } label: {
                    Image(systemName: temporaryCustomSetIsLiked ? "heart.fill" : "heart")
                        .foregroundColor(formatter.color(temporaryCustomSetIsLiked ? .red : .highContrastWhite ))
                        .scaleEffect(scaleEffectFloat)
                        .animation(.easeInOut(duration: 0.1))
                        .onChange(of: temporaryCustomSetIsLiked) { _ in
                            scaleEffectFloat = 0.3
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                scaleEffectFloat = 1
                            }
                        }
                }
                Image(systemName: "paperplane")
                Spacer()
                HStack (spacing: 5) {
                    ForEach(0..<customSetDurian.round1Len, id: \.self) { i in
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundColor(formatter.color(currentCategoryIndex == i ? .highContrastWhite : .lowContrastWhite))
                    }
                }
            }
            .font(.system(size: 22))
            .padding(10)
            MobileCustomSetCellView(customSet: customSetDurian)
        }
    }
    
    func selectSet() {
        setPreviewActive.toggle()
        formatter.hapticFeedback(style: .light)
        gamesVM.getCustomSetData(customSet: customSetDurian)
        participantsVM.resetScores()
    }
    
    func doubleTapAction() {
        formatter.hapticFeedback(style: .medium, intensity: .strong)
        temporaryCustomSetIsLiked = true
    }
}

struct MobileSetHorizontalScrollView: View {
    @EnvironmentObject var formatter: MasterHandler
    @Binding var customSets: [CustomSetDurian]
    
    var emptyLabelString: String = "Nothing yet! When you make a set, it’ll show up here."
    
    let labelText: String
    let promptText: String
    let buttonAction: () -> ()
    
    var body: some View {
        VStack (spacing: 5) {
            HStack {
                Text("\(labelText)")
                Spacer()
                Button {
                    buttonAction()
                } label: {
                    Text("\(promptText)")
                        .foregroundColor(formatter.color(.secondaryAccent))
                }
            }
            .padding(.horizontal, 15)
            MobileCustomSetsView(customSets: $customSets, emptyLabelString: emptyLabelString)
        }
    }
}

struct MobileHomepageHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM : BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var headerVisible: Bool
    
    @State var buildViewActive = false
    @State var profileViewActive = false
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                if buildVM.dirtyBit > 0 && !buildVM.currCustomSet.title.isEmpty {
                    HStack (alignment: .center) {
                        VStack (alignment: .leading, spacing: 5) {
                            Text("Set in progress")
                                .font(formatter.font(fontSize: .small))
                            Text("Tap to continue editing “\(buildVM.currCustomSet.title)”")
                                .font(formatter.font(.regular, fontSize: .small))
                        }
                        Spacer()
                        Button {
                            buildVM.writeToFirestore()
                            // This is so sketchy and I should switch to either a completion handler or async await but I'm LAZY right now!
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                buildVM.clearAll()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .padding()
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom, 7)
                    .background(formatter.color(.primaryFG))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        buildViewActive.toggle()
                    }
                }
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 22))
                    }
                    Spacer()
                    Text("Trivio!")
                        .kerning(-2)
                        .font(formatter.fontFloat(.extraBold, sizeFloat: 35))
                    Spacer()
                    Button {
                        formatter.hapticFeedback(style: .heavy, intensity: .weak)
                        profileViewActive.toggle()
                    } label: {
                        Text("\(exploreVM.getInitialsFromUserID(userID: profileVM.myUID ?? ""))")
                            .font(formatter.font(.boldItalic, fontSize: .micro))
                            .frame(width: 28, height: 28)
                            .background(formatter.color(.primaryAccent))
                            .clipShape(Circle())
                            .overlay(
                                    Circle()
                                        .stroke(formatter.color(.highContrastWhite), lineWidth: 1)
                                )
                    }
                }
                .padding(15)
                .background(formatter.color(.primaryBG))
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : -50)
            }
            
            NavigationLink(destination: MobileProfileView()
                .navigationBarTitle("Profile", displayMode: .inline),
                           isActive: $profileViewActive,
                           label: { EmptyView() }).isDetailLink(false).hidden()
            NavigationLink (isActive: $buildViewActive) {
                MobileBuildView()
            } label: { EmptyView() }.hidden()
        }
    }
}

struct MobileExploreBuildPromptButtonView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var isPresentingBuildView = false
    
    var bgColor: Color {
        return formatter.color(.primaryBG)
    }
    
    var body: some View {
        ZStack {
            VStack {
                Button {
                    formatter.hapticFeedback(style: .medium)
                    isPresentingBuildView.toggle()
                    buildVM.start()
                    // Request app store review if the conditions are right
                    let shouldRequestAndCurrentVersion = profileVM.shouldRequestAppStoreReview()
                    if shouldRequestAndCurrentVersion.0 {
                        if let windowScene = UIApplication.shared.windows.first?.windowScene { SKStoreReviewController.requestReview(in: windowScene) }
                        profileVM.updateMyUserRecords(fieldName: "lastVersionReviewPrompt", newValue: shouldRequestAndCurrentVersion.1)
                        profileVM.myUserRecords.lastVersionReviewPrompt = shouldRequestAndCurrentVersion.1
                    }
                } label: {
                    HStack {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("Build a Set!")
                    }
                    .shadow(color: Color.init(hex: "643316").opacity(0.5), radius: 10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(formatter.gradient(.secondaryAccent))
                    .cornerRadius(10)
                    .padding(.horizontal, 15)
                    .background(formatter.color(.primaryBG)
                        .mask(LinearGradient(gradient: Gradient(colors: [bgColor, bgColor, bgColor.opacity(0.5), .clear]), startPoint: .bottom, endPoint: .top))
                    )
                }
            }
            NavigationLink (isActive: $isPresentingBuildView) {
                MobileBuildView()
            } label: { EmptyView() }
                .hidden()
        }
    }
}

struct MobileExploreSectionHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    let labelText: String
    let promptText: String
    var buttonAction: () -> ()
    
    var body: some View {
        HStack {
            Text("\(labelText)")
            Spacer()
            Button {
                buttonAction()
            } label: {
                Text("\(promptText)")
                    .foregroundColor(formatter.color(.secondaryAccent))
            }
        }
        .padding(.horizontal, 15)
    }
}
