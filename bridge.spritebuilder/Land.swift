//
//  Land.swift
//  Bridge
//
//  Created by Cal on 5/18/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Land: CCNode {
    
    var _land : CCNode!
    let _xPosition : CGFloat = 200
    
    func didLoadFromCCB() {
        self.setLandPosition()
    }
    
    func setLandPosition() {
        _land.position = ccp(_land.position.x, 50)
    }
}