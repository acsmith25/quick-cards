//
//  Answer.swift
//  quick-cards
//
//  Created by Abby Smith on 6/29/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

class Answer: Codable {
    static func == (lhs: Answer, rhs: Answer) -> Bool {
        return lhs.answer == rhs.answer
    }
    
    var answer: String
    
    init(_ answer: String, level: Grade = .average) {
        self.answer = answer
    }
}
