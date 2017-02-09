//
//  Extensions.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import Foundation
import UIKit

extension Int {
	static func random(_ max: Int) -> Int {
		return Int(arc4random() % UInt32(max))
	}
}

extension CGRect {
	
	var mid: CGPoint { return CGPoint(x: midX, y: midY) }
	var upperLeft: CGPoint { return CGPoint(x: minX, y: minY) }
	var lowerLeft: CGPoint { return CGPoint(x: minX, y: maxY) }
	var upperRight: CGPoint { return CGPoint(x: maxX, y: minY) }
	var lowerRight: CGPoint { return CGPoint(x: maxX, y: maxY) }
	
	init(center: CGPoint, size: CGSize) {
		let upperLeft = CGPoint(x: center.x-size.width/2, y: center.y-size.height/2)
		self.init(origin: upperLeft, size: size)
	}
	
	static func aspectFitRect(_ innerRect: CGRect, into outerRect: CGRect) -> CGRect
	{
		// the width and height ratios of the rects
		let wRatio = outerRect.size.width/innerRect.size.width
		let hRatio = outerRect.size.height/innerRect.size.height
		
		// calculate scaling ratio based on the smallest ratio.
		let ratio = (wRatio < hRatio) ? wRatio : hRatio
		
		// The x-offset of the inner rect as it gets centered
		let xOffset = (outerRect.size.width-(innerRect.size.width*ratio))*0.5;
		
		// The y-offset of the inner rect as it gets centered
		let yOffset = (outerRect.size.height-(innerRect.size.height*ratio))*0.5;
		
		// aspect fitted origin and size
		let innerRectOrigin = CGPoint(x: xOffset+outerRect.origin.x, y: yOffset+outerRect.origin.y);
		let innerRectSize = CGSize(width: innerRect.size.width*ratio, height: innerRect.size.height*ratio);
		
		return CGRect(origin: innerRectOrigin, size: innerRectSize);
	}
}

extension UIImage {
	
	static func imageWithColor(color: UIColor, size: CGSize) -> UIImage? {
 
		let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height))
	 
		UIGraphicsBeginImageContext(rect.size)
	 
		var image: UIImage?
		
		if let context = UIGraphicsGetCurrentContext() {
	 
			context.setFillColor(color.cgColor);
		 
			context.fill(rect);
		 
			image = UIGraphicsGetImageFromCurrentImageContext();
		}
	 
		UIGraphicsEndImageContext();
	 
		return image;
	}
}
