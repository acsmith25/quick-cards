//
//  Array+random.swift
//  MyApp
//
//  Created by Abby Smith on 6/22/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

extension Array {
    
    func getElementAtRandomIndex() -> Element? {
        guard let randomIndex = self.getRandomIndex() else {
            return nil
        }
        return self[randomIndex]
    }
    
    func getRandomIndex() -> Int? {
        guard !self.isEmpty else {
            return nil
        }
        return Int(arc4random_uniform(UInt32(self.count)))
    }
}

