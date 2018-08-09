//
//  MultipleChoiceViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/12/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit
import CustomPopup

class MultipleChoiceViewController: UIViewController, QuizModeController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var choiceButton1: UIButton!
    @IBOutlet weak var choiceButton2: UIButton!
    @IBOutlet weak var choiceButton3: UIButton!
    @IBOutlet weak var choiceButton4: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var choicesView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var questionLabel: UILabel!

    private enum ViewState {
        case asking(Question, [Answer])
        case answer(String, Bool)
        case mastered
    }
    private var viewState: ViewState = .mastered
    
    var choiceButtons: [UIButton] = []
    
    // Pop Up protocol properties
    var gesture: UIGestureRecognizer?
    var popUp: PopUpController?
    
    var delegate: NavigationDelegate?
    var deckManager: DeckManager
    
    init(deck: Deck) {
        self.deckManager = DeckManager(deck: deck)
        super.init(nibName: String(describing: MultipleChoiceViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        choiceButtons = [choiceButton1, choiceButton2, choiceButton3, choiceButton4]
        
        addGestures()
        
        deckManager.delegate = self
        deckManager.startDeck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// MARK: - Actions
    
    @IBAction func choiceButtonAction(_ sender: Any) {
        // Submit
        guard let sender = sender as? UIButton else { return }
        deckManager.validate(userAnswer: sender.title(for: .normal))
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        switch viewState {
        case .asking(_):
            // Give up
            deckManager.incorrect()
        default:
            // Go to next card
            deckManager.next()
        }
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
        // Pop up presentation
        let infoController = DeckInfoViewController(deck: deckManager.deck, isViewingDeck: true)
        infoController.delegate = self
        popUp = PopUpController(popUpView: infoController)
        guard let popUp = popUp else { return }
        popUp.presentPopUp(on: self)
        
        // Add dismiss pop up gesture
        gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
        gesture?.delegate = self
        guard let gesture = gesture else { return }
        self.view.addGestureRecognizer(gesture)
    }
    
    @IBAction func moreAction(_ sender: Any) {
        guard let question = deckManager.currentQuestion else { return }
        
        // Pop up presentation
        let detailsController = DetailsViewController(question: question, isTimed: deckManager.deck.isTimed)
        detailsController.delegate = self
        popUp = PopUpController(popUpView: detailsController)
        guard let popUp = popUp else { return }
        popUp.presentPopUp(on: self)
        
        // Add dismiss pop up gesture
        gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
        gesture?.delegate = self
        guard let gesture = gesture else { return }
        self.view.addGestureRecognizer(gesture)

    }
}

// MARK: - Gestures
extension MultipleChoiceViewController {
    
    func addGestures() {
        let cardGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        cardView.addGestureRecognizer(cardGesture)
    }
    
    @objc func flipCard() {
        deckManager.incorrect()
    }
}

// MARK: - View State
extension MultipleChoiceViewController {
    
    private func setViewState(_ viewState: ViewState) {
        self.viewState = viewState
        
        switch viewState {
        case .asking(let question, var randomAnswers):
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.nextButton.setTitle("Give Up", for: .normal)
                self.choiceButtons.forEach({ (button) in
                    guard let index = randomAnswers.getRandomIndex() else { return }
                    button.setTitle(randomAnswers[index].answer, for: .normal)
                    randomAnswers.remove(at: index)
                })
                
                self.questionLabel.text = question.question
                self.cardView.backgroundColor = .white
                
                self.choicesView.isHidden = false
                self.moreButton.isHidden = false
                self.stackView.layoutIfNeeded()
                
                self.choicesView.alpha = 1.0
            }, completion: nil)
        case .answer(let answer, let isCorrect):
            UIView.animate(withDuration: 0.2) {
                self.nextButton.setTitle("Next", for: .normal)
                self.cardView.backgroundColor = isCorrect ? .myGreen : .myRed
                
                self.choicesView.isHidden = true
                self.moreButton.isHidden = true
                self.stackView.layoutIfNeeded()
                
                self.choicesView.alpha = 0.0
            }
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.questionLabel.text = answer
            }, completion: nil)
        case .mastered:
            UIView.animate(withDuration: 0.2) {
                self.questionLabel.text = "Congratulations!\nYou have mastered this deck."
                self.cardView.backgroundColor = .white
                self.moreButton.isHidden = true
            }
        }
    }
}

// MARK: - Card Deck Delegate
extension MultipleChoiceViewController: DeckManagerDelegate {
    
    func showComplete() {
        setViewState(.mastered)
    }
    
    func showAnswer(answer: Answer, isCorrect: Bool) {
        setViewState(.answer(answer.answer, isCorrect))
    }
    
    func showQuestion(question: Question, randomAnswers: [Answer]) {
        setViewState(.asking(question, randomAnswers))
    }
}

// MARK: - Pop Up
extension MultipleChoiceViewController: PopUpPresentationController {
    @objc func dismissPopUp() {
        guard let popUp = popUp, let gesture = gesture else { return }
        popUp.dismissSubviews()
        self.view.removeGestureRecognizer(gesture)
    }
}

// MARK: - Gesture Recognizer Delegate
extension MultipleChoiceViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Dismiss pop up on tap outside of pop up view
        guard let popUp = popUp, let view = touch.view else { return false }
        if view.isDescendant(of: popUp.popUpController.view) {
            return false
        }
        return true
    }
}

// MARK: - Navigation Delegate
extension MultipleChoiceViewController: NavigationDelegate {
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}
