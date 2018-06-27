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
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set separator color to native table view color
        let tempTableView = UITableView()
        let separatorColor = tempTableView.separatorColor
        separatorView.backgroundColor = separatorColor
        
        // Set separator to one pixel on any scale
        separatorHeightConstraint.constant = 1.0 / UIScreen.main.nativeScale
    }
    
    func configure(with title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
}
