//
//  MobileDailyTrivioView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 3/22/22.
//

import Foundation
import SwiftUI
import ConfettiSwiftUI

struct MobileDailyTrivioView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var body: some View {
        VStack {
            MobileDTHeaderView()
            ZStack {
                VStack {
                    MobileDTCardView()
                    MobileDTKeyboardView()
                        .disabled(dtVM.gameStatus != .ongoing)
                }
                if dtVM.dtDisplayMode[.info] == true {
                    MobileDTInfoView()
                } else if dtVM.dtDisplayMode[.stats] == true {
                    MobileDTFinishedView()
                }
            }
        }
    }
}

struct MobileDTHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var infoSelected: Bool {
        return dtVM.dtDisplayMode[.info] ?? false
    }
    
    var finalSelected: Bool {
        return dtVM.dtDisplayMode[.stats] ?? false
    }
    
    var body: some View {
        HStack {
            Button {
                if dtVM.gameStatus == .ongoing {
                    formatter.setAlertSettings(alertAction: {
                        formatter.showingDT.toggle()
                    }, alertTitle: "Exit the daily trivio?", alertSubtitle: "Your score will be logged as 0 for the day.", hasCancel: true, actionLabel: "Yes, exit")
                } else {
                    formatter.showingDT.toggle()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(formatter.iconFont(.small))
            }
            
            Text("Daily Trivio!")
                .font(formatter.font(.bold, fontSize: .mediumLarge))
            Spacer()
            
            if dtVM.gameStatus != .notBegun && dtVM.gameStatus != .ongoing {
                Button {
                    dtVM.toggleShowingStats()
                } label: {
                    Image(systemName: finalSelected ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.line.uptrend.xyaxis.circle")
                        .font(formatter.iconFont(.medium))
                }
                .opacity(dtVM.dtDisplayMode[.info] == true ? 0.3 : 1)
                .disabled(dtVM.dtDisplayMode[.info] == true)
            }
            
            if dtVM.gameStatus != .notBegun {
                Button {
                    dtVM.toggleShowingInfo()
                } label: {
                    Image(systemName: infoSelected ? "info.circle.fill" : "info.circle")
                        .font(formatter.iconFont(.medium))
                }
                .opacity(dtVM.dtDisplayMode[.stats] == true ? 0.3 : 1)
                .disabled(dtVM.dtDisplayMode[.stats] == true)
            }
        }
        .padding(.horizontal, 10)
    }
}

struct MobileDTCardView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var body: some View {
        ZStack {
            if dtVM.gameStatus == .notBegun {
                MobileDTWaitingRoomView()
            } else {
                VStack (spacing: 20) {
                    MobileDTTimerBarView()
                    
                    MobileDTSetInfoView()
                    
                    MobileWordleAttemptsView()
                }
                .padding([.horizontal, .top], 10)
            }
            ConfettiCannon(counter: $dtVM.solved, rainHeight: 800, fadesOut: false, radius: 500, repetitions: 4)
                .animation(.easeIn(duration: 2))
                .onChange(of: dtVM.solved) { _ in
                    formatter.hapticFeedback(style: .rigid)
                }
        }
        .font(formatter.font(.bold, fontSize: .medium))
        .frame(maxHeight: .infinity)
        .background(formatter.color(dtVM.gameStatus == .ongoing ? .primaryAccent : .primaryFG))
        .cornerRadius(10)
        .padding(.horizontal, 10)
        .animation(.easeInOut(duration: 0.2))
    }
}

struct MobileDTWaitingRoomView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var body: some View {
        VStack {
            ScrollView (.vertical, showsIndicators: false) {
                VStack (alignment: .center, spacing: 7) {
                    Text("How to Play")
                        .font(formatter.font(.bold, fontSize: .mediumLarge))
                        .padding(15)
                    MobileStaticInstructionsView()
                }
                .padding([.horizontal, .top], 10)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                dtVM.toggleStartGame()
            } label: {
                Text("Start timer")
                    .font(formatter.font(.boldItalic, fontSize: .small))
                    .foregroundColor(formatter.color(.primaryBG))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(formatter.color(.highContrastWhite))
                    .clipShape(Capsule())
                    .padding()
            }
            .padding(10)
        }
    }
}

struct MobileDTTimerBarView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var body: some View {
        HStack (spacing: 2) {
            ForEach(0..<10) { i in
                ZStack {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(formatter.color(.lowContrastWhite))
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(formatter.color(.secondaryAccent))
                        .opacity(dtVM.opacities[i])
                }
            }
        }
        .frame(height: 7)
        .clipShape(Capsule())
        .onReceive(dtVM.timer) { time in
            print("Received \(time)")
            dtVM.incrementTimeElapsed()
        }
    }
}

struct MobileDTSetInfoView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            HStack {
                VStack (spacing: 5) {
                    HStack (spacing: 3) {
                        Text("\(dtVM.dtSetStringDict[.categoryName] ?? "") for \(dtVM.dtSetStringDict[.amount] ?? "")")
                        Spacer()
                    }
                    .font(formatter.font(.bold, fontSize: .small))
                    HStack (spacing: 2) {
                        Text("Originally aired")
                        Text(dtVM.dtSetStringDict[.date] ?? "")
                        Spacer()
                    }
                    .font(formatter.font(.regularItalic, fontSize: .small))
                }
                Spacer()
                Text(String(dtVM.timeAllowed - dtVM.timeElapsed))
                    .font(formatter.font(.bold, fontSize: .small))
                    .frame(width: 40, height: 30)
                    .background(formatter.color(.primaryBG))
                    .cornerRadius(5)
            }
            Text(dtVM.dtSetStringDict[.clue] ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .lineSpacing(5)
        }
    }
}

