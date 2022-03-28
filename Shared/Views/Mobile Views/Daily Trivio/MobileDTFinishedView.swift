//
//  MobileDTFinishedView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 3/23/22.
//

import Foundation
import SwiftUI
import CoreMedia

struct MobileDTFinishedView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Text(dtVM.todaysGame?.correct ?? true ? "CORRECT" : "INCORRECT")
                Spacer()
                Text("Score: \(dtVM.todaysGame?.score ?? 0)")
            }
            .font(formatter.font(.boldItalic, fontSize: .small))
            .padding()
            .background(formatter.color(dtVM.todaysGame?.correct ?? true ? .green : .red))
            GeometryReader() { geometry in
                ScrollView (.vertical, showsIndicators: false) {
                    // Individual statitsics
                    VStack (spacing: 30) {
                        MobileDTClueResponseView()
                        MobileMyStatsView()
                        MobileDTGlobalStatsView()
                        MobileDTLeaderboardView(geometry: geometry)
                    }
                    .padding(.vertical, 40)
                }
            }
        }
        .background(formatter.color(.primaryFG))
        .cornerRadius(10)
        .padding(.horizontal, 10)
        .padding(.bottom, 30)
    }
}

struct MobileDTClueResponseView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var body: some View {
        VStack (spacing: 10) {
            Text("TODAY'S DAILY TRIVIO!")
                .font(formatter.font(.bold, fontSize: .small))
                .kerning(1)
            Text(dtVM.dtSetStringDict[.clue] ?? "")
                .font(formatter.font(.regular, fontSize: .small))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Text(dtVM.dtSetStringDict[.correctResponse]?.uppercased() ?? "")
                .font(formatter.font(.bold, fontSize: .small))
                .foregroundColor(formatter.color(.secondaryAccent))
                .kerning(1)
        }
        .padding(.horizontal)
    }
}

struct MobileMyStatsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    let myStats: [DailyTrivioGameStringValue] = [.plays, .winPercent, .streak]
    
    var body: some View {
        VStack (spacing: 10) {
            Text("MY STATS")
                .font(formatter.font(.bold, fontSize: .medium))
                .kerning(0.5)
            HStack {
                ForEach(0..<myStats.count) { i in
                    let key = myStats[i]
                    let labelHeader = dtVM.myDTStatsDict[key] ?? "-"
                    
                    switch key {
                    case .plays: MobileSingleStatView(labelHeader: labelHeader, textLabel: "Plays", iconName: "")
                    case .winPercent: MobileSingleStatView(labelHeader: labelHeader, textLabel: "Win %", iconName: "")
                    default: MobileSingleStatView(labelHeader: labelHeader, textLabel: "Streak", iconName: "bolt.fill")
                    }
                }
            }
        }
    }
}

struct MobileDTGlobalStatsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var body: some View {
        VStack (spacing: 10) {
            Text("GLOBAL STATS")
                .font(formatter.font(.bold, fontSize: .medium))
                .kerning(0.5)
            MobileDTAttemptsView()
            MobileDTTimesView()
        }
    }
}

struct MobileSingleStatView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    let labelHeader: String
    let textLabel: String
    let iconName: String
    
    var body: some View {
        VStack (spacing: 2) {
            Text(labelHeader)
                .font(formatter.font(.bold, fontSize: .large))
            HStack (spacing: 2) {
                if !textLabel.isEmpty {
                    Text(textLabel)
                        .font(formatter.font(.bold, fontSize: .small))
                }
                if !iconName.isEmpty {
                    Image(systemName: iconName)
                        .font(formatter.iconFont(.micro))
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 7)
            .background(formatter.color(.primaryAccent))
            .clipShape(Capsule())
        }
    }
}

struct MobileDTAttemptsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var percents: [Int] {
        return dtVM.getAttemptBarChartHeights().0
    }
    
    var heights: [CGFloat] {
        return dtVM.getAttemptBarChartHeights().1
    }
    
    var body: some View {
        VStack (spacing: 5) {
            HStack (spacing: 3) {
                Text("Attempts made")
                    .font(formatter.font(.bold, fontSize: .small))
                Text("(Average: \(String(dtVM.getAverageAttempts())))")
                    .font(formatter.font(.regularItalic, fontSize: .small))
                Spacer()
            }
            HStack (alignment: .bottom, spacing: 2) {
                ForEach(0..<10) { i in
                    let num = i + 1
                    VStack (spacing: 2) {
                        Spacer(minLength: 0)
                        Text(String(percents[i]) + "%")
                            .opacity(heights[i] > 0 ? 1 : 0)
                        ZStack {
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: heights[i])
                                .foregroundColor(formatter.color(.primaryAccent))
                        }
                        .cornerRadius(1)
                        Text(String(num))
                    }
                    .font(formatter.font(.bold, fontSize: .micro))
                }
            }
            .padding(5)
            .padding(.top, 10)
            .background(formatter.color(.primaryBG).opacity(0.4))
            .cornerRadius(3)
        }
        .padding(.horizontal)
    }
}

