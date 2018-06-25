//
//  ButtonTableViewCell.swift
//  quick-cards
//
//  Created by Abby Smith on 6/25/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    static let identifier = "BUTTON_CELL"
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func didTapButtonAction(sender: AnyObject) {
        if let action = action {
            action()
        }
    }
    
    var action: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with title: String, action: (() -> Void)? = nil) {
        self.action = action
        button.setTitle(title, for: .normal)
    }
    
}
