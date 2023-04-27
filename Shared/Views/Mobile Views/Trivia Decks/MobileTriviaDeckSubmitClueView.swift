//
//  MobileTriviaDeckSubmitClueView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/26/23.
//

import Foundation
import SwiftUI

struct MobileTriviaDeckSubmitClueView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    @Binding var doneWritingTriviaDeckClue: Bool
    
    @State var clueStringToSubmit = ""
    @State var responseStringToSubmit = ""
    @State var isNativeKeyboardActive = false
    @State var isTypingResponse = false
    
    @State private var showCategoryActionSheet = false
    @State private var focusTextField = false
    
    func focusResponseTextField() {
        formatter.dismissKeyboard()
        isTypingResponse = true
    }
    
    var body: some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    Button(action: {
                        showCategoryActionSheet = true
                    }) {
                        HStack {
                            Text("\(exploreVM.currentTriviaDeckClue.category)")
                            Image(systemName: "chevron.down")
                                .font(.system(size: 15))
                        }
                    }
                    .actionSheet(isPresented: $showCategoryActionSheet) {
                        ActionSheet(title: Text("Select a Category"), message: nil, buttons: categoryButtons())
                    }
                    Spacer(minLength: 0)
                    MobileMultilineTextFieldTriviaDeck("Start your clue here...", text: $clueStringToSubmit, onCommit: {
                        focusResponseTextField()
                    })
                    .padding(.horizontal)
                    if (isTypingResponse && !isNativeKeyboardActive) || !responseStringToSubmit.isEmpty {
                        MobileTriviaDeckResponseTextField(responseStringToSubmit: $responseStringToSubmit, isTypingResponse: $isTypingResponse)
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity)
                            .onTapGesture(perform: focusResponseTextField)
                    }
                    Spacer(minLength: 0)
                    MobileTriviaDeckSubmitButtonView(clueStringToSubmit: $clueStringToSubmit, responseStringToSubmit: $responseStringToSubmit, isNativeKeyboardActive: $isNativeKeyboardActive, isTypingResponse: $isTypingResponse, doneWritingTriviaDeckClue: $doneWritingTriviaDeckClue)
                }
                .frame(minHeight: 360, maxHeight: .infinity)
                .padding(.vertical, 35)
                .background(formatter.color(.primaryFG))
                .cornerRadius(10)
                .padding(10)
                
                if !isNativeKeyboardActive && isTypingResponse {
                    MobileTriviaDeckKeyboardView(text: $responseStringToSubmit, isTypingResponse: $isTypingResponse)
                }
            }
        }
        .onAppear {
            exploreVM.currentTriviaDeckClue.setCategory(newCategory: exploreVM.currentTriviaDeck.categories.first ?? "NULL CATEGORY")
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                isNativeKeyboardActive = true
                isTypingResponse = false
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                isNativeKeyboardActive = false
            }
        }
    }
    
    func categoryButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []

        for category in exploreVM.currentTriviaDeck.categories {
            let button = ActionSheet.Button.default(Text(category)) {
                exploreVM.currentTriviaDeckClue.setCategory(newCategory: category)
            }
            buttons.append(button)
        }

        buttons.append(.cancel())
        return buttons
    }
}

struct MobileTriviaDeckSubmitButtonView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var clueStringToSubmit: String
    @Binding var responseStringToSubmit: String
    @Binding var isNativeKeyboardActive: Bool
    @Binding var isTypingResponse: Bool
    @Binding var doneWritingTriviaDeckClue: Bool
    
    @State var isLoading = false
    
    func focusResponseTextField() {
        formatter.dismissKeyboard()
        isTypingResponse = true
    }
    
    var body: some View {
        Button {
            if isNativeKeyboardActive {
                focusResponseTextField()
            } else {
                isLoading = true
                let datamuse = Datamuse()
                datamuse.checkWord(word: responseStringToSubmit) { isFound in
                    if !isFound {
                        formatter.setAlertSettings(alertAction: { isLoading = false }, alertTitle: "Oops!", alertSubtitle: "Looks like '\(responseStringToSubmit)' isn't a valid word. Try again!", hasCancel: false, actionLabel: "Back")
                    } else {
                        isLoading = false
                        doneWritingTriviaDeckClue = true
                        exploreVM.submitTriviaDeckClue(triviaDeckClue: TriviaDeckClue(clue: clueStringToSubmit, response: responseStringToSubmit), authorID: profileVM.myUID, authorUsername: profileVM.username)
                    }
                }
            }
        } label: {
            if isTypingResponse {
                ZStack {
                    if isLoading {
                        LoadingView(color: .primaryBG, circleDiameter: 3)
                    } else {
                        Text("Submit")
                            .font(formatter.font(.regular, fontSize: .regular))
                            .foregroundColor(formatter.color(.primaryBG))
                    }
                }
                .frame(width: 100, height: 35)
                .background(formatter.color(.highContrastWhite))
                .clipShape(Capsule())
                .opacity((responseStringToSubmit.isEmpty) ? 0.4 : 1)
                .transition(.identity)
            } else {
                Text("\(responseStringToSubmit.isEmpty ? "Write a" : "Edit your") Response")
                    .font(formatter.font(.regular, fontSize: .regular))
                    .foregroundColor(formatter.color(.primaryBG))
                    .padding(10)
                    .padding(.horizontal, 7)
                    .background(formatter.color(.highContrastWhite))
                    .clipShape(Capsule())
                    .opacity((clueStringToSubmit.isEmpty) ? 0.4 : 1)
                    .transition(.identity)
            }
        }
        .disabled(clueStringToSubmit.isEmpty || (isTypingResponse && responseStringToSubmit.isEmpty))
    }
}

struct MobileTriviaDeckResponseTextField: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var responseStringToSubmit: String
    @Binding var isTypingResponse: Bool
    
    @State private var isCursorVisible = true
    
    var body: some View {
        ZStack {
            if responseStringToSubmit.isEmpty {
                Text("Your one-word response here…")
                    .font(formatter.bigCaslonFont(sizeFloat: 25))
                    .foregroundColor(formatter.color(.lowContrastWhite))
            }
            
            HStack (spacing: 0) {
                Text(responseStringToSubmit)
                    .font(formatter.bigCaslonFont(sizeFloat: 25))
                    .foregroundColor(formatter.color(.secondaryAccent))
                    .lineLimit(1)
                Capsule()
                    .frame(width: 2, height: 30)
                    .opacity((isCursorVisible && isTypingResponse) ? 1 : 0)
                    .offset(y: -1)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    isCursorVisible.toggle()
                }
            }
        }
        .animation(nil)
    }
}

struct MobileTriviaDeckSubmittedClueView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var doneWritingTriviaDeckClue: Bool
    
    var body: some View {
        VStack (spacing: 25) {
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 60))
            Text("Thanks for submitting!")
                .font(formatter.bigCaslonFont(sizeFloat: 30))
            Text("We’re reviewing clues all the time, so yours should be processed soon. To check the status of your clue, visit your profile.")
                .font(formatter.bigCaslonFont(sizeFloat: 20))
                .lineSpacing(5)
                .multilineTextAlignment(.center)
            Button {
                doneWritingTriviaDeckClue = false
            } label: {
                Text("Write another")
                    .font(formatter.font(.regular, fontSize: .regular))
                    .foregroundColor(formatter.color(.primaryBG))
                    .padding(10)
                    .padding(.horizontal, 7)
                    .background(formatter.color(.highContrastWhite))
                    .clipShape(Capsule())
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 15)
        .padding(.bottom, 100)
    }
}
