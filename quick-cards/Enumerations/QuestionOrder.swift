//
//  Order.swift
//  quick-cards
//
//  Created by Abby Smith on 7/26/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

enum QuestionOrder: Int, Codable {
    case random = 0
    case inOrder = 1
    case difficulty = 2
}
