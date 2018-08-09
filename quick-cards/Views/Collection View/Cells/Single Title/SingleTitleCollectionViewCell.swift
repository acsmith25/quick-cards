//
//  DeckCollectionViewCell.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

protocol CardDelegate {
    func removeCard(question: String?)
    func cardDetails(question: String?)
}

class SingleTitleCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "DECK_COLLECTION_CELL"
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    var isShowingFront = true
    var title: String?
    
    var delegate: CardDelegate?
    
    @IBAction func removeAction(_ sender: Any) {
        delegate?.removeCard(question: title)
    }
    
    @IBAction func moreAction(_ sender: Any) {
        delegate?.cardDetails(question: title)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleButton.isUserInteractionEnabled = false
        titleButton.layer.cornerRadius = 10.0
        closeButton.layer.cornerRadius = closeButton.bounds.size.width / 2.0
    }

    func configure(with title: String? = nil, backgroundColor: UIColor = .white, textColor: UIColor = .black, showCardDetails: Bool = false, isInDeleteMode: Bool = false) {
        if let _ = title {
            self.title = title
            titleButton.setTitle(title, for: .normal)
        }
        titleButton.backgroundColor = backgroundColor
        titleButton.setTitleColor(textColor, for: .normal)
        
        if isInDeleteMode {
            moreButton.isHidden = true
            closeButton.isHidden = false
            topConstraint.constant = 10
            bottomConstraint.constant = 10
            leadingConstraint.constant = 10
            trailingConstraint.constant = 10
        } else {
            if showCardDetails {
                moreButton.isHidden = false
            } else {
                moreButton.isHidden = true
            }
            closeButton.isHidden = true
            topConstraint.constant = 0
            bottomConstraint.constant = 0
            leadingConstraint.constant = 0
            trailingConstraint.constant = 0
        }
    }
    
    override func dragStateDidChange(_ dragState: UICollectionViewCellDragState) {
        switch dragState {
        case .none:
            moreButton.isHidden = true
            closeButton.isHidden = false
            topConstraint.constant = 10
            bottomConstraint.constant = 10
            leadingConstraint.constant = 10
            trailingConstraint.constant = 10
        case .lifting:
            moreButton.isHidden = true
            closeButton.isHidden = true
            topConstraint.constant = 0
            bottomConstraint.constant = 0
            leadingConstraint.constant = 0
            trailingConstraint.constant = 0
        default:
            return
        }
    }
}
