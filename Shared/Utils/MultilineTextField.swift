//
//  MultilineTextField.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/17/22.
//

import Foundation
import SwiftUI
import UIKit

fileprivate struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        UITextField.appearance().tintColor = .white
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = UIFont(name: "Metropolis-Regular", size: formatter.shrink(iPadSize: 30, factor: 1.8))
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        
        if nil != onDone {
            textField.returnKeyType = .done
        }

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?

        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
    }
}

struct MultilineTextField: View {
    private var placeholder: String
    private var onCommit: (() -> Void)?

    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 50
    @State private var showingPlaceholder = false
    @State private var color = Color.white

    private var formatter = MasterHandler()
    
    init (_ placeholder: String = "", text: Binding<String>, color: Color = Color.white, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
        self.color = color
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, onDone: onCommit)
            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
            .background(placeholderView.foregroundColor(formatter.color(.lowContrastWhite)), alignment: .topLeading)
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder)
                    .font(formatter.font(.boldItalic))
                    .foregroundColor(formatter.color(.lowContrastWhite))
                    .padding(.leading, 4)
                    .padding(.top, 8)
            }
        }
    }
}

struct MobileMultilineTextField: View {
    private var placeholder: String
    private var onCommit: (() -> Void)?

    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 50
    @State private var showingPlaceholder = false
    @State private var color = Color.white

    private var formatter = MasterHandler()
    
    init (_ placeholder: String = "", text: Binding<String>, color: Color = Color.white, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
        self.color = color
    }

    var body: some View {
        ZStack (alignment: .leading) {
            if showingPlaceholder {
                Text(placeholder)
                    .font(formatter.font(.regular, fontSize: .regular))
                    .foregroundColor(formatter.color(.lowContrastWhite))
                    .offset(x: 4)
            }
            UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, onDone: onCommit)
                .font(formatter.font(.regular))
                .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight, alignment: .leading)
        }
    }
}

// MARK: - Trivia Decks

fileprivate struct UITextViewWrapperTriviaDeck: UIViewRepresentable {
    typealias UIViewType = UITextView

    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapperTriviaDeck>) -> UITextView {
        let textField = UITextView()
        UITextField.appearance().tintColor = .white
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = UIFont(name: "BigCaslon-Medium", size: text.count > 130 ? 20 : 25)
        textField.textAlignment = .center
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        textField.autocapitalizationType = .sentences
        
        if nil != onDone {
            textField.returnKeyType = .done
        }

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapperTriviaDeck>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        uiView.font = UIFont(name: "BigCaslon-Medium", size: text.count > 130 ? 20 : 25)
        UITextViewWrapperTriviaDeck.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?

        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
    }
}

struct MobileMultilineTextFieldTriviaDeck: View {
    private var placeholder: String
    private var onCommit: (() -> Void)?

    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 80
    @State private var showingPlaceholder = false
    @State private var color = Color.white

    private var formatter = MasterHandler()
    
    init (_ placeholder: String = "", text: Binding<String>, color: Color = Color.white, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
        self.color = color
    }

    var body: some View {
        ZStack (alignment: .center) {
            if showingPlaceholder {
                Text(placeholder)
                    .multilineTextAlignment(.center)
                    .font(formatter.bigCaslonFont(sizeFloat: 25))
                    .foregroundColor(formatter.color(.lowContrastWhite))
                    .offset(x: 5)
            }
            UITextViewWrapperTriviaDeck(text: self.internalText, calculatedHeight: $dynamicHeight, onDone: onCommit)
                .font(formatter.bigCaslonFont(sizeFloat: 25))
                .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight, alignment: .leading)
        }
        .animation(nil)
    }
}

extension TextEditor { @ViewBuilder func hideBackground() -> some View { if #available(iOS 16, *) { self.scrollContentBackground(.hidden) } else { self } } }

