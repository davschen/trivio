//
//  MobileTriviaDeckClueView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/25/23.
//

import Foundation
import SwiftUI

struct MobileTriviaDeckClueView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    @State var responseString = ""
    @State var timer: Timer?
    @State var currentClueSecondsElapsed: Float = 0.0
    
    var clueState: TriviaDeckClueViewState {
        return exploreVM.triviaDeckClueViewState
    }
    
    var currentTriviaDeckClue: TriviaDeckClue {
        return exploreVM.currentTriviaDeckClue
    }
    
    var successRateString: String {
        let correctSubmissions = exploreVM.currentTriviaDeckClue.correctSubmissions
        let totalSubmissions = exploreVM.currentTriviaDeckClue.totalSubmissions
        
        if totalSubmissions == 0 {
            return "Success Rate: \(clueState.hasSolvedClue ? String(format: "%.0f", Float(100.0 / Float(clueState.currentClueNumAttempts))) : "N/A")%"
        }

        let successRate = Double(correctSubmissions) / Double(totalSubmissions) * 100
        let formattedSuccessRate = String(format: "%.0f", successRate)
        return "Success Rate: \(formattedSuccessRate)%"
    }
    
    var body: some View {
        VStack {
            VStack (spacing: 3) {
                if currentTriviaDeckClue.clue.isEmpty {
                    MobileTriviaDeckNoCluesView()
                } else {
                    Text("\(exploreVM.currentTriviaDeckClue.category)")
                        .font(formatter.font(.bold, fontSize: .regular))
                    Text("\(successRateString)")
                        .font(formatter.font(.regularItalic, fontSize: .small))
                    if clueState.hasSolvedClue {
                        MobileTriviaDeckClueSolvedView(responseString: $responseString, currentClueSecondsElapsed: $currentClueSecondsElapsed)
                    } else {
                        MobileTriviaDeckClueUnsolvedView()
                            .onAppear {
                                startTimer()
                            }
                    }
                }
            }
            .padding()
            .frame(minHeight: 360, maxHeight: .infinity)
            .background(formatter.color(.primaryFG))
            .cornerRadius(10)
            .padding([.top, .horizontal], 10)
            
            HStack (spacing: 5) {
                MobileTriviaDeckTimerAnimatedPieChart(currentClueSecondsElapsed: $currentClueSecondsElapsed)
                Text("\(String(format: "%0.1f", currentClueSecondsElapsed))s")
                    .offset(y: 1)
                Spacer()
                Text("\(clueState.currentClueNumAttempts)\(getNumberSuffix(clueState.currentClueNumAttempts)) try")
            }
            .font(formatter.font(.regular))
            .padding([.horizontal, .top], 10)
            .opacity(currentTriviaDeckClue.clue.isEmpty ? 0.4 : 1)
            
            MobileTriviaDeckClueTilesView(responseString: $responseString)
            
            MobileTriviaDeckKeyboardView(
                text: $responseString,
                isTypingResponse: $exploreVM.triviaDeckClueViewState.isTypingResponse,
                onPressEnter:  {
                    keyboardEnter()
                }, correctResponse: exploreVM.currentTriviaDeckClue.response
            )
            .opacity(clueState.hasSolvedClue || currentTriviaDeckClue.clue.isEmpty ? 0.4 : 1)
            .disabled(clueState.hasSolvedClue || currentTriviaDeckClue.clue.isEmpty)
        }
        .onDisappear {
            stopTimer()
            exploreVM.triviaDeckClueViewState.resetToDefaults()
            currentClueSecondsElapsed = 0.0
        }
    }
}

extension MobileTriviaDeckClueView {
    func getFlipConditions() -> [Bool] {
        Array(exploreVM.currentTriviaDeckClue.response).indices.map { i in
            let char = responseString.count > i ? responseString[i] : ""
            let refChar = exploreVM.currentTriviaDeckClue.response[i]
            return clueState.hasSolvedClue || (char == refChar && clueState.revealedIndices.contains(i))
        }
    }
    
