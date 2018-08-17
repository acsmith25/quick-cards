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
    
    // MARK: - Properties
    
    var title: String
    var mastery: Double
    var isTimed: Bool
    var order: QuestionOrder
    var quizMode: QuizMode = .showAnswer {
        didSet {
            switch quizMode {
            case .showAnswer, .grid:
                isTimed = false
            default:
                return
            }
        }
    }
    var progressCounter: Int = 0
    var hasCompletedFirstPass: Bool = false
    
    var cards: [Question: Answer]
    var questions: [Question]
    var answers: [Answer]
    var gradeDistribution: [Grade: [Question]]
    
    // MARK: - Deck Methods
    
    init(title: String, cards: [Question: Answer], mastery: Double = 50.0, order: QuestionOrder = .random, timed: Bool = false) {
        self.title = title
        self.mastery = mastery
        self.order = order
        self.isTimed = timed
        
        self.cards = cards
        self.questions = Array(cards.keys).sorted(by: { $0.index < $1.index } )
        self.answers = Array(cards.values)
        self.gradeDistribution = [.average: questions]
    }
    
    func reset() {
        mastery = 50.0
        hasCompletedFirstPass = false
        progressCounter = 0
        questions = questions.enumerated().map({ (index, question) -> Question in
            question.reset(index: index)
            return question
        })
        sortQuestions(by: .inOrder)
        gradeDistribution = [.average: questions]
    }
    
    func sortQuestions(by order: QuestionOrder) {
        /** Resets progress **/
        progressCounter = 0
        
        switch order {
        case .inOrder:
            questions.sort(by: { $0.index < $1.index } )
        case .random:
            break
        case .difficulty:
            questions.sort(by: {
                // Return which ever hasn't been seen
                if $0.seen == 0 || $1.seen == 0 { return $0.seen < $1.seen }
                
                // If neither have been correct, return which has been seen more times
                if $0.correct == 0 && $1.correct == 0 { return $0.seen > $1.seen }
                
                // Use ratios of correct to seen
                var first = 0.0
                var second = 0.0
                if $0.seen > 0 && $0.correct > 0 { first = Double($0.correct) / Double($0.seen)  }
                if $1.seen > 0 && $1.correct > 0 { second = Double($1.correct) / Double($1.seen)  }
                return first < second
            })
        }
        gradeDistribution = [.average: questions]
    }
    
    // MARK: - Card Methods
    
    func addCard(question: String, answer: String, grade: Grade = .average) {
        let question = Question(question, questions.count)
        let answer = Answer(answer)
        
        cards[question] = answer
        questions.append(question)
        answers.append(answer)
        
        updateQuestionGrade(question: question, newGrade: grade)
    }
    
    func removeCard(question: Question) {
        guard let answer = cards[question] else { return }
        
        if let index = questions.index(where: { $0 == question }) {
            questions.remove(at: index)
        }
        if let index = answers.index(where: { $0 == answer }) {
            answers.remove(at: index)
        }
        
        removeQuestionFromGrade(question: question)
        cards[question] = nil
    }
    
    func moveCard(question: Question, from originalIndex: Int, to newIndex: Int) {
        questions.remove(at: originalIndex)
        questions.insert(question, at: newIndex)
    }
    
    // MARK: - Modifiers
    
    func updateQuestion(oldQuestion: Question, newQuestion: String, newAnswer: String) {
        removeCard(question: oldQuestion)
        addCard(question: newQuestion, answer: newAnswer, grade: oldQuestion.grade)
    }
    
    func updateIndices() {
        self.questions = questions.enumerated().map { (index, question) -> Question in
            question.index = index
            return question
        }
    }
    
    func updateOrder(order: QuestionOrder) {
        self.order = order
        sortQuestions(by: order)
    }
    
    func updateTimed(isTimed: Bool) {
        self.isTimed = isTimed
    }
    
    func updateMode(quizMode: QuizMode) {
        self.quizMode = quizMode
    }
    
    func updateMastery(newMastery: Double) {
        self.mastery = newMastery
    }
    
    func updateQuestionGrade(question: Question, newGrade: Grade, didAnswerQuestion: Bool = true) {
        removeQuestionFromGrade(question: question)
        
        question.grade = newGrade
        
        let grade = order == .random ? newGrade : .average
        guard var targetGrade = gradeDistribution[grade] else {
            // Target grade does not exist in grade distribution
            gradeDistribution[newGrade] = [question]
            return
        }
        
        if didAnswerQuestion {
            targetGrade.append(question)
        } else {
            targetGrade.insert(question, at: 0)
        }
        gradeDistribution[grade] = targetGrade
    }
    
    func removeQuestionFromGrade(question: Question) {
        let grade = order == .random ? question.grade : .average
        guard var targetGrade = gradeDistribution[grade] else { return }
        if let index = targetGrade.index(where: { $0 == question }) {
            targetGrade.remove(at: index)
        }
        if targetGrade.isEmpty {
            gradeDistribution[grade] = nil
        } else {
            gradeDistribution[grade] = targetGrade
        }
    }
    
}
