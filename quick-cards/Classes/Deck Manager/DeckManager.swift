//
//  DeckManager.swift
//  MyApp
//
//  Created by Abby Smith on 6/22/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

protocol DeckManagerDelegate {
    func askQuestion(question: String)
    func showAnswer(correctAnswer: String?)
}

class DeckManager {
    var delegate: DeckManagerDelegate?
    
    var deck: Deck
    var levels: [[Card]] = []
    var currentCard: Card?
    
    var getNextCard: (() -> Card)?
    
    init(deck: Deck) {
        self.deck = deck
    }
    
    func startDeck() {
        // Creates an empty array for each level with all cards in average initially
        // [ [], [], [deck], [], [] ]
        levels = Array(repeating: [], count: Level.allCases.count)
        levels[Level.average.rawValue] = deck.cards
        
        // Calculate the sum of all level weights
        Level.allCases.forEach { totalWeight += $0.weight }
        
        // Initiailize next card function to use first pass function
        getNextCard = getNextCardFromFirstPass
        
        next()
    }
    
    func next() {
        if let getNextCard = getNextCard {
            currentCard = getNextCard()
        }
        delegate?.askQuestion(question: "\(currentCard!.question)")
    }
    
    func validate(userAnswer: String?) {
        let didAnswerCorrectly = userAnswer == currentCard?.answer ? true : false
        if didAnswerCorrectly {
            increaseLevel()
        } else {
            decreaseLevel()
        }
        delegate?.showAnswer(correctAnswer: currentCard?.answer)
    }
    
    func calculateMastery() -> Double {
        let total = deck.cards.count * 4
        var current = 0
        levels.enumerated().forEach {
            current += $0.element.count * $0.offset
        }
        print(levels)
        return Double(current) / Double(total) * 100
    }
    
    // MARK: - Private
    
    private var totalWeight: Int = 0
    
    private func getNextCardFromFirstPass() -> Card {
        var defaultLevel = levels[Level.average.rawValue]
        guard let randomCard = defaultLevel.removeElementAtRandomIndex() else {
            // First pass complete
            // Update get next card function to use random function
            self.getNextCard = getRandomCard
            return getRandomCard()
        }
        return randomCard
    }
    
    private func getRandomCard() -> Card {
        guard let randomLevel = getRandomWeightedLevel() else {
            fatalError("Error getting random level.")
        }
        guard let randomCard = levels[randomLevel.rawValue].removeElementAtRandomIndex() else {
            return getRandomCard()
        }
        return randomCard
    }
    
    private func getRandomWeightedLevel() -> Level? {
        // Get random weight from the summ of all level weights
        var randomWeight = Int(arc4random_uniform(UInt32(totalWeight + 1)))
        
        // Get level of random weight by subtracting weight of current level until <= 0
        for level in Level.allCases.reversed() {
            randomWeight = randomWeight - level.weight
            if randomWeight <= 0 {
                return level
            }
        }
        return nil
    }
    
    private func increaseLevel() {
        guard var currentCard = currentCard else { return }
        let newLevel = currentCard.level.rawValue + 1
        guard newLevel < Level.allCases.count else {
            // Already at heighest level, add card back to top level
            levels[newLevel - 1].append(currentCard)
            return
        }
        // Update card's level
        guard let level = Level(rawValue: newLevel) else {
            fatalError("Error increasing card's level")
        }
        currentCard.level = level
        levels[newLevel].append(currentCard)
    }
    
    private func decreaseLevel() {
        guard var currentCard = currentCard else { return }
        let newLevel = currentCard.level.rawValue - 1
        guard newLevel >= 0 else {
            // Already at lowest level, add card back to bottom level
            levels[newLevel + 1].append(currentCard)
            return
        }
        // Update card's level
        guard let level = Level(rawValue: newLevel) else {
            fatalError("Error decreasing card's level")
        }
        currentCard.level = level
        levels[newLevel].append(currentCard)
    }

}

