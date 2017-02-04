//
//  LobbyViewController.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let gameVC = segue.destination as? GamePlayViewController {
			if let identifier = segue.identifier {
				gameVC.gridOption = identifier
			}
		}
	}

	@IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue)
	{
		
	}
}


