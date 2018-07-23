//
//  TypeAnswerViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/6/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit
import CustomPopup

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
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var continueButtonCenter: NSLayoutConstraint!
    @IBOutlet weak var cardViewCenter: NSLayoutConstraint!
    @IBOutlet weak var giveUpButtonCenter: NSLayoutConstraint!
    
    private enum ViewState {
        case asking(String?)
        case answer(String, Bool)
        case mastered
    }
    
    private var viewState: ViewState = .asking(nil)
    
    // Pop Up protocol properties
    var gesture: UIGestureRecognizer?
    var popUp: PopUpController?
    
    var delegate: NavigationDelegate?
    
    var deckManager: DeckManager
    var shouldResume: Bool
    
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

//        cardView.layer.cornerRadius = 10
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 11)
//        cardView.layer.shadowOpacity = 0.15
//        cardView.layer.shadowRadius = 13
        
        answerTextField.delegate = self
        answerTextField.autocorrectionType = .no
        
        addGestures()

        deckManager.delegate = self
        if shouldResume { deckManager.startDeck() }
        else { deckManager.startFromBeginning() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// MARK: - Actions
    
    @IBAction func continueButtonAction(_ sender: Any) {
        switch viewState {
        case .asking(_):
            // Submit
            self.answerTextField.resignFirstResponder()
            deckManager.validate(userAnswer: answerTextField.text)
        case .answer(_,_):
            // Go to next card
            deckManager.next()
        case .mastered:
            // Exit
            delegate?.dismissViewController()
        }
    }
    
    @IBAction func giveUpAction(_ sender: Any) {
        deckManager.incorrect()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        print("Current deck mastery: \(deckManager.deck.mastery)%")
        deckManager.exit()
        
        // Update all references to deck
        let inProgressIndex = decksInProgress.index { $0 == deckManager.deck }
        if let index = inProgressIndex {
            decksInProgress[index] = deckManager.deck
        } else {
            decksInProgress.append(deckManager.deck)
        }
        let userDeckIndex = userDecks.index { $0 == deckManager.deck }
        if let index = userDeckIndex {
            userDecks[index] = deckManager.deck
        } else {
            if let defaultDeckIndex = defaultDecks.index(where: { $0 == deckManager.deck }) {
                defaultDecks[defaultDeckIndex] = deckManager.deck
            }
        }
        
        // Save decks
        DeckSaver.saveAllDecks()
        delegate?.dismissViewController()
    }

    @IBAction func settingsAction(_ sender: Any) {
        let infoController = DeckInfoViewController(deck: deckManager.deck, isViewingDeck: true)
        infoController.delegate = self
        popUp = PopUpController(popUpView: infoController)
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
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.continueButton.setTitle("Submit", for: .normal)
                self.questionLabel.text = question
                self.cardView.backgroundColor = .white
                
                if self.answerTextField.isHidden == true {
                    self.giveUpButton.isHidden = false
                    self.answerTextField.isHidden = false
                    self.stackView.layoutIfNeeded()
                }
                self.answerTextField.alpha = 1.0
                self.giveUpButton.alpha = 1.0
            }, completion: nil)
        case .answer(let answer, let isCorrect):
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Next Question", for: .normal)
                self.answerTextField.text = ""
                self.cardView.backgroundColor = isCorrect ? .myGreen : .myRed
            
                self.giveUpButton.isHidden = true
                self.answerTextField.isHidden = true
                self.stackView.layoutIfNeeded()
                
                self.answerTextField.alpha = 0.0
                self.giveUpButton.alpha = 0.0
            }
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.questionLabel.text = answer
            }, completion: nil)
        case .mastered:
            UIView.animate(withDuration: 0.2) {
                self.continueButton.setTitle("Done", for: .normal)
                self.questionLabel.text = "Congratulations!\nYou have mastered this deck."
                self.answerTextField.text = ""
                self.cardView.backgroundColor = .white

                self.giveUpButton.isHidden = true
                self.answerTextField.isHidden = true
                self.stackView.layoutIfNeeded()
                
                self.answerTextField.alpha = 0.0
                self.giveUpButton.alpha = 0.0
            }
        }
    }
}

// MARK: - Gestures
extension TypeAnswerViewController {
    
    func addGestures() {
        let cardGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        cardView.addGestureRecognizer(cardGesture)
        
        let keyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(keyboardGesture)
    }
    
    @objc func flipCard() {
        dismissKeyboard()
        deckManager.incorrect()
    }
    
    @objc func dismissKeyboard() {
        answerTextField.endEditing(true)
    }
}

// MARK: - DeckManagerDelegate
extension TypeAnswerViewController: DeckManagerDelegate {
    
    func masteredDeck() {
        setViewState(.mastered)
    }
    
    func showAnswer(answer: Answer, isCorrect: Bool) {
        setViewState(.answer(answer.answer, isCorrect))
    }
    
    func askQuestion(question: Question, wrongAnswers: [Answer]) {
        setViewState(.asking(question.question))
    }
}

// MARK: - PopUpPresentationController
extension TypeAnswerViewController: PopUpPresentationController {
    
    @objc func dismissPopUp() {
        guard let popUp = popUp, let gesture = gesture else { return }
        popUp.dismissSubviews()
        self.view.removeGestureRecognizer(gesture)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension TypeAnswerViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let popUp = popUp, let view = touch.view else { return false }
        if view.isDescendant(of: popUp.popUpController.view) {
            return false
        }
        return true
    }
}

// MARK: - UITextFieldDelegate
extension TypeAnswerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        deckManager.validate(userAnswer: answerTextField.text)
        return true
    }
}

// MARK: - Deck Collection View Delegate
extension TypeAnswerViewController: NavigationDelegate {
    
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}
