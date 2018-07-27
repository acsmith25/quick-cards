//
//  Question.swift
//  quick-cards
//
//  Created by Abby Smith on 6/29/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

class Question: Codable, Hashable {
    var hashValue: Int { return question.hashValue }
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.question == rhs.question
    }
    
    var question: String
    var index: Int
    var grade: Grade
    var seen: Int
    var correct: Int

    init(_ question: String, grade: Grade = .average, _ index: Int) {
        self.question = question
        self.grade = grade
        self.index = index
        self.seen = 0
        self.correct = 0
    }
}