// Copy of attempts view, slight modifications to labels
struct MobileDTTimesView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    var percents: [Int] {
        return dtVM.getTimesBarChartHeights().0
    }
    
    var heights: [CGFloat] {
        return dtVM.getTimesBarChartHeights().1
    }
    
    var body: some View {
        VStack (spacing: 5) {
            HStack (spacing: 3) {
                Text("Seconds spent")
                    .font(formatter.font(.bold, fontSize: .small))
                Text("(Average: \(String(dtVM.getAverageSeconds())))")
                    .font(formatter.font(.regularItalic, fontSize: .small))
                Spacer()
            }
            HStack (alignment: .bottom, spacing: 2) {
                ForEach(0..<10) { i in
                    let num = (10 - i) * Int(dtVM.timeAllowed / 10)
                    VStack (spacing: 2) {
                        Text(String(percents[i]) + "%")
                            .opacity(heights[i] > 0 ? 1 : 0)
                        ZStack {
                            Rectangle()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .frame(height: heights[i])
                                .foregroundColor(formatter.color(.secondaryAccent))
                        }
                        .cornerRadius(1)
                        Text(String(num) + "s")
                    }
                    .font(formatter.font(.bold, fontSize: .micro))
                }
            }
            .padding(5)
            .padding(.top, 10)
            .background(formatter.color(.primaryBG).opacity(0.4))
            .cornerRadius(3)
        }
        .padding(.horizontal)
    }
}

struct MobileDTLeaderboardView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var dtVM: DailyTrivioViewModel
    
    let geometry: GeometryProxy
    
    var body: some View {
        VStack (spacing: 10) {
            Text("LEADERBOARD")
                .font(formatter.font(.bold, fontSize: .small))
                .kerning(1)
            VStack {
                HStack (spacing: 0) {
                    Spacer()
                        .frame(width: 26)
                    Text("USERNAME")
                        .font(formatter.font(.bold, fontSize: .micro))
                        .kerning(0.5)
                        .frame(width: geometry.size.width * 0.3, alignment: .leading)
                    Spacer()
                    Text("TIME")
                        .font(formatter.font(.bold, fontSize: .micro))
                        .kerning(0.5)
                        .frame(width: geometry.size.width * 0.1, alignment: .leading)
                    Text("ATTEMPTS")
                        .font(formatter.font(.bold, fontSize: .micro))
                        .kerning(0.5)
                        .frame(width: geometry.size.width * 0.2, alignment: .trailing)
                    Text("SCORE")
                        .font(formatter.font(.bold, fontSize: .micro))
                        .kerning(0.5)
                        .frame(width: geometry.size.width * 0.2, alignment: .trailing)
                }
                Rectangle()
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(formatter.color(.lowContrastWhite))
                    .padding(.bottom, 10)
                VStack (spacing: 15) {
                    ForEach(0..<dtVM.allGamesToday.count, id: \.self) { i in
                        let dtGame = dtVM.allGamesToday[i]
                        let myUID = dtVM.myUID ?? ""
                        VStack (spacing: 10) {
                            HStack (spacing: 0) {
                                Text(String(i + 1))
                                    .font(formatter.font(.bold, fontSize: .small))
                                    .frame(width: 26, alignment: .center)
                                Text(dtGame.username)
                                    .frame(width: geometry.size.width * 0.3, alignment: .leading)
                                Spacer()
                                Text("\(dtGame.time)s")
                                    .frame(width: geometry.size.width * 0.1, alignment: .leading)
                                Text("\(dtGame.attempts.count)x")
                                    .frame(width: geometry.size.width * 0.2, alignment: .trailing)
                                Text("\(dtGame.score)")
                                    .frame(width: geometry.size.width * 0.2, alignment: .trailing)
                            }
                            .font(formatter.font(dtGame.userID == myUID ? .bold : .regular, fontSize: .small))
                            
                            Rectangle()
                                .frame(height: 1)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(formatter.color(.lowContrastWhite))
                                .padding(.top, 5)
                        }
                        .foregroundColor(formatter.color(dtGame.userID == myUID ? .secondaryAccent : .highContrastWhite))
                    }
                }
                Text("New Daily Trivio every midnight!")
                    .font(formatter.font(.regularItalic, fontSize: .small))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal)
    }
}
