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
		showBack()
		
//		let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: width)
//		constraint.priority = 1000
//		self.addConstraint(constraint)
		
		// Add an aspect ratio constraint to the button
		let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: aspectRatio, constant: 0)
		constraint.priority = 1000
		self.addConstraint(constraint)
	}
	
	required init?(coder aDecoder: NSCoder) {
		// This object can only be created programmatically
		fatalError("init(coder:) has not been implemented")
	}
	
	func showFace()
	{
		if let imageName = CardType.faceImageForType(myType) {
			setImage(UIImage.init(named: imageName), for: .normal)
		}
	}
	
	func showBack()
	{
		setImage(UIImage.init(named: "CardBack"), for: .normal)
	}
}
