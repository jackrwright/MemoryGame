//
//  Card.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import Foundation

// These are the image file names that correspond to the CardType enum values.
// Update this when a new card face image is added.
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
	// Update this when new a new card face is added
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
	
	struct Card {
		var type: CardType
		
		func createDeck(size: Int) -> [Card]
		{
			// Create a deck of card pairs from the available card types

			var deck = [Card]()
			let enumCount = CardType.count
			// start at a random position in the enum to get a variety of pairs
			var n = Int.random(CardType.count)
			var total = 0
			while let card = CardType(rawValue: n), total < (size/2) {
				// append a pair
				deck.append(Card(type: card))
				deck.append(Card(type: card))
				n += 1
				total += 1
				if n >= enumCount {
					n = 0
				}
			}
			
			return deck
		}
	}
	
	static func createDeck(size: Int) -> [Card]
	{
		let card = Card(type: .cow)
		let cardArray = card.createDeck(size: size)
		return cardArray
	}

	
}
