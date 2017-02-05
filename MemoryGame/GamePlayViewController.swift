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
	
	@IBOutlet weak var stackView: UIStackView!
	
	override func viewDidLoad() {
		
		// Construct and display the grid of cards
		if let theGridOption = gridOption {
			generateCardArray(gridOptions[theGridOption]!)
		}
		
	}
	
	// prevent the view controller's contents from rotating when the game is in play
	override var shouldAutorotate: Bool {
		return false
	}
	
	// This is a fun game, don't bother me with the clock
	override var prefersStatusBarHidden: Bool {
		return true
	}

	// MARK: - Private Implementation
	
	private typealias ArrayDimensions = (width: Int, height: Int)
	
	// These keys must match the Storyboard segue identifiers for the buttons.
	// Update this is another grid option is desired.
	private let gridOptions: Dictionary<String,ArrayDimensions> = [
		"threeByFour":	(3, 4),
		"fiveByTwo":	(5, 2),
		"fourByFour":	(4, 4),
		"fourByFive":	(4, 5)
	]
	
	// Determine if we need to flip the grid dimensions to best fit the device orientation
	private func needToFlipDimensions(width: Int, height: Int) -> Bool
	{
		// We can't use traits because there are devices that are compact in both orientations
		let screenFrame = UIScreen.main.bounds
		
		if screenFrame.width > screenFrame.height && height > width {
			return true
		}
		
		if screenFrame.height > screenFrame.width && width > height {
			return true
		}
		
		return false
	}
	
	private func generateCardArray(_ dimensions: ArrayDimensions)
	{
		let numberOfCards = dimensions.width * dimensions.height
		
		// create a deck of card pairs
		var cardArray = CardType.createDeck(size: numberOfCards)
		
		// generate a random array of card type pairs
		var cardTypeArray = [CardType]()
		for _ in 0..<numberOfCards {
			let index = Int.random(cardArray.count)
			cardTypeArray.append(cardArray[index].type)
			cardArray.remove(at: index)
		}
		
		// Generate the rows of cards as horizontal UIStackViews...
		
		let spacing: CGFloat = 10.0
		var horizontalStackViews = [UIStackView]()
		
		// See if we need to flip the grid dimensions to best fit the device orientation
		var width = dimensions.width
		var height = dimensions.height
		if needToFlipDimensions(width: width, height: height) {
			width = dimensions.height
			height = dimensions.width
		}
		
		// for each row
		for row in 0..<height {
			var rowCardArray = [UIButton]()
			// for each column
			for col in 0..<width {
				let index = row * width + col
				let card = CardView(cardTypeArray[index])
//				print("Adding CardView for '\(cardTypeArray[index])'")
				// hook up the button's target so the cardWasTapped function is called
				card.addTarget(self, action: #selector(cardWasTapped(_:)), for: .touchUpInside)
				rowCardArray += [card]
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

	}
	
	// MARK: - Card Tap Logic
	
	// keep track of the card previously tapped
	private var previousCardTapped: CardView?
	
	// When true, the timer for turning a pair of unmatched cards is running
	private var isResetingCards = false
	
	// Time to wait before turning over unmatched cards in seconds
	private let unMatchedCardsTimer = 1.0
	
	// This function handles the card tap logic.
	// The 'card' argument is the CardView object as the sender.
	// We know which card type was tapped because it's an instance variable in the CardView object.
	@objc fileprivate func cardWasTapped(_ card: CardView)
	{
		// Don't respond to taps during the waiting period for turning unmatched cards back over
		if isResetingCards {
			return
		}
		
		// Ignore the tap if it is the same card
		if (card == previousCardTapped) {
			return
		}
		
		// change the card's image to it's face
		card.showFace()
		if previousCardTapped != nil {
			if card.myType == previousCardTapped!.myType {
				// a match, disable user interaction with both cards
				card.isUserInteractionEnabled = false
				previousCardTapped!.isUserInteractionEnabled = false
				previousCardTapped = nil
			} else {
				// no match, turn the cards over after 1 second
				
				// Prevent further taps until the cards have flipped back over
				isResetingCards = true
				
				// Start a timer to delay turning the cards over
				Timer.scheduledTimer(withTimeInterval: unMatchedCardsTimer, repeats: false, block: { (timer) in
					card.showBack()
					self.previousCardTapped!.showBack()
					self.isResetingCards = false
					self.previousCardTapped = nil
				})
			}
		} else {
			previousCardTapped = card
		}
	}
	
}
