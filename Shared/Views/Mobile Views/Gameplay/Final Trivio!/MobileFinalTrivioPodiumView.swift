//
//  MobileFinalTrivioPodiumView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI
import ConfettiSwiftUI

struct MobileFinalTrivioPodiumView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var rating = 0
    
    var body: some View {
        VStack (spacing: 15) {
            
            // Title and rating
            VStack {
                Text(gamesVM.customSet.title)
                    .font(formatter.font(fontSize: .mediumLarge))
                    .foregroundColor(formatter.color(.primaryFG))
                MobileRatingView(rating: $rating)
            }
            .padding()
            .padding(.horizontal, 50)
            .background(formatter.color(.highContrastWhite))
            .cornerRadius(10)
            
            // Podiums View
            MobilePodiumsView()
            
            // Finished button
            Button(action: {
                guard let customSetID = gamesVM.customSet.id else { return }
                formatter.hapticFeedback(style: .soft, intensity: .strong)
                participantsVM.incrementGameStep()
                profileVM.markAsPlayed(gameID: customSetID)
                participantsVM.writeToFirestore(gameID: customSetID, myRating: rating)
                participantsVM.resetScores()
                gamesVM.reset()
                gamesVM.clearAll()
            }, label: {
                Text("Finish Game!")
                    .font(formatter.font())
                    .padding()
                    .padding(.horizontal)
                    .background(formatter.color(.lowContrastWhite))
                    .clipShape(Capsule())
            })
            .keyboardAware()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(formatter.color(.primaryAccent))
        .cornerRadius(20)
    }
}

struct MobileRatingView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var rating: Int
    
    var range: [Int] {
        var retRange = [Int]()
        for i in (0..<5) {
            retRange.append(i)
        }
        return retRange
    }
    var body: some View {
        HStack (spacing: 3) {
            ForEach(range, id: \.self) { i in
                Image(systemName: "star.fill")
                    .font(formatter.iconFont(.small))
                    .foregroundColor(formatter.color(rating >= i + 1 ? .secondaryAccent : .secondaryFG))
                    .onTapGesture {
                        formatter.hapticFeedback(style: .rigid, intensity: .weak)
                        rating = i + 1
                    }
            }
        }
    }
}

struct MobilePodiumsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var confettiCounter1: Int = 0
    @State var confettiCounter2: Int = 0
    @State var confettiCounter3: Int = 0
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack {
                
                if let firstPlaceIndex = participantsVM.getTeamIndexForPlace(.first) {
                    ZStack {
                        MobileSinglePodiumView(teamIndex: firstPlaceIndex, placing: .first)
                        ConfettiCannon(counter: $confettiCounter1, repetitions: 3)
                            .animation(.easeInOut(duration: 5))
                    }
                    .onAppear {
                        confettiCounter1 += 1
                    }
                }
                if let secondPlaceIndex = participantsVM.getTeamIndexForPlace(.second) {
                    ZStack {
                        MobileSinglePodiumView(teamIndex: secondPlaceIndex, placing: .second)
                        ConfettiCannon(counter: $confettiCounter2, repetitions: 3)
                            .animation(.easeInOut(duration: 5))
                    }
                    .onAppear {
                        confettiCounter2 += 1
                    }
                }
                if let thirdPlaceIndex = participantsVM.getTeamIndexForPlace(.third) {
                    ZStack {
                        MobileSinglePodiumView(teamIndex: thirdPlaceIndex, placing: .third)
                        ConfettiCannon(counter: $confettiCounter3, repetitions: 3)
                            .animation(.easeInOut(duration: 5))
                    }
                    .onAppear {
                        confettiCounter3 += 1
                    }
                }
            }
        }
        .cornerRadius(10)
    }
}

struct MobileSinglePodiumView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var isShowing = false
    
    let teamIndex: Int
    let placing: Placing
    
    var animationDelay: Double {
        switch placing {
        case .first: return 0
        case .second: return 1
        case .third: return 2
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            // Score label with confetti layer
            Text("$\(participantsVM.teams[teamIndex].score)")
                .font(formatter.font(fontSize: .large))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(formatter.color(.primaryBG))
                .cornerRadius(10)
            
            // Podium with medals
            VStack {
                VStack (spacing: 0) {
                    Text(participantsVM.teams[teamIndex].name)
                        .font(formatter.font(fontSize: .semiLarge))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(ColorMap().getColor(color: participantsVM.teams[teamIndex].color))
                        .cornerRadius(10)
                    switch placing {
                    case .first:
                        Image("medal.1")
                        Spacer()
                            .frame(maxHeight: 30)
                    case .second:
                        Image("medal.2")
                        Spacer()
                            .frame(maxHeight: 20)
                    default:
                        Image("medal.3")
                    }
                }
                .padding()
            }
            .background(formatter.color(.primaryFG))
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity)
        .offset(x: isShowing ? 0 : -UIScreen.main.bounds.width)
        .onAppear {
            isShowing = true
        }
        .animation(.spring().delay(animationDelay))
    }
}

