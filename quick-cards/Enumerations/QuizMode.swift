//
//  QuizMode.swift
//  quick-cards
//
//  Created by Abby Smith on 7/6/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

enum QuizMode: Int, Codable {
    case showAnswer = 0
    case typeAnswer = 1
    case multipleChoice = 2
    case grid = 3
    
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
            return "Freeform"
        }
    }
    
    func getController(with deck: Deck, shouldResume: Bool) -> QuizModeController {
        switch self {
        case .showAnswer:
            return ShowAnswerViewController(deck: deck)
        case .typeAnswer:
            return TypeAnswerViewController(deck: deck, shouldResume: shouldResume)
        case .multipleChoice:
            return MultipleChoiceViewController(deck: deck)
        case .grid:
            return GridViewController(deck: deck)
        }
    }
}
