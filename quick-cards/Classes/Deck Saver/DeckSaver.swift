//
//  DeckSaver.swift
//  quick-cards
//
//  Created by Abby Smith on 6/27/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

class DeckSaver {
    
    class func saveDecks() {
        let encoder = JSONEncoder()
        let decksData = userDecks.map { (deck) -> String? in
            do {
                let data = try encoder.encode(deck)
                return String(data: data, encoding: .utf8)
            } catch let error {
                print("Could not encode to JSON. Error: \(error)")
                return nil
            }
        }
        UserDefaults.standard.set(decksData, forKey: allDecksKey)
    }
    
    class func getDefaultDecks() -> [Deck]? {
        let decoder = JSONDecoder()
        guard let decksData = UserDefaults.standard.array(forKey: allDecksKey) as? [String] else { return nil }
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
