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
	
	private var cubeNode: SCNNode!

	required init(_ cardView: CardView) {
		
		myCardView = cardView
		
		super.init()
		
		// create a cube node to represent the card
		let cube = SCNBox(width: CardView.width, height: CardView.height, length: 5, chamferRadius: 5)

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
	
	func rotate()
	{
		// rotate the card
		
		SCNTransaction.begin()
		SCNTransaction.animationDuration = 0.33
		
		self.rotation = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: self.rotation.w + Float(M_PI))
		
		SCNTransaction.commit()
		

	}
	
}
