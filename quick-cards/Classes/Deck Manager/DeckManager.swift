//
//  DeckManager.swift
//  MyApp
//
//  Created by Abby Smith on 6/22/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

protocol DeckManagerDelegate {
    func showQuestion(question: Question, randomAnswers: [Answer])
    func showAnswer(answer: Answer, isCorrect: Bool?)
    func showComplete()
}

class DeckManager {
    
    // MARK: - Properties
    
    var delegate: DeckManagerDelegate?
    var deck: Deck
    
    var currentQuestion: Question?
    
    private var currentMastery: Int = 0
    private var totalMastery: Int = 0
    private var startTime: Date = Date()
    
    private var getNextQuestion: (() -> Question?)?
    
    // MARK: - Public Methods
    
    init(deck: Deck) {
        self.deck = deck
    }
    
    func startDeck() {
        // Calculate the current mastery of the deck
        deck.gradeDistribution.forEach { (grade, questions) in
            currentMastery += grade.masteryValue * questions.count
        }
        
        // The sum for when all grades are mastered
        totalMastery = deck.cards.count * Grade.mastered.masteryValue
        
        if deck.order == .random {
            getNextQuestion = deck.hasCompletedFirstPass ? getRandomQuestion : getAverageQuestion
        } else {
            getNextQuestion = getAverageQuestion
        }
        
        next()
    }
    
    func exit() {
        guard let currentQuestion = currentQuestion else { return }
        deck.updateQuestionGrade(question: currentQuestion, newGrade: currentQuestion.grade, didAnswerQuestion: false)
    }
    
    func next() {
        // Completed pass through deck, sort and restart
        if deck.cards.count == deck.progressCounter {
            deck.sortQuestions(by: deck.order)
        }
        
        guard let getNextQuestion = getNextQuestion else { return }
        guard let question = getNextQuestion() else {
            // Deck is empty
            return
        }
        self.currentQuestion = question
        
        // Start time and update progress when question is displayed
        startTime = Date()
        deck.progressCounter += 1
        
        if deck.quizMode == .multipleChoice {
            // Only ask with random answers if multiple choice
            askWithRandomAnswers()
            return
        }
        delegate?.showQuestion(question: currentQuestion!, randomAnswers: []) // Question is safely unwrapped
    }
    
    func showAnswer(isCorrect: Bool? = nil) {
        guard let currentQuestion = currentQuestion else { return }
        guard let correctAnswer = deck.cards[currentQuestion] else {
            fatalError("Question does not exist.")
        }
        
        if currentMastery == totalMastery {
            // Deck is mastered
            delegate?.showComplete()
        } else {
            delegate?.showAnswer(answer: correctAnswer, isCorrect: isCorrect)
        }
    }
    
    func giveUp() {
        guard let currentQuestion = currentQuestion else { return }
        guard let correctAnswer = deck.cards[currentQuestion] else {
            fatalError("Question does not exist.")
        }
        
        incorrect()
        delegate?.showAnswer(answer: correctAnswer, isCorrect: false)
    }
    
    func correct() {
        updateDeck(didAnswerCorrectly: true)
        updateMastery()
        self.currentQuestion = nil
    }
    
    func incorrect() {
        updateDeck(didAnswerCorrectly: false)
        updateMastery()
        self.currentQuestion = nil
    }
    
    func validate(userAnswer: String?) {
        guard let currentQuestion = currentQuestion else { return }
        guard let correctAnswer = deck.cards[currentQuestion] else {
            fatalError("Question does not exist.")
        }
        
        // Validate
        let didAnswerCorrectly = userAnswer == correctAnswer.answer ? true : false
        
        updateDeck(didAnswerCorrectly: didAnswerCorrectly)
        updateMastery()
        showAnswer(isCorrect: didAnswerCorrectly)
        
        self.currentQuestion = nil
    }
    

    
    func updateTime() {
        guard let currentQuestion = currentQuestion else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        currentQuestion.updateTime(newTime: elapsed)
    }
    
    // MARK: - Private Methods
    
    private func askWithRandomAnswers() {
        guard let currentQuestion = currentQuestion else { return }
        guard let correctAnswer = deck.cards[currentQuestion] else { return }
        
        var randomAnswers = [correctAnswer]
        while randomAnswers.count < 4 {
            guard let index = getRandomIndex(deck.answers) else { return }
            let answer = deck.answers[index]
            
            // Excludes duplicates
            if !randomAnswers.contains(where: { $0 == answer }) {
                randomAnswers.append(answer)
            }
        }
        delegate?.showQuestion(question: currentQuestion, randomAnswers: randomAnswers)
    }
    
    private func updateDeck(didAnswerCorrectly: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        var newGrade = Grade.average
        
        // Update distribution if random
        if deck.order == .random {
            let newGradeValue = didAnswerCorrectly ? currentQuestion.grade.masteryValue + 1 : currentQuestion.grade.masteryValue - 1
            if didAnswerCorrectly {
                if newGradeValue >= Grade.allCases.count {
                    // Already at heighest level, insert card back into top level
                    newGrade = Grade(masteryValue: newGradeValue - 1)
                }
            } else {
                if newGradeValue < 0 {
                    // Already at lowest level, insert card back into bottom level
                    newGrade = Grade(masteryValue: newGradeValue + 1)
                }
            }
            newGrade = Grade(masteryValue: newGradeValue)
        }
        
        deck.updateQuestionGrade(question: currentQuestion, newGrade: newGrade)
        currentQuestion.seen += 1
        if didAnswerCorrectly {
            currentQuestion.correct += 1
            currentMastery += 1
        } else {
            currentMastery -= 1
        }
    }
    
    private func updateMastery() {
        deck.updateMastery(newMastery: round(Double(currentMastery) / Double(totalMastery) * 10000) / 100)
    }
    
    private func getAverageQuestion() -> Question? {
        guard var targetGrade = deck.gradeDistribution[.average], let randomIndex = getRandomIndex(targetGrade) else {
            deck.hasCompletedFirstPass = true
            getNextQuestion = getRandomQuestion
            return getRandomQuestion()
        }
        
        // Get card from front of level unless random
        var index = 0
        if deck.order == .random {
            index = randomIndex
        }
        
        let question = targetGrade[index]
        deck.removeQuestionFromGrade(question: question)
        return question
    } 
    
    private func getRandomQuestion() -> Question? {
        guard let randomGrade = getRandomWeightedGrade() else {
            fatalError("Error getting random level.")
        }
        guard var targetGrade = deck.gradeDistribution[randomGrade], let randomIndex = getRandomIndex(targetGrade) else {
            // Target grade is empty
            return getRandomQuestion()
        }
        
        let question = targetGrade[randomIndex]
        deck.removeQuestionFromGrade(question: question)
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
}

