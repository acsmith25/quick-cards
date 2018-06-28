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
    func masteredDeck()
}

class DeckManager {
    
    // MARK: - Public
    
    var delegate: DeckManagerDelegate?
    
    var deck: Deck
    var levels: [[Card]] = []
    var currentCard: Card?
    
    var getNextCard: (() -> Card)?
    
    init(deck: Deck) {
        self.deck = deck
    }
    
    func startDeck() {
        // Creates an empty array for each level with all cards in their respective level (average for new decks)
        // [ [], [], [deck], [], [] ]
        levels = Array(repeating: [], count: Level.allCases.count)
        deck.cards.forEach { (card) in
            levels[card.level.rawValue].append(card)
            currentMastery += card.level.rawValue
        }
        
        // Calculate the sum of all level weights
        Level.allCases.forEach { levelWeightsSum += $0.weight }
        
        // The sum for when all levels are mastered
        totalMastery = deck.cards.count * Level.mastered.rawValue
        
        // Initiailize next card function to use first pass function
        getNextCard = getNextCardFromFirstPass
        
        // Get first card
        next()
    }
    
    func next() {
        if let getNextCard = getNextCard {
            currentCard = getNextCard()
        }
        guard let currentCard = currentCard else { return }
        delegate?.askQuestion(question: "\(currentCard.question)")
    }
    
    func validate(userAnswer: String?) {
        let didAnswerCorrectly = userAnswer == currentCard?.answer ? true : false
        if didAnswerCorrectly {
            increaseLevel()
            if currentMastery == totalMastery {
                // Deck is mastered
                delegate?.masteredDeck()
            } else {
                // Continue
                delegate?.showAnswer(correctAnswer: nil)
            }
        } else {
            // Continue
            decreaseLevel()
            delegate?.showAnswer(correctAnswer: currentCard?.answer)
        }
        saveMastery()
        print("Current mastery: \(deck.mastery)")
    }
    
    func saveMastery() {
        deck.mastery = round(Double(currentMastery) / Double(totalMastery) * 10000) / 100
    }
    
    // MARK: - Private
    
    private var levelWeightsSum: Int = 0
    private var totalMastery: Int = 0
    private var currentMastery: Int = 0
    
    private func getNextCardFromFirstPass() -> Card {
        var defaultLevel = levels[Level.average.rawValue]
        guard let randomIndex = getRandomIndex(defaultLevel) else {
            // First pass complete
            // Update get next card function to use random function
            self.getNextCard = getRandomCard
            return getRandomCard()
        }
        // Extract card at random index
        let card = defaultLevel.remove(at: randomIndex)
        levels[Level.average.rawValue] = defaultLevel
        return card
    }
    
    private func getRandomCard() -> Card {
        guard let randomLevel = getRandomWeightedLevel() else {
            fatalError("Error getting random level.")
        }
        guard let randomIndex = getRandomIndex(levels[randomLevel.rawValue]) else {
            return getRandomCard()
        }
        return levels[randomLevel.rawValue].remove(at: randomIndex)
    }
    
    private func getRandomWeightedLevel() -> Level? {
        // Get random weight from the summ of all level weights
        var randomWeight = Int(arc4random_uniform(UInt32(levelWeightsSum + 1)))
        
        // Get level of random weight by subtracting weight of current level until <= 0
        for level in Level.allCases.reversed() {
            randomWeight = randomWeight - level.weight
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
        guard let currentCard = currentCard else { return }
        let newLevel = currentCard.level.rawValue + 1
        guard newLevel < Level.allCases.count else {
            // Already at heighest level, insert card back into top level
            levels[newLevel - 1].append(currentCard)
            return
        }
        // Update card's level
        guard let level = Level(rawValue: newLevel) else {
            fatalError("Error increasing card's level")
        }
        // Reinsert card at new level and update mastery
        currentMastery += 1
        currentCard.level = level
        levels[newLevel].append(currentCard)
    }
    
    private func decreaseLevel() {
        guard let currentCard = currentCard else { return }
        let newLevel = currentCard.level.rawValue - 1
        guard newLevel >= 0 else {
            // Already at lowest level, insert card back into bottom level
            levels[newLevel + 1].append(currentCard)
            return
        }
        // Update card's level
        guard let level = Level(rawValue: newLevel) else {
            fatalError("Error decreasing card's level")
        }
        // Reinsert card at new level and update mastery
        currentMastery -= 1
        currentCard.level = level
        levels[newLevel].append(currentCard)
    }

}

