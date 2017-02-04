//
//  Card.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import Foundation

// These are the image file names that correspond to the CardType
private var faceImageName: Dictionary<CardType,String> = [
	.cow:		"Cow",
	.hen:		"Hen",
	.horse:		"Horse",
	.pig:		"Pig",
	.bat:		"Bat",
	.cat:		"Cat",
	.spider:	"Spider",
	.ghostDog:	"GhostDog"
]

enum CardType: Int {
	case cow, hen, horse, pig, bat, cat, spider, ghostDog
	
	// find the maximum enum value
	static let count: CardType.RawValue = {
		var maxValue: Int = 0
		while let _ = CardType(rawValue: maxValue) {
			maxValue += 1
		}
		return maxValue
	}()
	
	// pick and return a valid random value
	static func random() -> CardType {
		let rand = Int.random(count)
		return CardType(rawValue: rand)!
	}
	
	// return the image file name for the given CardType
	static func faceImageForType(_ type: CardType) -> String?
	{
		return faceImageName[type]
	}
}
