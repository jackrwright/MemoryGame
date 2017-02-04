//
//  GamePlayViewController.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import UIKit

class GamePlayViewController: UIViewController {
	
	var gridOption: String?
	
	var previousCardTapped: CardView?
	
	@IBOutlet weak var stackView: UIStackView!
	
	typealias ArrayDimensions = (width: Int, height: Int)
	
	// These keys match the Storyboard identifiers
	private let gridOptions: Dictionary<String,ArrayDimensions> = [
		"threeByFour":	(3, 4),
		"fiveByTwo":	(5, 2),
		"fourByFour":	(4, 4),
		"fourByFive":	(4, 5)
	]
	
	private let cardImages: Dictionary<CardType,String> = [
		.cow: "Cow",
		.hen: "Hen",
	]
	
	func generateCardArray(_ dimensions: ArrayDimensions)
	{
		// Generate an array of the correct number of card pairs
		var cardArray = [CardType]()
		let numCardPairs = dimensions.width * dimensions.height / 2
		for _ in 0..<numCardPairs {
			let randomCardType = CardType.random()
			// append a pair of these
			cardArray.append(randomCardType)
			cardArray.append(randomCardType)
		}
		
		
		// Generate the rows of cards as horizontal UIStackViews
		let spacing: CGFloat = 10.0
		var horizontalStackViews = [UIStackView]()
		// for each row
		for _ in 0..<dimensions.height {
			var rowCardArray = [UIButton]()
			// for each column
			for _ in 0..<dimensions.width {
				let index = Int.random(cardArray.count)
				let randomCard = cardArray[index]
				let card = CardView(randomCard)
				// hook up the target
				card.addTarget(self, action: #selector(cardWasTapped(_:)), for: .touchUpInside)
				rowCardArray += [card]
				// remove the selected card from the array
				cardArray.remove(at: index)
			}
			let rowStackView = UIStackView(arrangedSubviews: rowCardArray)
			rowStackView.axis = .horizontal
			rowStackView.distribution = .fillEqually
			rowStackView.alignment = .fill
			rowStackView.spacing = spacing
			rowStackView.translatesAutoresizingMaskIntoConstraints = false
			
			view.addSubview(rowStackView)
			horizontalStackViews.append(rowStackView)
		}
		
		// Put the horizontal stack views into the vertical stack view created on the storyboard
		for rowStackView in horizontalStackViews {
			stackView.addArrangedSubview(rowStackView)
		}
		stackView.axis = .vertical
		stackView.distribution = .fillEqually
		stackView.alignment = .fill
		stackView.spacing = spacing
		stackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(stackView)

//		//autolayout the stack view - pin 30 up 20 left 20 right 30 down
//		let viewsDictionary = ["stackView":stackView]
//		let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[stackView]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
//		let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[stackView]-30-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
//		view.addConstraints(stackView_H)
//		view.addConstraints(stackView_V)

	}
	
	@objc fileprivate func cardWasTapped(_ card: CardView)
	{
		// change the card's image to it's face
		card.showFace()
		if let previousCard = previousCardTapped {
			if card.myType == previousCard.myType {
				// a match, disable user interaction with both cards
				card.isUserInteractionEnabled = false
				previousCard.isUserInteractionEnabled = false
				previousCardTapped = nil
			} else {
				// no match, turn the cards over after 1 second
				Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
					card.showBack()
					previousCard.showBack()
				})
				previousCardTapped = nil
			}
		} else {
			previousCardTapped = card
		}
	}
	
	override func viewDidLoad() {
		// Construct the grid of cards
		if let theGridOption = gridOption {
			generateCardArray(gridOptions[theGridOption]!)
		}
		
	}

}
