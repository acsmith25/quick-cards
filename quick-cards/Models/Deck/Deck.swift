//
//  Deck.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

class Deck: Codable {
    static func == (lhs: Deck, rhs: Deck) -> Bool {
        return lhs.title == rhs.title
    }
    
    var title: String
    var mastery: Double
    var isInInitialState: Bool {
        get {
            return Array(gradeDistribution.keys) == [.average]
        }
    }
    var hasCompletedFirstPass: Bool = false
    
    var cards: [Question: Answer]
    var questions: [Question]
    var answers: [Answer]
    var gradeDistribution: [Grade: [Question]]
    
    init(title: String, cards: [Question: Answer], mastery: Double = 50.0) {
        self.title = title
        self.mastery = mastery
        
        self.cards = cards
        self.questions = Array(cards.keys)
        self.answers = Array(cards.values)
        self.gradeDistribution = [.average: questions]
    }
    
    func reset() {
        mastery = 50.0
        hasCompletedFirstPass = false
        questions = questions.map({ (question) -> Question in
            question.grade = .average
            return question
        })
        gradeDistribution = [.average: questions]
    }
    
    func addCard(question: String, answer: String, grade: Grade = .average) {
        let question = Question(question)
        let answer = Answer(answer)
        cards[question] = answer
        questions.append(question)
        answers.append(answer)
        
        guard var targetGrade = gradeDistribution[grade] else {
            question.grade = grade
            gradeDistribution[grade] = [question]
            return
        }
        question.grade = grade
        targetGrade.append(question)
        gradeDistribution[grade] = targetGrade
    }
    
    func updateQuestionGrade(question: Question, grade: Grade) {
        guard var targetGrade = gradeDistribution[grade] else {
            question.grade = grade
            gradeDistribution[grade] = [question]
            return
        }
        question.grade = grade
        targetGrade.append(question)
        gradeDistribution[grade] = targetGrade
    }
}

