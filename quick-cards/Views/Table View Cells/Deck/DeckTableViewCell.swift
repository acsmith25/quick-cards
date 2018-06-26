//
//  DeckTableViewCell.swift
//  quick-cards
//
//  Created by Abby Smith on 6/26/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class DeckTableViewCell: UITableViewCell {
    static let identifier = "DECK_TABLE_CELL"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
}
