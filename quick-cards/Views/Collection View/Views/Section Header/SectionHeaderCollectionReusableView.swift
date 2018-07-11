//
//  SectionHeaderCollectionReusableView.swift
//  quick-cards
//
//  Created by Abby Smith on 7/11/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class SectionHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "SECTION_HEADER_REUSABLE"
    
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with title: String) {
        self.title.text = title
    }
}
