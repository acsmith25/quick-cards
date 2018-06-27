//
//  Deck.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

struct Deck {
    var cards: [Card]
    var title: String
    var mastery: Double
    
    init(title: String, cards: [Card], mastery: Double = 50.0) {
        self.title = title
        self.cards = cards
        self.mastery = mastery
    }
    
    mutating func addCard(card: Card) {
        cards.append(card)
    }
}

