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

class TypeAnswerViewController: UIViewController, QuizModeController, PopUpPresentationController {
    @IBOutlet weak var giveUpButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var continueButtonCenter: NSLayoutConstraint!
    @IBOutlet weak var cardViewCenter: NSLayoutConstraint!
//    @IBOutlet weak var answerFieldCenter: NSLayoutConstraint!
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
    
    var gesture: UIGestureRecognizer?
    var popUp: PopUpController?
    
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
//        cardView.layer.cornerRadius = 10
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 11)
//        cardView.layer.shadowOpacity = 0.15
//        cardView.layer.shadowRadius = 13
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        cardView.addGestureRecognizer(gesture)
        
        deckManager.delegate = self
        if shouldResume { deckManager.startDeck() }
        else { deckManager.startFromBeginning() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
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
        deckManager.exit()
        let ipIndex = decksInProgress.index { $0 == deckManager.deck }
        if let index = ipIndex {
            decksInProgress[index] = deckManager.deck
        } else {
            decksInProgress.append(deckManager.deck)
        }
        let udIndex = userDecks.index { $0 == deckManager.deck }
        if let index = udIndex {
            userDecks[index] = deckManager.deck
        } else {
            if let ddIndex = defaultDecks.index(where: { $0 == deckManager.deck }) {
                defaultDecks[ddIndex] = deckManager.deck
            }
        }
        DeckSaver.saveAllDecks()
        delegate?.dismissViewController()
    }
    
    @IBAction func giveUpAction(_ sender: Any) {
        // Give Up
        deckManager.validate(userAnswer: nil)
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        popUp = PopUpController(popUpView: DeckInfoViewController(deck: deckManager.deck, isViewingDeck: true))
        guard let popUp = popUp else { return }
        popUp.presentPopUp(on: self)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
        gesture?.delegate = self
        guard let gesture = gesture else { return }
        self.view.addGestureRecognizer(gesture)
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
                self.cardView.backgroundColor = .white
                
                self.answerTextField.alpha = 1.0
                self.giveUpButton.alpha = 1.0
            }, completion: nil)
        case .correct:
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Next Question", for: .normal)
//                self.questionLabel.text = "Correct!"
                self.answerTextField.text = ""
                self.cardView.backgroundColor = .myGreen
                
                self.answerTextField.alpha = 0.0
                self.giveUpButton.alpha = 0.0
            }
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                //                self.questionLabel.text = "Answer"
                self.questionLabel.text = "Correct!"
            }, completion: nil)

        case .incorrect(let correctAnswer):
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Next Question", for: .normal)
//                self.questionLabel.text = "Wrong: \(correctAnswer)"
                self.answerTextField.text = ""
                self.cardView.backgroundColor = .myRed
                
                self.answerTextField.alpha = 0.0
                self.giveUpButton.alpha = 0.0
            }
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
//                self.questionLabel.text = "Answer"
                self.questionLabel.text = "Wrong: \(correctAnswer)"
            }, completion: nil)
        case .mastered:
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Done", for: .normal)
                self.questionLabel.text = "Congratulations!\nYou have mastered this deck."
                self.answerTextField.text = ""
                self.cardView.backgroundColor = .white
                
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
    
    @objc func dismissPopUp() {
        guard let popUp = popUp, let gesture = gesture else { return }
        popUp.dismissSubviews()
        self.view.removeGestureRecognizer(gesture)
    }
    
    @objc func flipCard() {
//        UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
//            self.questionLabel.text = "Answer"
//        }, completion: nil)
        deckManager.validate(userAnswer: nil)
    }
}

extension TypeAnswerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let popUp = popUp, let view = touch.view else { return false }
        if view.isDescendant(of: popUp.popUpController.view) {
            return false
        }
        return true
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
    
    func askQuestion(question: Question, wrongAnswers: [Answer]) {
        setViewState(.asking(question.question))
    }
    
}
