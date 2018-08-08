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
    var avgTime: Double

    init(_ question: String, grade: Grade = .average, _ index: Int) {
        self.question = question
        self.grade = grade
        self.index = index
        self.seen = 0
        self.correct = 0
        self.avgTime = 0
    }
    
    func reset(index: Int) {
        self.index = index
        self.grade = .average
        self.seen = 0
        self.correct = 0
        self.avgTime = 0.0
    }
    
    func updateTime(newTime: Double) {
        if avgTime == 0.0 {
            avgTime = newTime
            return
        }
        avgTime = ( ( avgTime * Double(seen) ) + newTime ) / 2
    }
}
