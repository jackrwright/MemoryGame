//
//  cardNode.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/7/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import UIKit
import SceneKit


class CardNode: SCNNode {
	
	var myCardView: CardView!
	
	var isUserInteractionEnabled: Bool = false
	
	static let depth: CGFloat = 1.0
	
	private var cubeNode: SCNNode!

	required init(_ cardView: CardView, cardRect: CGRect) {
		
		myCardView = cardView
		
		super.init()
		
		// Adjust the size of the card image to aspect fit the cardRect (which has been layed out by the UIStackView and scaled for the scene)
		let imageRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: CardView.width, height: CardView.height))
		let adjustedRect = CGRect.aspectFitRect(imageRect, into: cardRect)
		
		cardView.myNode = self
		
		self.myCardView = cardView
		
		// compute the scale based on the changed size
		let scale: CGFloat = adjustedRect.width / imageRect.width
		
//		print("card scale = \(scale)")
		
		self.scale = SCNVector3.init(x: Float(scale), y: Float(scale), z: Float(scale))
		
		// create a cube node to represent the card
		let cube = SCNBox(width: CardView.width, height: CardView.height, length: CardNode.depth * scale, chamferRadius: CardNode.depth * scale)
		
		let material_white = SCNMaterial()
		material_white.diffuse.contents = UIColor.init(white: 0.8, alpha: 1.0)
		
		let material_Back = SCNMaterial()
		material_Back.diffuse.contents = UIImage(named: "CardBack")
		
		let material_Face = SCNMaterial()
		if let imageName = CardType.faceImageForType((myCardView.myType)) {
			material_Face.diffuse.contents = UIImage(named: imageName)
		}
		
		cube.materials = [material_Back,  material_white, material_Face, material_white, material_white, material_white, material_white]
		
		self.geometry = cube
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func rotate(direction: Double)
	{
		// rotate the card
		
		SCNTransaction.begin()
		SCNTransaction.animationDuration = 0.5
		
		self.rotation = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: self.rotation.w + Float(M_PI * direction))
		
		SCNTransaction.commit()
	}
	
	func makePhysical()
	{
		// add a physical body
		let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		self.physicsBody = physicsBody
	}
	
}
