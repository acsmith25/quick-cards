//
//  Answer.swift
//  quick-cards
//
//  Created by Abby Smith on 6/29/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

class Answer: Codable {
    var answer: String
//    var level: Level
    
    init(_ answer: String, level: Grade = .average) {
        self.answer = answer
//        self.level = level
    }
}
