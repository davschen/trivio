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
    
    @Binding var category: Category
    
    @State var offsetValue: CGFloat = 0
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack (spacing: formatter.shrink(iPadSize: 20)) {
                Text("CATEGORY NAME")
                    .font(formatter.font(fontSize: .large))
                
                VStack {
                    MobileCategoryLargeView(categoryName: category.name)
                    // Category name textfield
                    MobileCategoryNameTextFieldView(categoryName: $category.name)
                    
                    Button(action: {
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                        buildVM.currentDisplay = .grid
                    }, label: {
                        Text("Done")
                            .font(formatter.font())
                            .padding()
                            .padding(.horizontal)
                            .background(formatter.color(.lowContrastWhite))
                            .clipShape(Capsule())
                    })
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .keyboardAware(heightFactor: 0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .background(formatter.color(.primaryAccent))
        .cornerRadius(20)
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

