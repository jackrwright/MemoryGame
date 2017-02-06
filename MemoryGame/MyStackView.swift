//
//  MyStackView.swift
//  MemoryGame
//
// This stackview allows animation of its arranged views
//
//  Created by Jack Wright on 2/5/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import UIKit

class MyStackView: UIStackView {

	override func layoutSubviews() {
		super.layoutSubviews()
		
		return
		
		// There are other possibilities, but this doesn't look too bad
		
//		for view in self.arrangedSubviews {
//			if let horizontalStack = view as? UIStackView {
//				for view in horizontalStack.arrangedSubviews {
//					if let cardView = view as? CardView {
//						UIView.animate(withDuration: 0.5, animations: { 
//							cardView.isHidden = false
////							print("\(cardView.myType): \(cardView.bounds)")
//						})
//					}
//				}
//			}
//		}
	}

}
