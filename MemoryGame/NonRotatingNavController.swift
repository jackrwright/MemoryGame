//
//  NonRotatingNavController.swift
//  MemoryGame
//
// This prevents rotation in a view controller embedded in a navigation controller
//
//  Created by Jack Wright on 2/5/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import UIKit

class NonRotatingNavController: UINavigationController {

	override var shouldAutorotate: Bool {
		return false
	}

}
