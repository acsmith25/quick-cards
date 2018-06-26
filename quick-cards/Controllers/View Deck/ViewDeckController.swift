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

    @IBOutlet weak var giveUpButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var continueButtonCenter: NSLayoutConstraint!
    @IBOutlet weak var cardViewCenter: NSLayoutConstraint!
    @IBOutlet weak var answerFieldCenter: NSLayoutConstraint!
    @IBOutlet weak var giveUpButtonCenter: NSLayoutConstraint!
    
    
    enum ViewState {
        case initial
        case asking(String)
        case correct
        case incorrect(String)
        case mastered
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
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        deckManager.delegate = self
        setViewState(.initial)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cardViewCenter.constant += view.bounds.width
//        answerFieldCenter.constant += view.bounds.width
//        giveUpButtonCenter.constant += view.bounds.width
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func continueButtonAction(_ sender: Any) {
        switch viewState {
        case .initial:
            // Start deck
            self.cardViewCenter.constant -= self.view.bounds.width
//            self.answerFieldCenter.constant -= self.view.bounds.width
//            self.giveUpButtonCenter.constant -= self.view.bounds.width
            deckManager.startDeck()
        case .asking(_):
            // Submit
            deckManager.validate(userAnswer: answerTextField.text)
        case .correct, .incorrect(_):
            // Go to next card
            deckManager.next()
        case .mastered:
            // Exit
            delegate?.dismissViewController()
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
            giveUpButton.alpha = 0.0
            answerTextField.alpha = 0.0
        case .asking(let question):
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.continueButton.setTitle("Submit", for: .normal)
                self.questionLabel.text = question
                
                self.view.layoutIfNeeded()
                
                self.answerTextField.alpha = 1.0
                self.giveUpButton.alpha = 1.0
            }, completion: nil)
        case .correct:
            self.answerTextField.endEditing(false)
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Next Question", for: .normal)
                self.questionLabel.text = "Correct!"
                self.answerTextField.text = ""
                
                self.answerTextField.alpha = 0.0
                self.giveUpButton.alpha = 0.0
            }
        case .incorrect(let correctAnswer):
            self.answerTextField.endEditing(false)
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Next Question", for: .normal)
                self.questionLabel.text = "Wrong: \(correctAnswer)"
                self.answerTextField.text = ""
                
                self.answerTextField.alpha = 0.0
                self.giveUpButton.alpha = 0.0
            }
        case .mastered:
            self.answerTextField.endEditing(false)
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Done", for: .normal)
                self.questionLabel.text = "Congratulations!\nYou have mastered this deck."
                self.answerTextField.text = ""
                
                self.answerTextField.alpha = 0.0
                self.giveUpButton.alpha = 0.0
            }
        }
    }
}

// MARK: - Card Deck Delegate
extension ViewDeckController: DeckManagerDelegate {
    
    func masteredDeck() {
        setViewState(.mastered)
    }
    
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
