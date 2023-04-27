//
//  MobileTriviaDeckKeyboardView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/22/23.
//

import Foundation
import SwiftUI

struct MobileTriviaDeckKeyboardView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var text: String
    @Binding var isTypingResponse: Bool

    var onPressEnter: () -> () = ({})
    var correctResponse: String = ""
    
    private let keyboardLayout = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["Enter", "Z", "X", "C", "V", "B", "N", "M", "Delete"]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(keyboardLayout.indices, id: \.self) { rowIndex in
                HStack(spacing: 5) {
                    ForEach(keyboardLayout[rowIndex].indices, id: \.self) { keyIndex in
                        Button(action: {
                            handleKeyPress(key: keyboardLayout[rowIndex][keyIndex])
                        }) {
                            let keyString = keyboardLayout[rowIndex][keyIndex]
                            if keyString == "Enter" {
                                Image(systemName: "arrow.turn.down.right")
                                    .font(.system(size: 20, weight: .regular))
                                    .frame(width: 45)
                                    .frame(height: 42)
                                    .background(formatter.color(correctResponse.count == text.count ? .highContrastWhite : .primaryFG))
                                    .foregroundColor(correctResponse.count == text.count ? formatter.color(.primaryBG) : .white)
                                    .cornerRadius(5)
                                    .padding(.trailing, 6)
                                    .opacity(correctResponse.isEmpty ? 0 : 1)
                                    .opacity(correctResponse.count == text.count ? 1 : 0.4)
                            } else if keyString == "Delete" {
                                Image(systemName: "delete.left")
                                    .font(.system(size: 20, weight: .regular))
                                    .frame(width: 45)
                                    .frame(height: 42)
                                    .background(formatter.color(.primaryFG))
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                    .padding(.leading, 6)
                            } else {
                                Text(keyString)
                                    .font(formatter.font(.regular, fontSize: .medium))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 42)
                                    .background(formatter.color(.lowContrastWhite))
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                    .opacity(text.count > 13 ? 0.4 : 1)
                            }
                        }
                        .animation(.easeInOut(duration: 0.2))
                    }
                }
                .padding(.horizontal, rowIndex == 1 ? 15 : 0)
            }
        }
        .padding(.horizontal, 4)
        .frame(maxHeight: .infinity, alignment: .top)
        .transition(.move(edge: .bottom))
    }

    private func handleKeyPress(key: String) {
        switch key {
        case "Enter":
            formatter.dismissKeyboard()
            onPressEnter()
        case "Delete":
            if !text.isEmpty {
                text.removeLast()
            }
        default:
            formatter.hapticFeedback(style: .rigid, intensity: .weak)
            if correctResponse.isEmpty {
                if text.count > 13 { return }
            } else {
                if text.count == correctResponse.count { return }
            }
            text += key
        }
    }
}