struct MobileDTKeyboardView: View {
    var body: some View {
        VStack (spacing: 15) {
            MobileKeyboardRowView(keys: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"], spacing: 0, hasExtras: false)
            MobileKeyboardRowView(keys: ["a", "s", "d", "f", "g", "h", "j", "k", "l"], spacing: 14, hasExtras: false)
            MobileKeyboardRowView(keys: ["z", "x", "c", "v", "b", "n", "m"], spacing: 15, hasExtras: true)
        }
        .padding(7)
        .padding(.bottom, 30)
    }
}

struct MobileKeyboardRowView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    let keys: [String]
    let spacing: CGFloat
    let hasExtras: Bool
    
    var shouldDisable: Bool {
        return dtVM.gameStatus != .ongoing
    }
    
    var body: some View {
        HStack (spacing: 4) {
            if hasExtras {
                Button {
                    dtVM.enterWord()
                } label: {
                    Image(systemName: "return.right")
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(formatter.color(.secondaryFG))
                        .cornerRadius(5)
                }
                .disabled(shouldDisable)
                .opacity(shouldDisable ? 0.3 : 1)
            }
            
            ForEach(0..<keys.count) { i in
                let char = keys[i]
                Button {
                    dtVM.addChar(char: char)
                } label: {
                    Text(char)
                        .font(formatter.font(.regular, fontSize: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(dtVM.getKeyColor(char: char))
                        .cornerRadius(5)
                }
                .disabled(shouldDisable)
            }
            
            if hasExtras {
                Button {
                    dtVM.removeChar()
                } label: {
                    Image(systemName: "delete.left")
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(formatter.color(.secondaryFG))
                        .cornerRadius(5)
                }
                .disabled(shouldDisable)
                .opacity(shouldDisable ? 0.3 : 1)
            }
        }
        .padding(.horizontal, spacing)
    }
}

struct MobileWordleTextFieldView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    @State var scale: CGFloat = 1
    
    var body: some View {
        HStack (spacing: 3) {
            ForEach(0..<dtVM.correctResponse.count, id: \.self) { i in
                ZStack {
                    Text(dtVM.guessedWordAtIndex(i: i).uppercased())
                        .foregroundColor(dtVM.guessedWordAtIndex(i: i) == "@@" ? formatter.color(.primaryBG) : formatter.color(.highContrastWhite))
                        .font(formatter.font(.regular, fontSize: .mediumLarge))
                        .animation(nil)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(formatter.color(.primaryBG))
                .frame(height: 50)
                .scaleEffect(CGFloat(dtVM.scaleValues[i]))
                .animation(.easeIn(duration: 0.1))
            }
        }
    }
}

struct MobileWordleAttemptsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var attemptOpacities: [CGFloat] {
        return dtVM.getAttemptBarChartHeights().1
    }
    
    var body: some View {
        VStack (spacing: 5) {
            HStack (alignment: .bottom) {
                Text("ATTEMPTS")
                    .font(formatter.font(.bold, fontSize: .medium))
                    .foregroundColor(formatter.color(.secondaryAccent))
                Spacer()
                Text(String(dtVM.attemptedStrings.count))
                    .font(formatter.font(.bold, fontSize: .small))
                    .frame(width: 40, height: 30)
                    .background(formatter.color(.primaryBG))
                    .cornerRadius(5)
            }
            
            MobileWordleTextFieldView()
            
            // the rotation effect shenanigans are to flip the scrollview (top:bottom)
            ScrollView (.vertical, showsIndicators: false) {
                ScrollViewReader { scrollView in
                    VStack (spacing: 3) {
                        Spacer(minLength: 10)
                        ForEach (0..<dtVM.attemptedStrings.count, id: \.self) { attemptIndex in
                            MobileWordleAttemptView(attemptIndex: attemptIndex)
                                .id(attemptIndex)
                        }
                        .rotationEffect(Angle(degrees: 180)).scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                        .onChange(of: dtVM.attemptedStrings) { _ in
                            withAnimation(.easeInOut) {
                                scrollView.scrollTo(dtVM.attemptedStrings.count - 1, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .rotationEffect(Angle(degrees: 180)).scaleEffect(x: -1.0, y: 1.0, anchor: .center)
        }
    }
}

struct MobileWordleAttemptView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    let attemptIndex: Int
    var attempt: String {
        return dtVM.attemptedStrings[attemptIndex]
    }
    
    var body: some View {
        HStack (spacing: 3) {
            ForEach(0..<attempt.count, id: \.self) { i in
                ZStack {
                    Text(attempt[i].uppercased())
                        .font(formatter.font(.regular, fontSize: .mediumLarge))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(dtVM.getAttemptCharColor(attemptIndex: attemptIndex, charIndex: i))
                }
                .frame(height: 50)
            }
        }
    }
}
