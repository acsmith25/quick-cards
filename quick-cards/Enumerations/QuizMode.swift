//
//  QuizMode.swift
//  quick-cards
//
//  Created by Abby Smith on 7/6/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

enum QuizMode {
    case showAnswer
    case typeAnswer
    case multipleChoice
    case grid
    
    static let allModes: [QuizMode] = [.showAnswer, .typeAnswer, .multipleChoice, .grid]
    
    var title: String {
        switch self {
        case .showAnswer:
            return "Show Answer"
        case .typeAnswer:
            return "Type Answer"
        case .multipleChoice:
            return "Multiple Choice"
        case .grid:
            return "Grid"
        }
    }
    
    func getController(with deck: Deck) -> QuizModeController {
        switch self {
        default:
            return TypeAnswerViewController(deck: deck)
        }
    }
}
