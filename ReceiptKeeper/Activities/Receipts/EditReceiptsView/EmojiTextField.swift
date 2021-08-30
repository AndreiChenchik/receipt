////
////  EmojiTextField.swift
////  EmojiTextField
////
////  Created by Andrei Chenchik on 30/8/21.
////
//
//import Foundation
//
//class EmojiTextField: UITextField {
//
//       // required for iOS 13
//       override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯
//
//        override var textInputMode: UITextInputMode? {
//            for mode in UITextInputMode.activeInputModes {
//                if mode.primaryLanguage == "emoji" {
//                    return mode
//                }
//            }
//            return nil
//        }
//
//    override init(frame: CGRect) {
//            super.init(frame: frame)
//
//            commonInit()
//        }
//
//        required init?(coder: NSCoder) {
//            super.init(coder: coder)
//
//             commonInit()
//        }
//
//        func commonInit() {
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(inputModeDidChange),
//                                                   name: UITextInputMode.currentInputModeDidChangeNotification,
//                                                   object: nil)
//        }
//
//        @objc func inputModeDidChange(_ notification: Notification) {
//            guard isFirstResponder else {
//                return
//            }
//
//            DispatchQueue.main.async { [weak self] in
//                self?.reloadInputViews()
//            }
//        }
//    }
