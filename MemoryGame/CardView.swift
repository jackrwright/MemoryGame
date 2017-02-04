//
//  CardView.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import UIKit

class CardView: UIButton {
	
	var myType: CardType
	
	required init(_ type: CardType) {
		// set myType before super.init is called
		self.myType = type
		
		let width: CGFloat = 74
		let height: CGFloat = 106
		let aspectRatio = width / height
		
		let frame = CGRect(x: 0, y: 0, width: width, height: height)
		super.init(frame: frame)
		
		// set other operations after super.init, if required
		setImage(UIImage.init(named: "CardBack"), for: .normal)
		
		// Add an aspect ratio constraint to the button
		self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: aspectRatio, constant: 0))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
