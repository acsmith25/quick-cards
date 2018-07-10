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
    var delegate: NavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deck = Deck(title: "New Deck", cards: [:])
        setViewState(.initial)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapNextButton(_ sender: Any) {
        switch viewState {
        case .initial:
            self.questionTextField.endEditing(true)
            
            let title = questionTextField.text ?? ""
            deck?.title = title
            
            setViewState(.enterCard)
        case .enterCard:
            self.answerTextField.endEditing(true)
            self.questionTextField.endEditing(true)
            
            let question = questionTextField.text ?? ""
            let answer = answerTextField.text ?? ""
            deck?.addCard(question: question, answer: answer)
            
            setViewState(.submitted)
        case .submitted:
            setViewState(.enterCard)
        }
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        if let deck = deck {
            allDecks.append(deck)
            userDecks.append(deck)
            DeckSaver.saveDecks(decks: allDecks, key: allDecksKey)
            DeckSaver.saveDecks(decks: userDecks, key: allDecksKey)
        }
        delegate?.dismissViewController()
    }
}

// MARK: - View State
extension NewDeckViewController {
    
    private func setViewState(_ viewState: ViewState) {
        self.viewState = viewState
        switch viewState {
        case .initial:
            self.continueButton.setTitle("Save Title", for: .normal)
            self.questionLabel.text = "Title:"
            
            self.doneButton.alpha = 0
            self.answerTextField.alpha = 0
            self.answerLabel.alpha = 0
        case .enterCard:
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.continueButton.setTitle("Save", for: .normal)
                self.questionLabel.text = "Question:"
                self.questionTextField.text = ""
                
                self.questionTextField.alpha = 1
                self.questionLabel.alpha = 1
                self.answerTextField.alpha = 1
                self.answerLabel.alpha = 1
                self.doneButton.alpha = 0
            }, completion: nil)
        case .submitted:
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.continueButton.setTitle("Add Another", for: .normal)
                self.answerTextField.text = ""
                self.questionTextField.text = ""
                
                self.doneButton.alpha = 1
                self.answerTextField.alpha = 0
                self.answerLabel.alpha = 0
                self.questionTextField.alpha = 0
                self.questionLabel.alpha = 0
            }, completion: nil)
        }
    }

}
