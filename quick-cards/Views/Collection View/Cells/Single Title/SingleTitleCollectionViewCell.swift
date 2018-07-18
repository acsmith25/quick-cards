//
//  DeckCollectionViewCell.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class SingleTitleCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "DECK_COLLECTION_CELL"
    
    @IBOutlet weak var titleButton: UIButton!
    
    var isShowingFront = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleButton.isUserInteractionEnabled = false
    }

    func configure(with title: String, backgroundColor: UIColor = .white, textColor: UIColor = .black) {
        titleButton.backgroundColor = backgroundColor
        titleButton.setTitleColor(textColor, for: .normal)
        titleButton.setTitle(title, for: .normal)
    }
}
