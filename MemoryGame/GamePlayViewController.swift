//
//  GamePlayViewController.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import UIKit
import SceneKit

class GamePlayViewController: UIViewController {
	
	var gridOption: String?
	
	// Choose SceneKit or not
	private var useSceneKit = true
	
	private var myScene = MainScene()

	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var sceneView: SCNView!
	
	override func viewDidLoad() {
		
		// Construct and display the grid of cards
		if let theGridOption = gridOption {
			generateCardArray(gridOptions[theGridOption]!)
		}
		
		if useSceneKit {
			self.stackView.isHidden = true
			
			self.sceneView.scene = myScene

			// allows the user to manipulate the camera
			self.sceneView.allowsCameraControl = true
			
			// add a tap gesture recognizer
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
			self.sceneView.addGestureRecognizer(tapGesture)
			

		} else {
			self.sceneView.isHidden = true
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		dealCards()
	}
	
	// This is a fun game, don't bother me with the clock
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	// MARK: - SceneKit Tap Handler

	func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		
		// check what nodes are tapped
		let p = gestureRecognize.location(in: self.sceneView)
		let hitResults = self.sceneView.hitTest(p, options: [:])
		// check that we clicked on at least one object
		if hitResults.count > 0 {
			// retrieved the first clicked object
			let result: AnyObject = hitResults[0]
			if let cardNode = result.node as? CardNode {
				if let cardView = cardNode.myCardView {

					// rotate the card
					
					SCNTransaction.begin()
					SCNTransaction.animationDuration = 0.33
					
					cardNode.rotation = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: cardNode.rotation.w + Float(M_PI))
					
					SCNTransaction.commit()
					
					// handle the tap
					cardWasTapped(cardView)
				}
			}
		}
		
	}
	
	// MARK: - Private Implementation
	
	private typealias ArrayDimensions = (width: Int, height: Int)
	
	// These keys must match the Storyboard segue identifiers for the buttons.
	// Update this if another grid option is desired.
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
		
		// See if we need to flip the grid dimensions to best fit the device orientation
		var width = dimensions.width
		var height = dimensions.height
		if needToFlipDimensions(width: width, height: height) {
			width = dimensions.height
			height = dimensions.width
		}
		
		for row in 0..<height {
			
			// for each row
			
			let rowStackView = UIStackView()
			rowStackView.axis = .horizontal
			rowStackView.distribution = .fillEqually
			rowStackView.alignment = .fill
			rowStackView.spacing = spacing
			rowStackView.translatesAutoresizingMaskIntoConstraints = false
			stackView.addArrangedSubview(rowStackView)
			
			// for each column
			for col in 0..<width {
				let index = row * width + col
				let card = CardView(cardTypeArray[index])
				// disable user interactions until the card is dealt
				card.isUserInteractionEnabled = false

				// hook up the button's target so the cardWasTapped function is called
				card.addTarget(self, action: #selector(cardWasTapped(_:)), for: .touchUpInside)
				
				let startPoint = CGPoint(x: 0, y: card.frame.origin.y)
				card.frame = CGRect(origin: startPoint, size: card.frame.size)
//				print("\(card.myType): \(card.frame)")
				rowStackView.insertArrangedSubview(card, at: col)
				
			}
		}
		
	}
	
	private func dealCards()
	{
		// Now that the stack views have been layed out,
		// cause the cards to animate into their positions from offscreen
		
		var delay = 0.0
		let duration = 0.15

		if useSceneKit {
			for view in stackView.arrangedSubviews {
				if let horizontalStack = view as? UIStackView {
					for view in horizontalStack.arrangedSubviews {
						if let cardView = view as? CardView {
							// show a card node at the cardView's position
							myScene.showCard(cardView)

						}
					}
				}
			}
		} else {
			for view in stackView.arrangedSubviews {
				if let horizontalStack = view as? UIStackView {
					for view in horizontalStack.arrangedSubviews {
						if let cardView = view as? CardView {
							cardView.dealAfterDelay(delay, withDuration: duration)
							delay += duration
						}
					}
				}
			}
			
		}

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
