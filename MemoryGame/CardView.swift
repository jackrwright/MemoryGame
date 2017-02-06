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
		
		// These dimensions match the @1x image size,
		// but the image may be redimensioned by the UIStackView.
		let width: CGFloat = 74
		let height: CGFloat = 106
		
		let frame = CGRect(x: 0, y: 0, width: width, height: height)
		super.init(frame: frame)
		
		// This keeps the aspect ratio of the card image constant
		self.imageView?.contentMode = .scaleAspectFit
		
		// Add a shadow to help with those images that have no outline.
		// I tried to appoximate the shadow on the provided back button artwork.
		self.layer.shadowOffset = CGSize.init(width: -2, height: 2)
		self.layer.shadowOpacity = 0.4;
		self.layer.shadowRadius = 5.0;
		self.clipsToBounds = false;
		self.layer.shouldRasterize = true;
		
		// No image is added at this point because the card positions will be layed out
		// prior to actually displaying them.
	}
	
	required init?(coder aDecoder: NSCoder) {
		// This object can only be created programmatically
		fatalError("init(coder:) has not been implemented")
	}
	
	func dealAfterDelay(_ delay: TimeInterval, withDuration: TimeInterval)
	{
		var startFrame = self.convert(frame, from: nil)
		let startPoint = CGPoint(x: startFrame.origin.x - frame.size.width - 10.0, y: startFrame.origin.y)
		startFrame = CGRect(origin: startPoint, size: startFrame.size)
		let endFrame = frame
		
		UIView.animate(withDuration: 0, animations: {
			self.frame = startFrame
		}) { (complete) in
			self.setImage(UIImage.init(named: "CardBack"), for: .normal)
			UIView.animate(withDuration: withDuration, delay: delay, options: [.curveEaseOut], animations: {
				self.frame = endFrame
			}, completion: { (_) in
				self.isUserInteractionEnabled = true
			})
		}
	}
	
	// Could do some animations here
	func showFace()
	{
		if let imageName = CardType.faceImageForType(myType) {
			
			UIView.transition(with: self.imageView!, duration: 0.25, options: .transitionFlipFromRight, animations: {
				self.setImage(UIImage.init(named: imageName), for: .normal)
			}, completion: nil)
		}
	}
	
	func showBack()
	{
		UIView.transition(with: self.imageView!, duration: 0.25, options: .transitionFlipFromLeft, animations: {
			self.setImage(UIImage.init(named: "CardBack"), for: .normal)
		}, completion: nil)
	}
}
