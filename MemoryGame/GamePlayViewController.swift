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
	static let sceneScale: CGFloat = 1.0
}

class GamePlayViewController: UIViewController {
	
	var gridOption: String?
	
	// Choose SceneKit or not
	private var useSceneKit = true
	
	private var myScene = SCNScene(named: "Game2.scn")!
	private var boardNode: SCNNode!
	private var sceneBounds: CGRect!
	private var sceneScale: CGFloat!
	private var boardView: UIView!
	
	private var numberOfCards: Int = 0
	
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var sceneView: SCNView!
	
	// MARK: - UIViewController delegate
	
	override func viewDidLoad() {
		
		if useSceneKit {
			// Leave this visible to debug card placement in the scene vs. cell placement in the UIStackView.
			// You can use the Xcode view debugging tool.
			// But, it must be hidden to allow the user to tap the cards.
			self.stackView.isHidden = true
			
			self.sceneView.scene = myScene
			
			// For debugging: allows the user to manipulate the camera
//						self.sceneView.allowsCameraControl = true
			
			// add a tap gesture recognizer to handle card taps
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
			self.sceneView.addGestureRecognizer(tapGesture)
			
			let screenRect = UIScreen.main.bounds
	
			// it's good to crash if we don't have a camera
			let camera = self.sceneView.pointOfView!.camera!
			let cameraPosition = self.sceneView.pointOfView!.position
	
			// Compute the width and height in points of the visible plane at z = 0 (where the game board is)
			let distance = Double(cameraPosition.z)
			let yFov = camera.yFov * .pi / 180.0
			let aspect = Double(screenRect.width / screenRect.height)
			let height = 2.0 * tan(yFov / 2.0) * distance
			let width = height * aspect
	
			sceneBounds = CGRect(x: 0.0, y: 0.0, width: width, height: height)
			boardView = UIView(frame: sceneBounds)
	
			sceneScale = CGFloat(width) / screenRect.width
			
			
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
	
	private func showCard(_ cardView: CardView, atDepth depth: CGFloat, afterDelay delay: TimeInterval, withDuration duration: TimeInterval)
	{
		
		// Create a card node and position it at the edge of the screen
		
		var cardFrame = cardView.convert(cardView.bounds, to: boardView)
		
		// scale the card for the scene
		let newOrigin = CGPoint(x: cardFrame.origin.x * sceneScale, y: cardFrame.origin.y * sceneScale)
		let newSize = CGSize(width: cardFrame.size.width * sceneScale, height: cardFrame.size.height * sceneScale)
		cardFrame = CGRect(origin: newOrigin, size: newSize)
		
		// start position...
		
		let originX: CGFloat = 0.0
		let originY: CGFloat = (sceneBounds.height / 2.0) + cardFrame.size.height / 2.0 - 150.0
		let startPosition = SCNVector3.init(originX, originY, depth)
		
		// end position...
		
		// add it to the scene at the start position
		let theCardNode = CardNode(cardView, cardRect: cardFrame)
		theCardNode.isUserInteractionEnabled = false
		
		// translate the card into the scene's coordinate space
		let originOffsetX: CGFloat = -(sceneBounds.width / 2.0)
		let originOffsetY: CGFloat = -(sceneBounds.height / 2.0) - 100.0 * sceneScale
		
		let endPosition = SCNVector3.init(cardFrame.mid.x + originOffsetX, cardFrame.mid.y + originOffsetY, -100.0)
		
		theCardNode.position = startPosition
		self.myScene.rootNode.addChildNode(theCardNode)
		
		// Animate the card onto the scene after the given delay
		Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { (timer) in
			
			SCNTransaction.begin()
			
			SCNTransaction.animationDuration = duration
			SCNTransaction.animationTimingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
			
			theCardNode.position = endPosition
			
			// enable user interaction when the animation is complete
			SCNTransaction.completionBlock = (() -> Void)? {
				
				theCardNode.isUserInteractionEnabled = true
			}
			
			SCNTransaction.commit()
			
		}) // timer block

	}
	
	func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		
		// check what nodes are tapped
		let p = gestureRecognize.location(in: self.sceneView)
		let hitResults = self.sceneView.hitTest(p, options: [:])
		// check that we clicked on at least one object
		if hitResults.count > 0 {
			// retrieved the first clicked object
			let result: AnyObject = hitResults[0]
			if let cardNode = result.node as? CardNode, cardNode.isUserInteractionEnabled {
				if let cardView = cardNode.myCardView {
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
		numberOfCards = dimensions.width * dimensions.height
		
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
			
			if let dimensions = gridOptions[gridOption!] {
				let numberOfCards = dimensions.width * dimensions.height
				var depth = CGFloat(numberOfCards) * CardNode.depth
				for view in stackView.arrangedSubviews {
					if let horizontalStack = view as? UIStackView {
						for view in horizontalStack.arrangedSubviews {
							if let cardView = view as? CardView {
								// show a card node at the cardView's position
								self.showCard(cardView, atDepth: depth, afterDelay: delay, withDuration: duration)
								delay += duration
								depth -= CardNode.depth
							}
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
		if let previousCard = previousCardTapped {
			if card.myType == previousCard.myType {
				
				// a match, disable user interaction with both cards
				
				card.isUserInteractionEnabled = false
				previousCard.isUserInteractionEnabled = false
				
				previousCardTapped = nil
				
				// Detect the end of the game
				numberOfCards -= 2
				if numberOfCards <= 0 {
					endGame()
				}
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
	
	func endGame()
	{
		let m: Float = 2.0
		
		self.myScene.physicsWorld.gravity = SCNVector3.init(0.0, -98.0, 0.0)
		
		// Make each cardNode a physical object and apply a force to it
		for view in stackView.arrangedSubviews {
			if let horizontalStack = view as? UIStackView {
				for view in horizontalStack.arrangedSubviews {
					if let cardView = view as? CardView {
						if let node = cardView.myNode {
							node.makePhysical()
							if let body = node.physicsBody {
								var randomX = Float.random(min: -10, max: 10) * m
								let randomY = Float.random(min: 10, max: 18) * m
								let randomZ = Float.random(min: -10, max: 18) * m
								let force = SCNVector3(x: randomX, y: randomY , z: randomZ)
								
								// create an offset from the card's center of mass for the application of the force so the card spins a bit
								randomX = Float.random(min: -10.0, max: 10.0)
								let randomPosition = SCNVector3(x: randomX * m, y: 0.0, z: 0.0)
								
								body.applyForce(force, at: randomPosition, asImpulse: true)
								
//								body.applyForce(force, asImpulse: true)
							}

						}
					}
				}
			}
		}

	}
	
}
