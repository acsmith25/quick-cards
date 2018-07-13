//
//  GenericCell.swift
//  quick-cards
//
//  Created by Abby Smith on 6/25/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

enum GenericSection: String {
    case newDeck = "New Deck"
    case startDeck = "Start a Deck"
    case quickResume = "Quick Resume"
    
    var icon: UIImage? {
        switch self {
        case .newDeck:
            return UIImage(named: "pencilPaperIcon")
        case .startDeck:
            return UIImage(named: "bookshelfIcon")
        default:
            return UIImage()
        }
    }
    
    var color: UIColor {
        switch self {
//        case .newDeck:
//            return UIColor(red: 255.0/255.0, green: 191.0/255.0, blue: 0/255.0, alpha: 1)
//        case .startDeck:
//            return UIColor(red: 254.0/255.0, green: 74.0/255.0, blue: 73.0/255.0, alpha: 1)
//        case .allDecks:
//            return UIColor(red: 0/255.0, green: 159.0/255.0, blue: 183.0/255.0, alpha: 1)
        default:
            return .myTeal
        }
    }
    
    var rows: Int {
        switch self {
        case .quickResume:
            return decksInProgress.count
        default:
            return 1
        }
    }
}
