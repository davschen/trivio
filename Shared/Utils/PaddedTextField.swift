//
//  PaddedTextField.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/16/22.
//

import Foundation
import UIKit
import SwiftUI

class ModifiedTextField: UITextField {
    let padding = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}

struct EnhancedTextField: UIViewRepresentable {
    @Binding var text: String
    
    var onDone: (() -> Void)?
    
    init(text: Binding<String>, onDone: (() -> Void)? = nil) {
        self._text = text
        self.onDone = onDone
    }

    func makeUIView(context: Context) -> ModifiedTextField {
        let textField = ModifiedTextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.font = UIFont(name: "Metropolis-Bold", size: 15)
        
        if nil != onDone {
            textField.returnKeyType = .done
        }
        
        return textField
    }
    
    func updateUIView(_ uiView: ModifiedTextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, onDone: onDone)
    }
  
    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: EnhancedTextField
        var onDone: (() -> Void)?
        
        init(_ parent: EnhancedTextField, onDone: (() -> Void)? = nil) {
            self.parent = parent
            self.onDone = onDone
        }
        
        func textView(_ textView: UITextView, replacementText text: String) -> Bool {
            print("PaddedTextField textView is even active at all")
            if let onDone = self.onDone, text == "\n" {
                print("PaddedTextField : Enhanced : Coordinator : textview")
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}

struct MobilePaddedTextField: View {
    private var onCommit: (() -> Void)?

    @Binding private var text: String
    
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
        }
    }

    private var formatter = MasterHandler()
    
    init (text: Binding<String>, onCommit: (() -> Void)? = nil) {
        self.onCommit = onCommit
        self._text = text
    }

    var body: some View {
        EnhancedTextField(text: self.internalText, onDone: onCommit)
            .font(formatter.font(.regular))
            .frame(alignment: .leading)
    }
}
