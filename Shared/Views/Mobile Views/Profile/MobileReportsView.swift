//
//  MobileReportsView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileReportsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading, spacing: 10) {
                if reportVM.allGameReports.count == 0 {
                    MobileEmptyListView(label: "You haven't played any games yet. Once you do, they will show up here with detailed in-game reports")
                        .padding()
                } else {
                    ScrollView (.horizontal, showsIndicators: false) {
                        HStack {
                            Spacer()
                                .frame(width: 0)
                            ForEach(reportVM.allGameReports, id: \.self) { pastGameReport in
                                MobileReportPreviewView(pastGameReport: pastGameReport)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                    if !self.reportVM.selectedGameID.isEmpty {
                        MobileAnalysisView()
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct MobileReportPreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    let pastGameReport: Report
    
    var body: some View {
        let gameID = pastGameReport.id ?? "NID"
        VStack (alignment: .leading, spacing: 15) {
            HStack (spacing: 15) {
                Text("\(reportVM.dateFormatter.string(from: pastGameReport.date))")
                    .font(formatter.font(.bold))
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 15)
                Text("\(reportVM.timeFormatter.string(from: pastGameReport.date))")
                    .font(formatter.font(.regular))
            }
            .foregroundColor(formatter.color(.highContrastWhite))
            ScrollView (.horizontal) {
                HStack (spacing: 15) {
                    ForEach(pastGameReport.getNames(), id: \.self) { name in
                        Text(name.uppercased())
                            .font(formatter.font())
                            .foregroundColor(formatter.color(.secondaryAccent))
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .padding()
        .background(formatter.color(reportVM.selectedGameID == gameID ? .secondaryFG : .primaryFG))
        .cornerRadius(10)
        .padding(.top)
        .onTapGesture {
            formatter.hapticFeedback(style: .medium)
            if reportVM.selectedGameID != gameID {
                self.reportVM.getGameInfo(id: gameID)
            }
        }
        .onLongPressGesture {
            self.reportVM.delete(id: gameID)
        }
    }
}

struct MobileAnalysisView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    
    var body: some View {
        if let game = reportVM.currentReport {
            ScrollView (.vertical, showsIndicators: false) {
                VStack (alignment: .leading, spacing: 15) {
                    // Includes "Game Dynamics" text, play button, and contestants scrollview
                    MobileAnalysisInfoView(game: game)
                    // chart magic
                    HStack (spacing: 0) {
                        // y axis
                        VStack (alignment: .trailing) {
                            ForEach(self.reportVM.yAxis.reversed(), id: \.self) { yVal in
                                Text("\(yVal)")
                                    .font(formatter.font(fontSize: .micro))
                                    .frame(maxHeight: .infinity, alignment: .leading)
                                    .minimumScaleFactor(0.1)
                            }
                            .frame(maxHeight: .infinity)
                        }
                        .frame(width: 40)
                        .padding(.bottom, 10)
                        .padding(.trailing, 5)
                        VStack (spacing: 0) {
                            MobileChartView(min: reportVM.min, max: reportVM.max)
                            // x axis
                            HStack {
                                ForEach(self.reportVM.xAxis, id: \.self) { xVal in
                                    Text("\(xVal)")
                                        .font(formatter.font(fontSize: .micro))
                                        .frame(maxWidth: .infinity)
                                        .minimumScaleFactor(0.1)
                                }
                            }
                            .frame(height: 15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.4)
                    
                    // "game played" label with set title
                    Button(action: {
                        formatter.hapticFeedback(style: .light)
                        gamesVM.menuChoice = .game
                        if game.episode_played.contains("game_id") {
                            gamesVM.getEpisodeData(gameID: game.episode_played)
                        } else {
                            gamesVM.getCustomData(setID: game.episode_played)
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 15))
                            Text("\(reportVM.getGameName(from: game.episode_played))")
                                .font(formatter.font())
                        }
                        .foregroundColor(formatter.color(.primaryFG))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.highContrastWhite))
                        .cornerRadius(5)
                    })
                    
                    HStack {
                        if let set = reportVM.currentSet {
                            Text("Clues in Set: \(set.numclues)")
                                .padding(10)
                                .padding(.horizontal, 30)
                                .background(formatter.color(.secondaryFG))
                                .cornerRadius(5)
                        }
                        Spacer()
                    }
                    .font(formatter.font())
                }
                .padding()
            }
            .background(formatter.color(.primaryFG))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

struct MobileAnalysisInfoView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    
    var game: Report
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            Text("Game Dynamics")
                .font(formatter.font(fontSize: .large))
                .foregroundColor(formatter.color(.highContrastWhite))
            
            // contestants/teams that played
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(game.team_ids, id: \.self) { id in
                        if let name = game.name_id_map[id], let color = game.color_id_map[id], let score = reportVM.scores[id]?.last {
                            VStack (alignment: .leading, spacing: 5) {
                                HStack {
                                    Circle()
                                        .foregroundColor(ColorMap().getColor(color: color))
                                        .frame(width: 15)
                                    Text(name)
                                        .font(formatter.font(fontSize: .mediumLarge))
                                        .foregroundColor(formatter.color(.highContrastWhite))
                                }
                                Text("$\(score)")
                                    .font(formatter.font(fontSize: .mediumLarge))
                                    .foregroundColor(formatter.color(.highContrastWhite))
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(formatter.color(.primaryFG))
                                    .cornerRadius(5)
                            }
                            .padding()
                            .frame(width: 150)
                            .background(RoundedRectangle(cornerRadius: 5).stroke(formatter.color(.highContrastWhite), lineWidth: reportVM.selectedID == id ? 5 : 0))
                            .background(formatter.color(.secondaryFG))
                            .cornerRadius(5)
                            .onTapGesture {
                                formatter.hapticFeedback(style: .medium)
                                reportVM.selectedID = (reportVM.selectedID == id) ? "" : id
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MobileChartView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var reportVM: ReportViewModel
    @State var on = true
    
    var min: CGFloat
    var max: CGFloat
    var newMax: CGFloat {
        return max - min
    }
    var newMin: CGFloat {
        return min - min
    }
    
    var body: some View {
        VStack {
            ZStack (alignment: .topLeading) {
                if let currentGame = reportVM.currentReport {
                    formatter.color(.secondaryFG)
                    ForEach(currentGame.team_ids, id: \.self) { id in
                        if let scores = reportVM.scores[id] {
                            LineGraph(dataPoints: scores.map { CGFloat($0) }, min: min, max: max)
                                .stroke(style: StrokeStyle(lineCap: .round, lineJoin: .round))
                                .stroke(ColorMap().getColor(color: currentGame.color_id_map[id]!), lineWidth: 2)
                                .opacity((reportVM.selectedID == id || reportVM.selectedID.isEmpty) ? 1 : 0.25)
                        }
                    }
                }
            }
            .cornerRadius(5)
        }
    }
}

