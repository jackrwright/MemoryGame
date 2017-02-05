//
//  LobbyViewController.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController {

	// MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let navVC = segue.destination as? UINavigationController {
			if let gameVC = navVC.topViewController as? GamePlayViewController {
				if let identifier = segue.identifier {
					// Pass the storyboard ID to the gameVC so it knows what the grid choice was
					gameVC.gridOption = identifier
				}
			}
		}
	}

	// this is called when the back button is pressed in the gamePlayView
	@IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue)
	{
		
	}
	
	// This is a fun game, don't bother me with the clock
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
}


