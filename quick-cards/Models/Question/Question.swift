//
//  Question.swift
//  quick-cards
//
//  Created by Abby Smith on 6/29/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

//typealias Question = String

class Question: Codable, Hashable {
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.question == rhs.question
    }
    
    var hashValue: Int { return question.hashValue }
    
    var question: String
    var grade: Grade
    
    init(_ question: String, grade: Grade = .average) {
        self.question = question
        self.grade = grade
    }
}
