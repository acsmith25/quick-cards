//
//  DetailsViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/24/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var seenLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var question: Question
    
    var delegate: NavigationDelegate?
    
    init(question: Question) {
        self.question = question
        super.init(nibName: String(describing: DetailsViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        seenLabel.text = "\(question.seen)"
        correctLabel.text = "\(question.correct)"
        timeLabel.text = String(format: "%.2f", question.avgTime) + " seconds"
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
}
