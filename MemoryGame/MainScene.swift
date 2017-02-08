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
	
	var frameInStackVoew: CGRect?

	private var cameraNode: SCNNode!
	private var lightNode: SCNNode!

	override init() {
		super.init()
		
		// a camera
		let camera = SCNCamera()
		camera.xFov = 60
		camera.yFov = 60

		// ambient light
		let ambientLight = SCNLight()
		ambientLight.type = SCNLight.LightType.ambient
		ambientLight.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
		
		// The camera node
		self.cameraNode = SCNNode()
		self.cameraNode.camera = camera
		self.cameraNode.light = ambientLight
		let screenBounds = UIScreen.main.bounds
		let cameraPosition = SCNVector3(x: Float(screenBounds.width / 200.0), y: Float(screenBounds.height / 200.0), z: 3.5)
		print("Camera position = \(cameraPosition)")
		self.cameraNode.position = cameraPosition
		
		let omniLight = SCNLight()
		omniLight.type = SCNLight.LightType.omni
		
		self.lightNode = SCNNode()
		self.lightNode.light = omniLight
		self.lightNode.position = SCNVector3(x: -30, y: 50, z: 30)
		
		self.rootNode.addChildNode(self.cameraNode)
		self.rootNode.addChildNode(self.lightNode)
		
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
		
		let scale = 1.0 //cardView.bounds.width / 74.0
		
		// Calculate the position in our scene
		
		let theCardNode = CardNode()
		let position = SCNVector3.init(x: (Float)(point.x) / 100.0, y: (Float)(point.y) / 100.0, z: 0.0)
		print("Creating card at: \(position)")
		theCardNode.position = position
		
		theCardNode.myCardView = cardView
		
		// need to scale the card because the UISTackView may have
		theCardNode.scale = SCNVector3.init(x: Float(scale), y: Float(scale), z: Float(scale))
		
		self.rootNode.addChildNode(theCardNode)

	}
	
}
