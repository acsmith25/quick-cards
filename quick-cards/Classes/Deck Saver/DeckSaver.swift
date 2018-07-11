//
//  DeckSaver.swift
//  quick-cards
//
//  Created by Abby Smith on 6/27/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

class DeckSaver {
    
    class func saveAllDecks() {
        DeckSaver.saveDecks(decks: userDecks, key: userDecksKey)
        DeckSaver.saveDecks(decks: allDecks, key: allDecksKey)
        DeckSaver.saveDecks(decks: decksInProgress, key: decksInProgressKey)
    }
    
    class func saveDecks(decks: [Deck], key: String) {
        let encoder = JSONEncoder()
        let decksData = decks.map { (deck) -> String? in
            do {
                let data = try encoder.encode(deck)
                return String(data: data, encoding: .utf8)
            } catch let error {
                print("Could not encode to JSON. Error: \(error)")
                return nil
            }
        }
        UserDefaults.standard.set(decksData, forKey: key)
    }
    
    class func getDecks(for key: String) -> [Deck]? {
        let decoder = JSONDecoder()
        guard let decksData = UserDefaults.standard.array(forKey: key) as? [String] else { return nil }
        let decks = decksData.map({ (json) -> Deck in
            do {
                guard let data = json.data(using: .utf8) else { fatalError() }
                let deck: Deck = try decoder.decode(Deck.self, from: data)
                return deck
            } catch let error {
                print("Could not decode JSON. Error: \(error)")
                fatalError()
            }
        })
        return decks
    }
    
}
