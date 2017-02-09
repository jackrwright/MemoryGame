//
//  SceneKitView.swift
//  MemoryGame
//
//  This is the game playing scene.game.
//  The cards are added dynammically.
//
//  Created by Jack Wright on 2/7/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class MainScene: SCNScene {
	
	override init() {
		super.init()
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func showCard(_ cardView: CardView)
	{
		// get the card's frame in window coordinates
		var endFrame = cardView.convert(cardView.bounds, to: nil)
		
		// offset x so the card is centered
		endFrame.origin.x += cardView.bounds.width / 2.0
		
		let point = endFrame.origin
		
		// FIX: Needs work
		let scale = 1.0 //cardView.bounds.width / 74.0
		
		// Calculate the position in our scene
		
		let theCardNode = CardNode(cardView)
		let position = SCNVector3.init(x: (Float)(point.x) / 100.0, y: (Float)(point.y) / 100.0, z: 0.0)
		print("Creating card at: \(position)")
		theCardNode.position = position
		
		theCardNode.myCardView = cardView
		
		// need to scale the card because the UISTackView may have
		theCardNode.scale = SCNVector3.init(x: Float(scale), y: Float(scale), z: Float(scale))
		
		self.rootNode.addChildNode(theCardNode)

	}
	
}