    func getNumberSuffix(_ number: Int) -> String {
        let suffix: String
        
        let lastTwoDigits = number % 100
        let lastDigit = number % 10
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 13 {
            suffix = "th"
        } else {
            switch lastDigit {
            case 1:
                suffix = "st"
            case 2:
                suffix = "nd"
            case 3:
                suffix = "rd"
            default:
                suffix = "th"
            }
        }
        
        return suffix
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            currentClueSecondsElapsed += 0.1
            if currentClueSecondsElapsed >= 60 {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func keyboardEnter() {
        // If the response is correct, show the stats page.
        // If it's not, but the length of the string is correct, reveal which letters are correct.
        if responseString == exploreVM.currentTriviaDeckClue.response {
            exploreVM.triviaDeckClueViewState.hasSolvedClue = true
            stopTimer()
        } else if responseString.count == exploreVM.currentTriviaDeckClue.response.count {
            exploreVM.incrementTDSubmissions(clue: exploreVM.currentTriviaDeckClue, correctSubmission: false)
            for (charIndex, myChar) in responseString.enumerated() {
                let refChar = exploreVM.currentTriviaDeckClue.response[charIndex]
                if String(myChar) == refChar && !clueState.revealedIndices.contains(charIndex) {
                    exploreVM.triviaDeckClueViewState.revealedIndices.append(charIndex)
                } else if String(myChar) != refChar {
                    exploreVM.triviaDeckClueViewState.revealedIndices.removeAll(where: { $0 == charIndex })
                }
            }
        }
    }
}

struct MobileTriviaDeckTimerAnimatedPieChart: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var currentClueSecondsElapsed: Float
    
    @State private var percentage: Double = 0.0
    
    func stopwatchPercentage(elapsed: Double, duration: Double) -> Double {
        return min(elapsed / duration, 1)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 14, height: 14)
                .foregroundColor(Color.white.opacity(0.1))
                .overlay(Circle().stroke(formatter.color(.lowContrastWhite), lineWidth: 1))
            MobileTriviaDeckTimerPieSlice(endAngle: 360 * percentage)
                .fill(formatter.color(currentClueSecondsElapsed > 50 ? (currentClueSecondsElapsed >= 60 ? .red : .yellow) : .highContrastWhite))
                .frame(width: 14, height: 14)
                .onChange(of: currentClueSecondsElapsed, perform: { newValue in
                    percentage = stopwatchPercentage(elapsed: Double(currentClueSecondsElapsed), duration: 60)
                })
        }
    }
}

struct MobileTriviaDeckTimerPieSlice: Shape {
    var endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: endAngle - 90), clockwise: false)
        path.closeSubpath()
        
        return path
    }
    
    var animatableData: Double {
        get { endAngle }
        set { endAngle = newValue }
    }
}

struct MobileTriviaDeckClueTilesView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    @Binding var responseString: String
    
    @State var jumpStates: [Bool] = Array(repeating: false, count: 13)
    
    var clueState: TriviaDeckClueViewState {
        return exploreVM.triviaDeckClueViewState
    }
    
    var body: some View {
        ZStack {
            if exploreVM.currentTriviaDeckClue.clue.isEmpty {
                HStack(spacing: 5) {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .foregroundColor(formatter.color(.primaryFG))
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .foregroundColor(formatter.color(.primaryFG))
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .foregroundColor(formatter.color(.primaryFG))
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .foregroundColor(formatter.color(.primaryFG))
                }
                .opacity(0.4)
            } else {
                HStack(spacing: exploreVM.currentTriviaDeckClue.response.count > 10 ? 2.5 : 5) {
                    ForEach(Array(exploreVM.currentTriviaDeckClue.response).indices, id: \.self) { i in
                        let char = responseString.count > i ? responseString[i] : ""
                        let refChar = exploreVM.currentTriviaDeckClue.response[i]
                        ZStack {
                            if (clueState.hasSolvedClue || (char == refChar && clueState.revealedIndices.contains(i))) {
                                Text("\(responseString.count > i ? responseString[i] : "?")")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .foregroundColor(formatter.color(.highContrastWhite))
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color(hex: "#C77E24"), Color(hex: "#FFB033")]), startPoint: .bottomLeading, endPoint: .top)
                                    )
                                    .onAppear {
                                        let delay: Double = !clueState.hasSolvedClue ? 0.0 : 0.2 * Double(i) / Double(responseString.count)
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                                jumpStates[i] = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    jumpStates[i] = false
                                                }
                                            }
                                        }
                                    }
                            } else {
                                let refChar = exploreVM.currentTriviaDeckClue.response[i]
                                let revealedAndEmpty = clueState.revealedIndices.contains(i) && i > responseString.count - 1
                                let unsolvedChar = revealedAndEmpty ? refChar : (responseString.count > i ? responseString[i] : "")
                                Text("\(unsolvedChar)")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .foregroundColor(formatter.color(responseString.count - 1 == i ? .primaryBG : .highContrastWhite))
                                    .opacity(revealedAndEmpty ? 0.2 : 1)
                                    .background(
                                        formatter.color(responseString.count - 1 == i ? .highContrastWhite : .primaryFG)
                                    )
                            }
                        }
                        .offset(y: jumpStates[i] ? -20 : 0)
                    }
                    .font(formatter.bigCaslonFont(sizeFloat: 24))
                }
            }
        }
        .padding([.horizontal, .bottom], 10)
    }
}

