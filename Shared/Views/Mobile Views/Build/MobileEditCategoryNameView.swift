//
//  MobileEditCategoryNameView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileEditCategoryNameView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var category: CustomSetCategory
    
    @State var offsetValue: CGFloat = 0
    @State var categoryName = ""
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack (spacing: 20) {
                    VStack {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(formatter.iconFont(.small))
                            Text("Category \(category.index + 1)")
                            Image(systemName: "chevron.right")
                                .font(formatter.iconFont(.small))
                            Spacer()
                        }
                        // Category name textfield
                        TextField("Untitled", text: $categoryName)
                            .font(formatter.font(fontSize: .mediumLarge))
                            .padding(20)
                            .background(formatter.color(.primaryFG))
                            .cornerRadius(5)
                    }
                }
            }
            .padding()
            .background(formatter.color(.primaryFG))
            .cornerRadius(10)
            
            Button(action: {
                formatter.hapticFeedback(style: .soft, intensity: .strong)
                buildVM.currentDisplay = .grid
            }, label: {
                Text("Done")
                    .font(formatter.font())
                    .foregroundColor(formatter.color(.primaryBG))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(formatter.color(.highContrastWhite))
                    .clipShape(Capsule())
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .onAppear {
            categoryName = category.name
        }
    }
}

struct MobileCategoryNameTextFieldView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var categoryName: String
    
    var body: some View {
        // Category name textfield
        HStack {
            TextField("ADD A CATEGORY NAME", text: $categoryName, onCommit: {
                buildVM.currentDisplay = .grid
            })
            .accentColor(formatter.color(.secondaryAccent))
            .font(formatter.font(categoryName.isEmpty ? .boldItalic : .bold, fontSize: .mediumLarge))
            
            if categoryName.count > 0 {
                Image(systemName: "xmark.circle.fill")
                    .font(formatter.iconFont(.small))
                    .onTapGesture {
                        categoryName.removeAll()
                    }
            }
        }
        .padding()
        .background(formatter.color(.lowContrastWhite))
        .cornerRadius(5)
    }
}

