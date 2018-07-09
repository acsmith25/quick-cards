//
//  Card.swift
//  MyApp
//
//  Created by Abby Smith on 6/22/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

class Card: Codable {
    var question: String
    var answer: String
    var level: Grade
    
    init(question: String, answer: String, level: Grade = .average) {
        self.question = question
        self.answer = answer
        self.level = level
    }
}
