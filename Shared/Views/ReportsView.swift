//
//  ReportsView.swift
//  Trivio
//
//  Created by David Chen on 3/7/21.
//

import Foundation
import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .long
        return df
    }
    
    var timeFormatter: DateFormatter {
        let df = DateFormatter()
        df.timeStyle = .short
        return df
    }
    
    var body: some View {
        ZStack {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
            HStack {
                VStack (alignment: .leading, spacing: 5) {
                    VStack (alignment: .leading, spacing: 0) {
                        Text("All Games")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 40))
                            .foregroundColor(Color("MainAccent"))
                        Text("Hold to delete")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 12))
                            .foregroundColor(Color("MainAccent"))
                    }
                    if reportVM.allGames.count == 0 {
                        VStack {
                            Text("You haven't played any games yet. Once you do, they will show up here with detailed in-game reports")
                                .font(formatter.customFont(weight: "Italic", iPadSize: 20))
                            Button(action: {
                                gamesVM.menuChoice = .explore
                            }, label: {
                                Text("Explore")
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .foregroundColor(Color("Darkened"))
                                    .cornerRadius(5)
                                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            })
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                    } else {
                        ScrollView (.vertical, showsIndicators: false) {
                            ForEach(reportVM.allGames, id: \.self) { game in
                                let gameID = game.id ?? "NID"
                                VStack (alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("\(dateFormatter.string(from: game.date))")
                                            .font(formatter.customFont(weight: "Bold", iPadSize: 25))
                                        Spacer()
                                    }
                                    HStack {
                                        ScrollView (.horizontal, showsIndicators: false) {
                                            HStack {
                                                Text("\(timeFormatter.string(from: game.date))")
                                                    .font(formatter.customFont(weight: "Bold", iPadSize: 10))
                                                    .padding(3)
                                                    .background(Color.gray.opacity(0.3))
                                                    .cornerRadius(5)
                                                ForEach(game.getNames(), id: \.self) { name in
                                                    Text(name.uppercased())
                                                        .font(formatter.customFont(weight: "Bold", iPadSize: 10))
                                                        .foregroundColor(Color("MainAccent"))
                                                }
                                            }
                                        }
                                    }
                                }
                                .contentShape(Rectangle())
                                .padding(.horizontal, 15).padding(.vertical, 10)
                                .background(Color.gray.opacity(self.reportVM.selectedGameID == game.id! ? 0.3 : 0))
                                .cornerRadius(5)
                                .onTapGesture {
                                    if gameSelected(id: gameID) {
                                        self.reportVM.selectedGameID = ""
                                    } else {
                                        self.reportVM.getGameInfo(id: gameID)
                                        self.reportVM.selectedGameID = gameID
                                    }
                                }
                                .onLongPressGesture {
                                    self.reportVM.delete(id: gameID)
                                }
                            }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.2)
                Rectangle()
                    .frame(width: 1)
                    .padding()
                VStack {
                    HStack {
                        if !self.reportVM.selectedGameID.isEmpty {
                            AnalysisView()
                            Spacer()
                        }
                    }
                    
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    func gameSelected(id: String) -> Bool {
        return self.reportVM.selectedGameID == id
    }
}

struct AnalysisView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    
    @State var expanded = false
    
    var body: some View {
        ZStack {
            if let game = reportVM.currentReport {
                ScrollView (.vertical) {
                    VStack (alignment: .leading, spacing: 5) {
                        if !expanded {
                            AnalysisInfoView(game: game)
                        }
                        Text("Game Dynamics")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                        // grid magic
                        HStack (spacing: 0) {
                            // y axis
                            VStack (alignment: .trailing) {
                                ForEach(self.reportVM.yAxis.reversed(), id: \.self) { yVal in
                                    Text("\(yVal)")
                                        .font(formatter.customFont(weight: "Bold", iPadSize: formatter.shrink(iPadSize: 10)))
                                        .frame(maxHeight: .infinity, alignment: .leading)
                                        .minimumScaleFactor(0.1)
                                }
                                .frame(maxWidth: 30)
                                .frame(maxHeight: .infinity)
                            }
                            .padding(.bottom, 10)
                            .padding(.trailing, 5)
                            VStack (spacing: 0) {
                                ChartView(expanded: $expanded, min: reportVM.min, max: reportVM.max)
                                // x axis
                                HStack {
                                    ForEach(self.reportVM.xAxis, id: \.self) { xVal in
                                        Text("\(xVal)")
                                            .font(formatter.customFont(weight: "Bold", iPadSize: formatter.shrink(iPadSize: 10)))
                                            .frame(maxWidth: .infinity)
                                            .minimumScaleFactor(0.1)
                                    }
                                }
                                .frame(height: 15)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 5)
                            }
                        }
                        .frame(height: UIScreen.main.bounds.height * (expanded ? 0.65 : 0.45))
                        
                        if !expanded {
                            // adding other info
                            ScrollView (.horizontal, showsIndicators: false) {
                                HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                                    Text("Solved: \(game.qs_solved)")
                                        .padding(10)
                                        .background(Color.white.opacity(0.4))
                                        .cornerRadius(formatter.cornerRadius(5))
                                    if let set = reportVM.currentSet {
                                        Text("# of clues in set: \(set.numclues)")
                                            .padding(10)
                                            .background(Color.white.opacity(0.4))
                                            .cornerRadius(formatter.cornerRadius(5))
                                    }
                                    Text("Your Average Score: \(reportVM.getAverageScores().formatPoints())")
                                        .padding(10)
                                        .background(Color.white.opacity(0.4))
                                        .cornerRadius(formatter.cornerRadius(5))
                                    
                                }
                                .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                                .lineLimit(1)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct ChartView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var reportVM: ReportViewModel
    @State var on = true
    @Binding var expanded: Bool
    
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
                    ForEach(currentGame.team_ids, id: \.self) { id in
                        if let scores = reportVM.scores[id] {
                            LineGraph(dataPoints: scores.map { CGFloat($0) }, min: min, max: max)
                                .stroke(style: StrokeStyle(lineCap: .round, lineJoin: .round))
                                .stroke(ColorMap().getColor(color: currentGame.color_id_map[id]!), lineWidth: 2)
                                .opacity((reportVM.selectedID == id || reportVM.selectedID.isEmpty) ? 1 : 0.25)
                                .border(Color.gray, width: 1)
                        }
                    }
                    HStack {
                        Button (action: {
                            expanded.toggle()
                        }) {
                            ZStack {
                                Color.white
                                    .opacity(expanded ? 0.4 : 0.2)
                                    .frame(width: formatter.shrink(iPadSize: 40, factor: 1.5), height: formatter.shrink(iPadSize: 40, factor: 1.5))
                                Image(systemName: expanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                                    .font(.system(size: 10))
                            }
                            .clipShape(Circle())
                            .padding(formatter.padding(size: 10))
                        }
                    }
                }
            }
        }
    }
}

struct AnalysisInfoView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    
    var game: Report
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text("Game Analysis")
                .font(formatter.customFont(weight: "Bold", iPadSize: 50))
            // "game played" label with set title
            if let currentSet = reportVM.currentSet {
                VStack (alignment: .leading, spacing: 0) {
                    VStack (alignment: .leading, spacing: 0) {
                        Text("GAME PLAYED")
                            .tracking(2)
                            .font(formatter.customFont(iPadSize: 15))
                        ScrollView (.horizontal, showsIndicators: false) {
                            HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                                Text(currentSet.title)
                                    .padding(10)
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(formatter.cornerRadius(5))
                                Text("Average Score: \(currentSet.averageScore.formatPoints())")
                                    .padding(10)
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(formatter.cornerRadius(5))
                                Button {
                                    gamesVM.getCustomData(setID: currentSet.id ?? "NID")
                                    gamesVM.setEpisode(ep: currentSet.id ?? "NID")
                                    gamesVM.menuChoice = .game
                                } label: {
                                    HStack {
                                        Image(systemName: "gamecontroller")
                                        Text("Play")
                                    }
                                    .padding(10)
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(formatter.cornerRadius(5))
                                }
                            }
                            .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                        }
                    }
                }
            }
            // contestants/teams that played
            VStack (alignment: .leading, spacing: 0) {
                Text("PLAYERS (TAP TO HIGHLIGHT)")
                    .tracking(2)
                    .font(formatter.customFont(iPadSize: 15))
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                        ForEach(game.team_ids, id: \.self) { id in
                            if let name = game.name_id_map[id], let color = game.color_id_map[id], let score = reportVM.scores[id]?.last {
                                VStack (spacing: 0) {
                                    HStack {
                                        Circle()
                                            .foregroundColor(ColorMap().getColor(color: color))
                                            .frame(width: 10)
                                        Text(name)
                                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                            .foregroundColor(self.reportVM.selectedID == id ? .white : Color("MainAccent"))
                                    }
                                    Text("Score: " + "\(score)")
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                                        .foregroundColor(self.reportVM.selectedID == id ? .white : Color("MainAccent"))
                                }
                                .padding()
                                .frame(height: formatter.shrink(iPadSize: 70, factor: 1.5))
                                .background(Color.gray.opacity(self.reportVM.selectedID == id ? 1 : 0.4))
                                .cornerRadius(formatter.cornerRadius(5))
                                .onTapGesture {
                                    self.reportVM.selectedID = (self.reportVM.selectedID == id) ? "" : id
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LineGraph: Shape {
    var dataPoints: [CGFloat]
    var min: CGFloat
    var max: CGFloat
    var newMax: CGFloat {
        return max - min
    }
    var newMin: CGFloat {
        return min - min
    }
    
    func path(in rect: CGRect) -> Path {
        func point(at ix: Int) -> CGPoint {
            let point = dataPoints[ix] - min
            let x = rect.width * CGFloat(ix) / CGFloat(dataPoints.count - 1)
            let y = ((newMax-point) / (newMax - newMin)) * rect.height
            return CGPoint(x: x, y: y)
        }

        return Path { p in
            guard dataPoints.count > 1 else { return }
            let start = dataPoints[0] - min
            p.move(to: CGPoint(x: 0, y: ((newMax-start) / (newMax - newMin)) * rect.height))
            for idx in dataPoints.indices {
                p.addLine(to: point(at: idx))
            }
        }
    }
}
