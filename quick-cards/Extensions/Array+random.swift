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
}

