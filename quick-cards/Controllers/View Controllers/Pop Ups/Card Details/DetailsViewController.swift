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
    @IBOutlet weak var timeView: UIView!
    
    var question: Question
    var isTimed: Bool?
    
    var delegate: NavigationDelegate?
    
    init(question: Question, isTimed: Bool?) {
        self.question = question
        self.isTimed = isTimed
        super.init(nibName: String(describing: DetailsViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        seenLabel.text = "\(question.seen)"
        correctLabel.text = "\(question.correct)"
        
        if isTimed == true {
            timeLabel.text = String(format: "%.2f", question.avgTime) + " seconds"
        } else {
            timeView.isHidden = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
}
