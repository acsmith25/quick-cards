//
//  DeckManager.swift
//  MyApp
//
//  Created by Abby Smith on 6/22/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

protocol DeckManagerDelegate {
    func askQuestion(question: Question, wrongAnswers: [Answer])
    func showAnswer(answer: Answer, isCorrect: Bool)
    func masteredDeck()
}

class DeckManager {
    
    // MARK: - Public
    
    public var delegate: DeckManagerDelegate?
    public var deck: Deck
    public var currentQuestion: Question?
    
    private var getNextQuestion: (() -> Question?)?
    
    init(deck: Deck) {
        self.deck = deck
    }
    
    func startFromBeginning() {
        getNextQuestion = getNextQuestionFromFirstPass
        deck.reset()
        startDeck()
    }
    
    func startDeck() {
        deck.gradeDistribution.forEach { (grade, questions) in
            currentMastery += grade.masteryValue * questions.count
        }
        
        // Calculate the sum of all grade weights
//        Grade.allCases.forEach { gradeWeightsSum += $0.distributionWeight }
        
        // The sum for when all grades are mastered
        totalMastery = deck.cards.count * Grade.mastered.masteryValue
        
        // Initiailize next card function to use first pass function
        getNextQuestion = deck.hasCompletedFirstPass ? getRandomQuestion : getNextQuestionFromFirstPass
        
        // Get first card
        next()
    }
    
    func next() {
        if let getNextQuestion = getNextQuestion {
            guard let question = getNextQuestion() else {
                // Deck is empty
                return
            }
            currentQuestion = question
        }
        guard let currentQuestion = currentQuestion else { return }
        
        guard let vc = delegate as? MultipleChoiceViewController else {
            delegate?.askQuestion(question: currentQuestion, wrongAnswers: [])
            return
        }
        askWithRandomAnswers(vc: vc)
    }
    
    func askWithRandomAnswers(vc: MultipleChoiceViewController) {
        guard let currentQuestion = currentQuestion else { return }
        guard let correctAnswer = deck.cards[currentQuestion] else { return }
        var randomAnswers = [correctAnswer]
        while randomAnswers.count < 4 {
            guard let index = getRandomIndex(deck.answers) else { return }
            let answer = deck.answers[index]
            if !randomAnswers.contains(where: { $0 == answer }) {
                randomAnswers.append(answer)
            }
        }
        vc.askQuestion(question: currentQuestion, wrongAnswers: randomAnswers)
    }
    
    func exit() {
        guard let currentQuestion = currentQuestion else { return }
        deck.updateQuestionGrade(question: currentQuestion, grade: currentQuestion.grade)
    }
    
    func incorrect() {
        guard let currentQuestion = currentQuestion else { return }
        guard let correctAnswer = deck.cards[currentQuestion] else {
            fatalError("Question does not exist.")
        }

        decreaseLevel()
        delegate?.showAnswer(answer: correctAnswer, isCorrect: false)
        
        saveMastery()
        self.currentQuestion = nil
        print("Current mastery: \(deck.mastery)")
    }
    
    func correct() {
        guard let currentQuestion = currentQuestion else { return }
        guard let correctAnswer = deck.cards[currentQuestion] else {
            fatalError("Question does not exist.")
        }
        
        increaseLevel()
        if currentMastery == totalMastery {
            // Deck is mastered
            delegate?.masteredDeck()
        } else {
            // Continue
            delegate?.showAnswer(answer: correctAnswer, isCorrect: true)
        }
        
        saveMastery()
        self.currentQuestion = nil
        print("Current mastery: \(deck.mastery)")
    }
    
    func validate(userAnswer: String?) {
        guard let currentQuestion = currentQuestion else { return }
        guard let correctAnswer = deck.cards[currentQuestion] else {
            fatalError("Question does not exist.")
        }
        let didAnswerCorrectly = userAnswer == correctAnswer.answer ? true : false
        if didAnswerCorrectly {
            correct()
        } else {
            incorrect()
        }
    }
    
