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
        guard let randomIndex = getRandomIndex(self) else {
            return nil
        }
        return self[randomIndex]
    }
    
    private func getRandomIndex(_ array: Array<Any>) -> Int? {
        guard !array.isEmpty else {
            return nil
        }
        return Int(arc4random_uniform(UInt32(array.count)))
    }
}

