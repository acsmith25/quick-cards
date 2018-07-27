//
//  FullScreenCardViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/27/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit
import CustomPopup

class FullScreenCardViewController: UIViewController {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var wrongButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var question: Question
    var answer: Answer
    var isShowingFront: Bool
    var completion: (Bool) -> Void
    
    var delegate: PopUpPresentationController?
    
    init(question: Question, answer: Answer, isShowingFront: Bool = true, completion: @escaping (Bool) -> Void) {
        self.question = question
        self.answer = answer
        self.isShowingFront = isShowingFront
        self.completion = completion
        super.init(nibName: String(describing: FullScreenCardViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cardGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        cardView.addGestureRecognizer(cardGesture)
        
        if isShowingFront {
            questionLabel.text = question.question
            rightButton.isHidden = true
            wrongButton.isHidden = true
        } else {
            questionLabel.text = answer.answer
            rightButton.isHidden = false
            wrongButton.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    @objc func flipCard() {
        if isShowingFront {
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.questionLabel.text = self.answer.answer
                self.rightButton.isHidden = false
                self.wrongButton.isHidden = false
            }, completion: nil)
            isShowingFront = false
        } else {
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.questionLabel.text = self.question.question
                self.rightButton.isHidden = true
                self.wrongButton.isHidden = true
            }, completion: nil)
            isShowingFront = true
        }
    }
    
    @IBAction func rightAction(_ sender: Any) {
        delegate?.dismissPopUp()
        completion(true)
    }
    
    @IBAction func wrongAction(_ sender: Any) {
        delegate?.dismissPopUp()
        completion(false)
    }
}
