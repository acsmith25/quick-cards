//
//  DeckCollectionViewCell.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class DeckCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "DECK_CELL"
    
    @IBOutlet weak var titleButton: UIButton!
    
    var deck: Deck?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleButton.isUserInteractionEnabled = false
    }

    func configure(with deck: Deck) {
        self.deck = deck
        titleButton.setTitle(deck.title, for: .normal)
    }
}
