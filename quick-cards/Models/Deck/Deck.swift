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
    var mode: QuizMode
    var order: Order
    var timed: Bool
    var mastery: Double
    var progressCounter: Int = 0
    var hasCompletedFirstPass: Bool = false
    
    var cards: [Question: Answer]
    var questions: [Question]
    var answers: [Answer]
    var gradeDistribution: [Grade: [Question]]
    
    init(title: String, cards: [Question: Answer], mastery: Double = 50.0, order: Order = .random, timed: Bool = false) {
        self.title = title
        self.mode = .showAnswer
        self.mastery = mastery
        self.order = order
        self.timed = timed
        
        self.cards = cards
        self.questions = Array(cards.keys).sorted(by: { $0.index < $1.index } )
        self.answers = Array(cards.values)
        self.gradeDistribution = [.average: questions]
    }
    
    func updateOrder(order: Order) {
        sort(by: order)
        self.order = order
    }
    
    func updateTimed(timed: Bool) {
        self.timed = timed
    }
    
    func updateMode(mode: QuizMode) {
        self.mode = mode
    }
    
    func reset() {
        mastery = 50.0
        hasCompletedFirstPass = false
        progressCounter = 0
        questions = questions.enumerated().map({ (index, question) -> Question in
            question.grade = .average
            question.index = index
            question.seen = 0
            question.correct = 0
            return question
        })
        questions.sort(by: { $0.index < $1.index } )
        gradeDistribution = [.average: questions]
    }
    
    func sort(by order: Order) {
        switch order {
        case .difficulty:
            questions.sort(by: {
                if $0.seen == 0 || $1.seen == 0 { return $0.seen < $1.seen }
                if $0.correct == 0 && $1.correct == 0 { return $0.seen > $1.seen }
                var first = 0.0
                var second = 0.0
                if $0.seen > 0 && $0.correct > 0 { first = Double($0.correct) / Double($0.seen)  }
                if $1.seen > 0 && $1.correct > 0 { second = Double($1.correct) / Double($1.seen)  }
                return first < second
            })
        default:
            questions.sort(by: { $0.index < $1.index } )
        }
        progressCounter = 0 
        gradeDistribution = [.average: questions]
    }
    
    func addCard(question: String, answer: String, grade: Grade = .average) {
        let question = Question(question, questions.count)
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
    
    func removeCard(question: Question) {
        guard let answer = cards[question] else { return }
        
        guard var grade = gradeDistribution[question.grade] else { return }
        if let index = grade.index(where: { $0 == question }) {
            grade.remove(at: index)
        }
        gradeDistribution[question.grade] = grade
        
        cards[question] = nil
        
        if let index = questions.index(where: { $0 == question }) {
            questions.remove(at: index)
        }
        
        if let index = answers.index(where: { $0 == answer }) {
            answers.remove(at: index)
        }
    }
    
    func moveCard(question: Question, from originalIndex: Int, to newIndex: Int) {
        questions.remove(at: originalIndex)
        questions.insert(question, at: newIndex)
    }
    
    func setOrder() {
        questions = questions.enumerated().map { (index, question) -> Question in
            question.index = index
            return question
        }
    }
    
    func updateQuestion(oldQuestion: Question, newQuestion: String, newAnswer: String) {
        removeCard(question: oldQuestion)
        addCard(question: newQuestion, answer: newAnswer, grade: oldQuestion.grade)
    }
    
    func updateQuestionGrade(question: Question, grade: Grade, shouldInsertAtFront: Bool = false) {
        guard var targetGrade = gradeDistribution[grade] else {
            question.grade = grade
            gradeDistribution[grade] = [question]
            return
        }
        question.grade = grade
        if shouldInsertAtFront {
            targetGrade.insert(question, at: 0)
        } else {
            targetGrade.append(question)
        }
        gradeDistribution[grade] = targetGrade
    }
}

