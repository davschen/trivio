//
//  MobileTrivioLivePreviewView.swift
//  Trivio!
//
//  Created by David Chen on 10/27/22.
//

import Foundation
import SwiftUI
import StoreKit

struct MobileTrivioLivePreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var appStoreManager: AppStoreManager
    
    var hasSubscribed: Bool {
        return UserDefaults.standard.bool(forKey: "iOS.Trivio.3.0.Cherry.OTLHT")
    }
    
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
                    
                    VStack (alignment: .leading, spacing: 5) {
                        ForEach(appStoreManager.myProducts, id: \.self) { product in
                            ZStack {
                                if product.productIdentifier == "iOS.Trivio.3.0.Cherry.OTLHT" {
                                    MobileTrivioLiveCodeCardView(product: product)
                                } else {
                                    MobileTrivioLiveSubscriptionView(product: product)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .font(formatter.font())
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Live Game")
        .withBackButton()
    }
}

struct MobileTrivioLiveCodeCardView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var appStoreManager: AppStoreManager
    
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    let product: SKProduct
    
    @State var isLoading = false
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 5) {
                Text("\(gamesVM.liveGameCustomSet.hostCode)")
                    .font(formatter.fontFloat(.bold, sizeFloat: 45.0))
                Text("Enter Code at www.trivio.live into a computer’s browser to host your game")
                    .font(formatter.font(.regular, fontSize: .regular))
                    .frame(width: 200)
                    .fixedSize(horizontal: false, vertical: true)
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
                        Text("\(profileVM.myUserRecords.numLiveTokens)")
                            .font(formatter.fontFloat(.bold, sizeFloat: 24.0))
                            .foregroundColor(formatter.color(.primaryBG))
                    }
                    Text("Live games left this month")
                        .font(formatter.font(.regular, fontSize: .medium))
                }
                Button {
                    isLoading = true
                    appStoreManager.purchaseProduct(product: product)
                } label: {
                    ZStack {
                        if isLoading {
                            LoadingView()
                                .padding(.vertical, 19.5)
                        } else {
                            Text("Buy one more for $\(product.price)")
                                .padding(.vertical, 15)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(5)
                }
                Text("""
                     Note: game tokens will not be spent until you enter the code in a desktop browser
                     """)
                .font(formatter.font(.regularItalic, fontSize: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2.0)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(formatter.color(.primaryFG))
        }
        .cornerRadius(10)
        .onChange(of: appStoreManager.transactionState) { newState in
            if appStoreManager.currentTransactionProductID != product.productIdentifier {
                return
            }
            if newState == .failed {
                isLoading = false
            } else if newState == .purchased {
                profileVM.incrementNumTokens()
                isLoading = false
            }
        }
    }
}

struct MobileTrivioLiveSubscriptionView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var appStoreManager: AppStoreManager
    
    @State var isLoading = false
    
    let product: SKProduct
    
    var body: some View {
        VStack (spacing: 10) {
            VStack (spacing: 10) {
                Text("Trivio! Pro")
                HStack (alignment: .top) {
                    Text("$1")
                        .font(formatter.fontFloat(.bold, sizeFloat: 24.0))
                    Text("/month")
                        .font(formatter.font(.regular, fontSize: .regular))
                        .offset(y: 2)
                }
                Text("$\(product.price) billed annually")
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
                if UserDefaults.standard.bool(forKey: product.productIdentifier) {
                    return
                }
                appStoreManager.purchaseProduct(product: product)
            } label: {
                ZStack {
                    if isLoading {
                        LoadingView()
                    } else {
                        Text(UserDefaults.standard.bool(forKey: product.productIdentifier) ? "Subscribed!" : "Buy Now")
                    }
                }
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(formatter.color(UserDefaults.standard.bool(forKey: product.productIdentifier) ? .secondaryAccent : .primaryAccent))
                .cornerRadius(5)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 10).stroke(formatter.color(.highContrastWhite), lineWidth: 1))
        .padding(1)
        .onChange(of: appStoreManager.transactionState) { newState in
            isLoading = false
        }
    }
}
