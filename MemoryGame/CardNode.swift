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
	
	var myCardView: CardView?
	
	private var cubeNode: SCNNode!

	override init() {
		super.init()
		// create a cube node to represent the card
		let cube = SCNBox(width: 0.74, height: 1.06, length: 0.05, chamferRadius: 0.005)

		let cubeMaterial = SCNMaterial()
		cubeMaterial.diffuse.contents = UIColor.init(white: 0.8, alpha: 1.0)
		cube.materials = [cubeMaterial]

		self.geometry = cube
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
