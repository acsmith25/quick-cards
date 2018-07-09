//
//  TypeAnswerViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/6/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

protocol QuizModeController {
    var delegate: NavigationDelegate? { get set }
}

class TypeAnswerViewController: UIViewController, QuizModeController {
    
    @IBOutlet weak var giveUpButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var continueButtonCenter: NSLayoutConstraint!
    @IBOutlet weak var cardViewCenter: NSLayoutConstraint!
    @IBOutlet weak var answerFieldCenter: NSLayoutConstraint!
    @IBOutlet weak var giveUpButtonCenter: NSLayoutConstraint!
    
    
    private enum ViewState {
        case asking(String?)
        case correct
        case incorrect(String)
        case mastered
    }
    
    private var viewState: ViewState = .asking(nil)
    
    var deckManager: DeckManager
    var shouldResume: Bool
    var delegate: NavigationDelegate?
    
    init(deck: Deck, shouldResume: Bool) {
        self.deckManager = DeckManager(deck: deck)
        self.shouldResume = shouldResume
        super.init(nibName: String(describing: TypeAnswerViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.imageView?.tintColor = GenericSection.quickResume.color
        navigationController?.navigationBar.isHidden = true
        //        navigationController?.navigationBar.prefersLargeTitles = false
        
        deckManager.delegate = self
        if shouldResume { deckManager.startDeck() }
        else { deckManager.startFromBeginning() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        cardViewCenter.constant += view.bounds.width
        //        answerFieldCenter.constant += view.bounds.width
        //        giveUpButtonCenter.constant += view.bounds.width
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func continueButtonAction(_ sender: Any) {
        switch viewState {
        case .asking(_):
            // Submit
            self.answerTextField.endEditing(true)
            deckManager.validate(userAnswer: answerTextField.text)
        case .correct, .incorrect(_):
            // Go to next card
            deckManager.next()
        case .mastered:
            // Exit
            delegate?.dismissViewController()
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        print("Current deck mastery: \(deckManager.deck.mastery)%")
        decksInProgress.append(deckManager.deck)
        DeckSaver.saveAllDecks()
        delegate?.dismissViewController()
    }
    
    @IBAction func giveUpAction(_ sender: Any) {
        // Give Up
        deckManager.validate(userAnswer: nil)
    }
}


// MARK: - View State
extension TypeAnswerViewController {
    
    private func setViewState(_ viewState: ViewState) {
        self.viewState = viewState
        
        switch viewState {
        case .asking(let question):
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.continueButton.setTitle("Submit", for: .normal)
                self.questionLabel.text = question
                
                self.answerTextField.alpha = 1.0
                self.giveUpButton.alpha = 1.0
            }, completion: nil)
        case .correct:
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Next Question", for: .normal)
                self.questionLabel.text = "Correct!"
                self.answerTextField.text = ""
                
                self.answerTextField.alpha = 0.0
                self.giveUpButton.alpha = 0.0
            }
        case .incorrect(let correctAnswer):
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Next Question", for: .normal)
                self.questionLabel.text = "Wrong: \(correctAnswer)"
                self.answerTextField.text = ""
                
                self.answerTextField.alpha = 0.0
                self.giveUpButton.alpha = 0.0
            }
        case .mastered:
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Done", for: .normal)
                self.questionLabel.text = "Congratulations!\nYou have mastered this deck."
                self.answerTextField.text = ""
                
                self.answerTextField.alpha = 0.0
                self.giveUpButton.alpha = 0.0
            }
        }
    }
    
    func resetDeck() {
        let alertController = UIAlertController(title: "Confirm Start Over", message: "Are you sure you want to start this deck over? All progress will be lost.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default) { (action) in
            self.deckManager.startFromBeginning()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Card Deck Delegate
extension TypeAnswerViewController: DeckManagerDelegate {
    
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
