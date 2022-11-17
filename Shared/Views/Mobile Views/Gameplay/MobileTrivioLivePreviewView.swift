//
//  MobileTrivioLivePreviewView.swift
//  Trivio!
//
//  Created by David Chen on 10/27/22.
//

import Foundation
import SwiftUI

struct MobileTrivioLivePreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    init() {
        Theme.navigationBarColors(
            background: UIColor(MasterHandler().color(.primaryFG)),
            titleColor: UIColor(MasterHandler().color(.highContrastWhite))
        )
    }
    
    var body: some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView (.vertical, showsIndicators: false) {
                VStack (alignment: .leading, spacing: 15) {
                    MobileGameSettingsHeaderView()
                        .padding(.top)
                    
                    MobileTrivioLiveCodeCardView()
                    
                    MobileTrivioLiveSubscriptionView()
                }
            }
            .padding(.horizontal)
            .font(formatter.font())
        }
        .navigationTitle("Live Game")
        .withBackButton()
        .animation(.easeInOut)
    }
}

struct MobileTrivioLiveCodeCardView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 5) {
                Text("894156")
                    .font(formatter.fontFloat(.bold, sizeFloat: 45.0))
                Text("Enter Code at www.trivio.live into a computer’s browser to host your game")
                    .font(formatter.font(.regular, fontSize: .regular))
                    .frame(width: 200)
                    .multilineTextAlignment(.center)
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 25)
            .background(formatter.color(.secondaryFG))
            
            VStack (spacing: 15) {
                VStack {
                    ZStack {
                        Circle()
                            .fill(formatter.color(.secondaryAccent))
                            .frame(width: 90, height: 90)
                            .opacity(0.4)
                        Circle()
                            .fill(formatter.color(.secondaryAccent))
                            .frame(width: 65, height: 65)
                        Text("1")
                            .font(formatter.fontFloat(.bold, sizeFloat: 24.0))
                            .foregroundColor(formatter.color(.primaryBG))
                    }
                    Text("Live games left this month")
                        .font(formatter.font(.regular, fontSize: .medium))
                }
                Button {
                    print("Purchased one more!")
                } label: {
                    Text("Buy one more for $0.99")
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.primaryAccent))
                        .cornerRadius(5)
                }
                Text("""
                     Note: game tokens will not be spent until you enter the code in a desktop browser
                     """)
                .font(formatter.font(.regularItalic, fontSize: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(2.0)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(formatter.color(.primaryFG))
        }
        .cornerRadius(10)
    }
}

struct MobileTrivioLiveSubscriptionView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack (spacing: 10) {
            VStack (spacing: 10) {
                Text("Trivio! Pro")
                HStack (alignment: .top) {
                    Text("$0.99")
                        .font(formatter.fontFloat(.bold, sizeFloat: 24.0))
                    Text("/month")
                        .font(formatter.font(.regular, fontSize: .regular))
                }
                Text("$11.88 billed annually")
                    .font(formatter.font(.regular, fontSize: .regular))
                    .foregroundColor(formatter.color(.lowContrastWhite))
            }
            
            Text("""
                 Unlimited live games, unlimited participants. Perfect for teachers, managers, or anyone who wants to host multiple live games in a month. 1/3 the price of other comparable offerings.
                 """)
            .font(formatter.font(.regular, fontSize: .regular))
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineSpacing(2.0)
            
            Button {
                print("Subscribed!")
            } label: {
                Text("Buy now")
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(5)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 10).stroke(formatter.color(.highContrastWhite), lineWidth: 1))
        .padding(1)
    }
}
