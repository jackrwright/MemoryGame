//
//  GamePlayViewController.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import UIKit
import SceneKit

struct Constants {
	// The scale of our scene relative to the UIView coordinate system
	static let sceneScale: CGFloat = 0.1
}

class GamePlayViewController: UIViewController {
	
	var gridOption: String?
	
	// Choose SceneKit or not
	private var useSceneKit = true
	
	private var myScene = SCNScene(named: "Game.scn")!
	private var boardNode: SCNNode!

	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var sceneView: SCNView!
	
	// MARK: - UIViewController delegate
	
	override func viewDidLoad() {
		
		if useSceneKit {
			self.stackView.isHidden = true
			
			self.sceneView.scene = myScene

			// For debugging: allows the user to manipulate the camera
//			self.sceneView.allowsCameraControl = true
			
			// add a tap gesture recognizer to handle card taps
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
			self.sceneView.addGestureRecognizer(tapGesture)
			

		} else {
			self.sceneView.isHidden = true
		}

		// Construct and display the grid of cards
		if let theGridOption = gridOption {
			generateCardArray(gridOptions[theGridOption]!)
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
	
	// MARK: - SceneKit Stuff
	
	func showCard(_ cardView: CardView, in view: UIView)
	{
		// Calculate the position in our scene
		
		// Adjust the size of the card image to aspect fit the CardView (which has been layed out by the UIStackView)
		let imageRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: CardView.width, height: CardView.height))
		let adjustedRect = CGRect.aspectFitRect(imageRect, into: cardView.bounds)
		
		// Create a card node and add it as a child to the board node
		let theCardNode = CardNode(cardView)
		self.boardNode.addChildNode(theCardNode)
		
		cardView.myNode = theCardNode
		
		let cardFrame = cardView.convert(cardView.bounds, to: view)
		let position = SCNVector3.init(cardFrame.mid.x, cardFrame.mid.y, 0.0)
		print("SceneKit position: \(position)")
		theCardNode.position = position
		
		theCardNode.myCardView = cardView
		
		// compute the scale based on the changed size
		let scale: CGFloat = adjustedRect.width / CardView.width
		
		print("card scale = \(scale)")
		
		theCardNode.scale = SCNVector3.init(x: Float(scale), y: Float(scale), z: Float(scale))
		
	}
	
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

//					// rotate the card
//					
//					SCNTransaction.begin()
//					SCNTransaction.animationDuration = 0.33
//					
//					cardNode.rotation = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: cardNode.rotation.w + Float(M_PI))
//					
//					SCNTransaction.commit()
//					
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
				
//				let startPoint = CGPoint(x: 0, y: card.frame.origin.y)
//				card.frame = CGRect(origin: startPoint, size: card.frame.size)
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

			// create a plane proportional to the size of the outer stackView at y = 0
			
			let board = SCNPlane()
			
			board.width = stackView.bounds.size.width
			board.height = stackView.bounds.size.height
			print("board dimensions: \(board.width), \(board.height)")
			let boardMaterial = SCNMaterial()
			boardMaterial.diffuse.contents = UIColor.clear
			board.firstMaterial = boardMaterial

			// Create a board node that is positioned so cards can be added to it using their UIView coordinates
			
			boardNode = SCNNode(geometry: board)

			self.myScene.rootNode.addChildNode(boardNode)

			for view in stackView.arrangedSubviews {
				if let horizontalStack = view as? UIStackView {
					for view in horizontalStack.arrangedSubviews {
						if let cardView = view as? CardView {
							// show a card node at the cardView's position
							self.showCard(cardView, in: self.sceneView)
						}
					}
				}
			}
			
			// Now, position and scale the board
			
			var boardPos = SCNVector3.init(stackView.frame.origin.x - CGFloat(board.width / 2.0) - 40,
			                               stackView.frame.origin.y - CGFloat(board.height / 2.0) - 10,
			                               0.0)
			boardPos = SCNVector3.init(boardPos.x * Float(Constants.sceneScale),
			                           boardPos.y * Float(Constants.sceneScale),
			                           boardPos.z
			)
			print("board position: \(boardPos)")
			boardNode.position = boardPos
			
			boardNode.scale = SCNVector3(Constants.sceneScale, Constants.sceneScale, Constants.sceneScale)
			
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
