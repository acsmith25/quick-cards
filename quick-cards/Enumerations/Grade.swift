//
//  MasteryLevel.swift
//  MyApp
//
//  Created by Abby Smith on 6/22/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

enum Grade: Int, Codable {
    case failed = 0
    case belowAverage = 1
    case average = 2
    case aboveAverage = 3
    case mastered = 4
    
    static let allCases: [Grade] = [.failed, .belowAverage, .average, .aboveAverage, .mastered]
    
    init(masteryValue: Int) {
        switch masteryValue {
        case 0:
            self = .failed
        case 1:
            self = .belowAverage
        case 2:
            self = .average
        case 3:
            self = .aboveAverage
        case 4:
            self = .mastered
        default:
            self = .average
        }
    }
    
    var distributionWeight: Int {
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
    
    var masteryValue: Int {
        switch self {
        case .failed:
            return 0
        case .belowAverage:
            return 1
        case .average:
            return 2
        case .aboveAverage:
            return 3
        case .mastered:
            return 4
        }
    }
}


