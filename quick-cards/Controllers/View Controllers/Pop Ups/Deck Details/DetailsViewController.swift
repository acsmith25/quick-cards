//
//  DetailsViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/24/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var seenLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    
    var question: Question
    var answer: Answer
    
    var delegate: NavigationDelegate?
    
    init(question: Question, answer: Answer) {
        self.question = question
        self.answer = answer
        super.init(nibName: String(describing: DetailsViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        questionLabel.text = question.question
        answerLabel.text = answer.answer
        seenLabel.text = "\(question.seen)"
        correctLabel.text = "\(question.correct)"
    }

}
