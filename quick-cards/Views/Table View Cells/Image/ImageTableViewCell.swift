//
//  ImageTableViewCell.swift
//  quick-cards
//
//  Created by Abby Smith on 6/25/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    static let identifier = "IMAGE_CELL"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBAction func didTapButtonAction(sender: AnyObject) {
        if let action = action {
            action()
        }
    }
    
    var action: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with title: String, image: UIImage?, color: UIColor, action: (() -> Void)? = nil) {
        self.action = action
        self.button.backgroundColor = color
        self.iconImageView.image = image
        self.titleLabel.text = title
    }
    
}