struct MobileTriviaDeckClueUnsolvedView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    var clueState: TriviaDeckClueViewState {
        return exploreVM.triviaDeckClueViewState
    }
    
    var body: some View {
        Spacer(minLength: 0)
        Text("\(exploreVM.currentTriviaDeckClue.clue)")
            .font(formatter.bigCaslonFont(sizeFloat: exploreVM.currentTriviaDeckClue.clue.count > 130 ? 20 : 23))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        Spacer(minLength: 0)
        HStack {
            VStack (alignment: .leading, spacing: 2) {
                Text("Submitted by")
                    .font(formatter.font(.regular, fontSize: .small))
                    .foregroundColor(formatter.color(.lowContrastWhite))
                Text("\(exploreVM.currentTriviaDeckClue.authorUsername)")
                    .font(formatter.font(.semiBold, fontSize: .regular))
                    .underline()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
            Button {
                formatter.setAlertSettings(alertAction: {
                    // Skip here
                }, alertTitle: "Are you sure?", alertSubtitle: "If you skip this clue, you'll never be able to play it again.", hasCancel: true, actionLabel: "Skip")
            } label: {
                HStack (spacing: 2) {
                    Text("Skip")
                        .font(formatter.font(.regular, fontSize: .regular))
                    Image(systemName: "arrow.right.to.line")
                        .font(.system(size: 12))
                }
                .padding(7)
                .padding(.horizontal, 4)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct MobileTriviaDeckClueSolvedView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    @Binding var responseString: String
    @Binding var currentClueSecondsElapsed: Float
    
    var clueState: TriviaDeckClueViewState {
        return exploreVM.triviaDeckClueViewState
    }
    
    var body: some View {
        VStack (spacing: 0) {
            Spacer(minLength: 0)
            VStack (spacing: 5) {
                Text("Speed Distribution")
                    .font(formatter.font(fontSize: .small))
                HStack (alignment: .bottom, spacing: 2) {
                    let maxCount = max(exploreVM.currentTriviaDeckClue.secondsCountsBins.max() ?? 0, 1)
                    ForEach(exploreVM.currentTriviaDeckClue.secondsCountsBins.indices, id: \.self) { i in
                        let myBinIndex = Int(currentClueSecondsElapsed.rounded(.down))
                        let myAddend = (myBinIndex == i ? 1 : 0)
                        let count = exploreVM.currentTriviaDeckClue.secondsCountsBins[i] + myAddend
                        let countProportionFloat: Float = Float(count) / Float(maxCount + myAddend)
                        Rectangle()
                            .frame(minWidth: 1, maxHeight: countProportionFloat <= 1 ? CGFloat(countProportionFloat * 50) : 1)
                            .frame(minHeight: 1)
                            .background(formatter.color(.highContrastWhite))
                            .clipShape(Capsule())
                            .opacity(i == myBinIndex ? 1 : 0.4)
                    }
                }
                .frame(height: 50)
                HStack {
                    Text("1s")
                    Spacer()
                    Text("30s")
                    Spacer()
                    Text("60s")
                }
                .font(formatter.font(.regular, fontSize: .regular))
            }
            .padding(.top, 5)
            .padding(.bottom, 20)
            VStack (spacing: 5) {
                Text("Attempts Distribution")
                    .font(formatter.font(fontSize: .small))
                HStack (alignment: .bottom, spacing: 2) {
                    let maxCount = max(exploreVM.currentTriviaDeckClue.attemptsCountsBins.max() ?? 0, 1)
                    ForEach(exploreVM.currentTriviaDeckClue.attemptsCountsBins.indices, id: \.self) { i in
                        let myBinIndex = clueState.currentClueNumAttempts - 1
                        let myAddend = (myBinIndex == i ? 1 : 0)
                        let count = exploreVM.currentTriviaDeckClue.attemptsCountsBins[i] + myAddend
                        let countProportionFloat: Float = Float(count) / Float(maxCount + myAddend)
                        Rectangle()
                            .frame(minWidth: 1, maxHeight: countProportionFloat <= 1 ? CGFloat(countProportionFloat * 50) : 1)
                            .frame(minHeight: 1)
                            .background(formatter.color(.highContrastWhite))
                            .cornerRadius(2)
                            .opacity(i == myBinIndex ? 1 : 0.4)
                    }
                }
                .frame(height: 50)
                HStack {
                    Text("1")
                    Spacer()
                    Text("5")
                    Spacer()
                    Text("10")
                }
                .font(formatter.font(.regular, fontSize: .regular))
            }
            .padding(.top, 5)
            .padding(.bottom, 20)
            Spacer(minLength: 0)
            HStack {
                VStack (alignment: .leading, spacing: 2) {
                    Text("Submitted by")
                        .font(formatter.font(.regular, fontSize: .small))
                        .foregroundColor(formatter.color(.lowContrastWhite))
                    Text("\(exploreVM.currentTriviaDeckClue.authorUsername)")
                        .font(formatter.font(.semiBold, fontSize: .regular))
                        .underline()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button {
                    exploreVM.advanceNextTriviaDeckClue(secondsFloat: currentClueSecondsElapsed, numAttempts: clueState.currentClueNumAttempts)
                    exploreVM.triviaDeckClueViewState.resetToDefaults()
                    currentClueSecondsElapsed = 0.0
                    responseString.removeAll()
                } label: {
                    HStack (spacing: 2) {
                        Text("Next")
                            .font(formatter.font(.regular, fontSize: .regular))
                        Image(systemName: "arrow.right.to.line")
                            .font(.system(size: 12))
                    }
                    .padding(7)
                    .padding(.horizontal, 4)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
    }
}

struct MobileTriviaDeckNoCluesView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    var triviaDeckDisplayMode: TriviaDeckDisplayMode {
        return exploreVM.triviaDeckClueViewState.triviaDeckDisplayMode
    }
    
    var body: some View {
        VStack (spacing: 20) {
            Image(systemName: "nosign")
                .font(.system(size: 60))
            VStack (spacing: 7) {
                Text("We're all out of clues!")
                    .font(formatter.bigCaslonFont(sizeFloat: 35))
                Text("You can write some of your own if you’d like. The best submissions will appear in these trivia packs.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .font(formatter.bigCaslonFont(sizeFloat: 20))
            }
            Button {
                exploreVM.triviaDeckClueViewState.triviaDeckDisplayMode = .buildingCustomClue
            } label: {
                Text("Write a Clue")
                    .font(formatter.font(.regular, fontSize: .small))
                    .foregroundColor(formatter.color(.primaryBG))
                    .padding(10)
                    .padding(.horizontal, 5)
                    .background(formatter.color(.highContrastWhite))
                    .clipShape(Capsule())
                    .padding(.top, 7)
            }
        }
    }
}
