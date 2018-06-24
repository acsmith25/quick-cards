//
//  ViewController.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

protocol ViewDeckControllerDelegate {
    func dismissViewController()
}

class ViewDeckController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var startDeckTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var startDeckCenterConstraint: NSLayoutConstraint!
    
    enum ViewState {
        case initial
        case asking(String)
        case correct
        case incorrect(String)
    }
    
    var viewState: ViewState = .initial
    
    var deckManager: DeckManager
    var delegate: ViewDeckControllerDelegate?
    
    init(deck: Deck) {
        self.deckManager = DeckManager(deck: deck)
        super.init(nibName: String(describing: ViewDeckController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        deckManager.delegate = self
        setViewState(.initial)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func continueButtonAction(_ sender: Any) {
        switch viewState {
        case .initial:
            // Start deck
            deckManager.startDeck()
        case .asking(_):
            // Submit
            deckManager.validate(userAnswer: answerTextField.text)
        case .correct, .incorrect(_):
            // Go to next card
            deckManager.next()
        }
    }
    
    @IBAction func quitDeckAction(_ sender: Any) {
        let mastery = deckManager.calculateMastery()
        print("Current deck mastery: \(mastery)%")
        delegate?.dismissViewController()
    }
    
    @IBAction func giveUpAction(_ sender: Any) {
        deckManager.validate(userAnswer: nil)
    }
}


// MARK: - View State
extension ViewDeckController {
    
    func setViewState(_ viewState: ViewState) {
        self.viewState = viewState
        
        switch viewState {
        case .initial:
            continueButton.isHidden = false
            questionLabel.isHidden = true
            answerTextField.isHidden = true
        case .asking(let question):
            NSLayoutConstraint.deactivate([startDeckCenterConstraint])
            NSLayoutConstraint.activate([startDeckTopConstraint])
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.questionLabel.isHidden = false
                self.questionLabel.text = question
                self.answerTextField.isHidden = false
                self.continueButton.isHidden = false
                self.continueButton.setTitle("Submit", for: .normal)
            }
        case .correct:
            UIView.animate(withDuration: 0.3) {
                self.questionLabel.text = "Correct!"
                self.questionLabel.isHidden = false
                self.answerTextField.text = ""
                self.answerTextField.endEditing(false)
                self.answerTextField.isHidden = true
                self.continueButton.isHidden = false
                self.continueButton.setTitle("Next Question", for: .normal)
            }
        case .incorrect(let correctAnswer):
            UIView.animate(withDuration: 0.3) {
                self.questionLabel.text = "Wrong: \(correctAnswer)"
                self.questionLabel.isHidden = false
                self.answerTextField.text = ""
                self.answerTextField.endEditing(false)
                self.answerTextField.isHidden = true
                self.continueButton.isHidden = false
                self.continueButton.setTitle("Next Question", for: .normal)
            }
        }
    }
}

// MARK: - Card Deck Delegate
extension ViewDeckController: DeckManagerDelegate {
    
    func showAnswer(correctAnswer: String? = nil) {
        guard let correctAnswer = correctAnswer else {
            setViewState(.correct)
            return
        }
        setViewState(.incorrect(correctAnswer))
    }
    
    func askQuestion(question: String) {
        setViewState(.asking(question))
    }
    
}
