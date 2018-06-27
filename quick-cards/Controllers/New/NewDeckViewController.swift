//
//  NewDeckViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 6/27/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class NewDeckViewController: UIViewController {
    
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    private enum ViewState {
        case initial
        case enterCard
        case submitted
    }
    
    private var viewState: ViewState = .initial
    
    var deck: Deck?
    var delegate: ViewDeckControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deck = Deck(title: "New Deck", cards: [])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapNextButton(_ sender: Any) {
        switch viewState {
        case .initial:
            let title = questionTextField.text ?? ""
            
            self.questionTextField.text = ""
            self.questionTextField.endEditing(true)
            
            deck?.title = title
            set(.enterCard)
        case .enterCard:
            let question = questionTextField.text ?? ""
            let answer = answerTextField.text ?? ""
            
            self.answerTextField.text = ""
            self.questionTextField.text = ""
            self.answerTextField.endEditing(true)
            self.questionTextField.endEditing(true)
            
            let card = Card(question: question, answer: answer)
            deck?.addCard(card: card)
            set(.submitted)
        case .submitted:
            set(.enterCard)
        }

    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        delegate?.dismissViewController()
    }
}

// MARK: - View State
extension NewDeckViewController {
    
    private func set(_ viewState: ViewState) {
        self.viewState = viewState
        switch viewState {
        case .initial:
            self.questionLabel.text = "Title:"
            self.continueButton.setTitle("Save Title", for: .normal)
            self.doneButton.alpha = 0
            self.answerTextField.alpha = 0
            self.answerLabel.alpha = 0
        case .enterCard:
            self.questionLabel.text = "Question:"
            self.continueButton.setTitle("Save", for: .normal)
            self.doneButton.alpha = 0
            self.answerTextField.alpha = 1
            self.answerLabel.alpha = 1
        case .submitted:
            self.continueButton.setTitle("Add Another", for: .normal)
            self.answerTextField.alpha = 0
            self.answerLabel.alpha = 0
            self.questionTextField.alpha = 0
            self.questionLabel.alpha = 0
            self.doneButton.alpha = 1
        }
    }

}
