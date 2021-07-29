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
            VStack (spacing: 30) {
                Text("SAVE DRAFT")
                    .font(formatter.font(fontSize: .large))
                VStack (spacing: 15) {
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
                    .padding(20)
                    .background(formatter.color(.lowContrastWhite))
                    .cornerRadius(10)
                    
                    Button(action: {
                        if !buildVM.setName.isEmpty {
                            buildVM.currentDisplay = .grid
                            buildVM.saveDraft()
                        }
                    }, label: {
                        HStack {
                            Text("Save")
                                .font(formatter.font())
                            if buildVM.processPending {
                                ProgressView()
                                    .padding(.leading, 5)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.lowContrastWhite))
                        .clipShape(Capsule())
                        .opacity(buildVM.setName.isEmpty ? 0.5 : 1)
                    })
                    Button {
                        buildVM.currentDisplay = .grid
                    } label: {
                        Text("Cancel")
                            .font(formatter.font())
                    }
                    .keyboardAware()
                }
            }
            .frame(width: 400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(formatter.color(.primaryAccent))
        .cornerRadius(30)
    }
}

