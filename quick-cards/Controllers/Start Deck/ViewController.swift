//
//  ViewController.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var answerTextField: UITextField!
    
    enum ViewState {
        case initial
        case asking
        case result(Bool)
    }
    
    var viewState: ViewState = .initial
    var deck: Deck?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cards: [Card] = []
        cards.append(Card(question: "One?", answer: "1"))
        cards.append(Card(question: "Two?", answer: "2"))
        cards.append(Card(question: "Three?", answer: "3"))
        cards.append(Card(question: "Four?", answer: "4"))
        cards.append(Card(question: "Five?", answer: "5"))
        cards.append(Card(question: "Six?", answer: "6"))
        cards.append(Card(question: "Seven?", answer: "7"))
        cards.append(Card(question: "Eight?", answer: "8"))
        
        let deck = Deck(cards: cards)
        deck.delegate = self
        self.deck = deck
        
        setViewState(.initial)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Actions
extension ViewController {
    
    @IBAction func startButtonAction(_ sender: Any) {
        switch viewState {
        case .initial:
            setViewState(.asking)
            deck?.startDeck()
        case .asking:
            deck?.validate(userAnswer: answerTextField.text)
        case .result(_):
            setViewState(.asking)
            deck?.next()
        }
    }
}

// MARK: - View State
extension ViewController {
    
    func setViewState(_ viewState: ViewState) {
        self.viewState = viewState
        
        switch viewState {
        case .initial:
            startButton.isHidden = false
            questionLabel.isHidden = true
            answerTextField.isHidden = true
        case .asking:
            UIView.animate(withDuration: 0.3) {
                self.questionLabel.isHidden = false
                self.answerTextField.isHidden = false
                self.startButton.isHidden = false
                self.startButton.setTitle("Submit", for: .normal)
            }
        case .result(let isCorrect):
            UIView.animate(withDuration: 0.3) {
                self.questionLabel.isHidden = false
                self.questionLabel.text = isCorrect ? "Correct!" : "Wrong"
                self.answerTextField.text = ""
                self.answerTextField.endEditing(false)
                self.answerTextField.isHidden = true
                self.startButton.isHidden = false
                self.startButton.setTitle("Next Question", for: .normal)
            }
        }
    }
}

// MARK: - Card Deck Delegate
extension ViewController: CardDeckDelegate {
    
    func showAnswer(didAnswerCorrectly: Bool) {
        setViewState(.result(didAnswerCorrectly))
    }
    
    func askQuestion(question: String) {
        questionLabel.text = question
    }
    
}
