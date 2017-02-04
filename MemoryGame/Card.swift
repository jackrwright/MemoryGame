//
//  Card.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import Foundation

enum CardType: Int {
	case cow, hen, horse, pig, bat, cat, spider
	
	static let count: CardType.RawValue = {
		// find the maximum enum value
		var maxValue: Int = 0
		while let _ = CardType(rawValue: maxValue) {
			maxValue += 1
		}
		return maxValue
	}()
	
	static func random() -> CardType {
		// pick and return a valid random value
		let rand = Int.random(count)
		return CardType(rawValue: rand)!
	}
}
