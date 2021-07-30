//
//  MobileSaveDraftView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileSaveDraftView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    var body: some View {
        ZStack {
            VStack (spacing: 15) {
                Text("SAVE DRAFT")
                    .font(formatter.font(fontSize: .large))
                VStack (spacing: 10) {
                    HStack {
                        TextField("TITLE YOUR SET", text: $buildVM.setName, onCommit: {
                            buildVM.currentDisplay = .grid
                        })
                        .accentColor(formatter.color(.secondaryAccent))
                        .font(formatter.font(fontSize: .large))
                        
                        if !buildVM.setName.isEmpty {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .onTapGesture {
                                    buildVM.setName.removeAll()
                                }
                        }
                    }
                    .padding()
                    .background(formatter.color(.lowContrastWhite))
                    .cornerRadius(5)
                    
                    Button(action: {
                        if !buildVM.setName.isEmpty {
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
                            buildVM.currentDisplay = .grid
                            buildVM.saveDraft()
                        }
                    }, label: {
                        HStack {
                            Text("Save")
                                .font(formatter.font())
                            if buildVM.processPending {
                                LoadingView()
                                    .padding(.leading, 5)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.lowContrastWhite))
                        .clipShape(Capsule())
                        .opacity(buildVM.setName.isEmpty ? 0.5 : 1)
                    })
                    Button {
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                        buildVM.currentDisplay = .grid
                    } label: {
                        Text("Cancel")
                            .font(formatter.font())
                    }
                    .keyboardAware(heightFactor: 0.6)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(formatter.color(.primaryAccent))
        .cornerRadius(20)
    }
}

