//
//  MasteryLevel.swift
//  MyApp
//
//  Created by Abby Smith on 6/22/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

enum Level: Int {
    case failed = 0
    case belowAverage = 1
    case average = 2
    case aboveAverage = 3
    case mastered = 4
    
    static let allCases: [Level] = [.failed, .belowAverage, .average, .aboveAverage, .mastered]
    
    var weight: Int {
        switch self {
        case .failed:
            return 5
        case .belowAverage:
            return 4
        case .average:
            return 3
        case .aboveAverage:
            return 2
        case .mastered:
            return 1
        }
    }
}