    func saveMastery() {
        deck.mastery = round(Double(currentMastery) / Double(totalMastery) * 10000) / 100
    }
    
    // MARK: - Private
    
//    private var gradeWeightsSum: Int = 0
    private var totalMastery: Int = 0
    private var currentMastery: Int = 0
    
    private func getNextQuestionFromFirstPass() -> Question? {
        guard var defaultGrade = deck.gradeDistribution[.average] else { return nil }
        guard let randomIndex = getRandomIndex(defaultGrade) else {
            // First pass complete
            // Update get next card function to use random function
//            deck.hasCompletedFirstPass = true
//            self.getNextQuestion = getRandomQuestion
//            return getRandomQuestion()
            return nil
        }
        // Extract card at random index
        let question = defaultGrade.remove(at: randomIndex)
        if defaultGrade.isEmpty {
            deck.gradeDistribution[.average] = nil
            deck.hasCompletedFirstPass = true
            self.getNextQuestion = getRandomQuestion
            return getRandomQuestion()
        } else {
            deck.gradeDistribution[.average] = defaultGrade
        }
        return question
    } 
    
    private func getRandomQuestion() -> Question? {
        guard let randomLevel = getRandomWeightedGrade() else {
            fatalError("Error getting random level.")
        }
        guard var cards = deck.gradeDistribution[randomLevel] else {
            fatalError("Error getting random level.")
        }
        guard let randomIndex = getRandomIndex(cards) else {
            return getRandomQuestion()
        }
        print(deck.gradeDistribution)
        let question = cards.remove(at: randomIndex)
        if cards.isEmpty {
            deck.gradeDistribution[randomLevel] = nil
        } else {
            deck.gradeDistribution[randomLevel] = cards
        }
        return question
    }
    
    private func getRandomWeightedGrade() -> Grade? {
        // Get random weight from the summ of all level weights
        var gradeWeightsSum = 0
        deck.gradeDistribution.keys.forEach { gradeWeightsSum += $0.distributionWeight }
        var randomWeight = Int(arc4random_uniform(UInt32(gradeWeightsSum + 1)))
        
        // Get level of random weight by subtracting weight of current level until <= 0
        for level in deck.gradeDistribution.keys.reversed() {
            randomWeight = randomWeight - level.distributionWeight
            if randomWeight <= 0 {
                return level
            }
        }
        return nil
    }
    
    private func getRandomIndex(_ array: Array<Any>) -> Int? {
        guard !array.isEmpty else {
            return nil
        }
        return Int(arc4random_uniform(UInt32(array.count)))
    }
    
    private func increaseLevel() {
        guard let currentQuestion = currentQuestion else { return }
        currentQuestion.seen += 1
        let newGrade = currentQuestion.grade.masteryValue + 1
        guard newGrade < Grade.allCases.count else {
            // Already at heighest level, insert card back into top level
            let grade = Grade(masteryValue: newGrade - 1)
            currentQuestion.correct += 1
            deck.updateQuestionGrade(question: currentQuestion, grade: grade)
            return
        }
        // Update card's level
        let grade = Grade(masteryValue: newGrade)
        currentQuestion.correct += 1
        deck.updateQuestionGrade(question: currentQuestion, grade: grade)
        currentMastery += 1
    }
    
    private func decreaseLevel() {
        guard let currentQuestion = currentQuestion else { return }
        currentQuestion.seen += 1
        let newGrade = currentQuestion.grade.masteryValue - 1
        guard newGrade >= 0 else {
            // Already at lowest level, insert card back into bottom level
            let grade = Grade(masteryValue: newGrade + 1)
            deck.updateQuestionGrade(question: currentQuestion, grade: grade)
            return
        }
        // Update card's level
        let grade = Grade(masteryValue: newGrade)
        deck.updateQuestionGrade(question: currentQuestion, grade: grade)
        currentMastery -= 1
    }

}

