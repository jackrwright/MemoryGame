//
//  Extensions.swift
//  MemoryGame
//
//  Created by Jack Wright on 2/3/17.
//  Copyright © 2017 Jack Wright. All rights reserved.
//

import Foundation

extension Int {
	static func random(_ max: Int) -> Int {
		return Int(arc4random() % UInt32(max))
	}
}
