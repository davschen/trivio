//
//  EditCategoryNameView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct EditCategoryNameView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var category: Category
    
    @State var offsetValue: CGFloat = 0
    
    var body: some View {
        VStack (spacing: formatter.shrink(iPadSize: 20)) {
            Text("CATEGORY NAME")
                .font(formatter.font(fontSize: .extraLarge))
            
            VStack {
                CategoryLargeView(categoryName: category.name, width: 450)
                // Category name textfield
                CategoryNameTextFieldView(categoryName: $category.name)
                
                Button(action: {
                    buildVM.currentDisplay = .grid
                }, label: {
                    Text("Done")
                        .font(formatter.font())
                        .padding(20)
                        .padding(.horizontal, 20)
                        .background(formatter.color(.lowContrastWhite))
                        .clipShape(Capsule())
                })
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(width: 450)
            .keyboardAware()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(30)
        .background(formatter.color(.primaryAccent))
        .cornerRadius(30)
    }
}

struct CategoryNameTextFieldView: View {
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
            .font(formatter.font(categoryName.isEmpty ? .boldItalic : .bold, fontSize: .semiLarge))
             
            if categoryName.count > 0 {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .onTapGesture {
                        categoryName.removeAll()
                    }
            }
        }
        .padding(20)
        .background(formatter.color(.lowContrastWhite))
        .cornerRadius(10)
    }
}
