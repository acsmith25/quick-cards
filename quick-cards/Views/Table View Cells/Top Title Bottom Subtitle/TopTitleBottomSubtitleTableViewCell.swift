//
//  QuestionAnswerTableViewCell.swift
//  quick-cards
//
//  Created by Abby Smith on 7/19/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class TopTitleBottomSubtitleTableViewCell: UITableViewCell {
    static let identifier = "QUESTION_ANSWER_CELL "
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(question: String, answer: String) {
        questionLabel.text = question
        answerLabel.text = answer
    }
}
