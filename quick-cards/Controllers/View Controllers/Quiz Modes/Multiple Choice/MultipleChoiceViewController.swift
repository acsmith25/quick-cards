//
//  MultipleChoiceViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/12/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class MultipleChoiceViewController: UIViewController, QuizModeController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var choiceButton1: UIButton!
    @IBOutlet weak var choiceButton2: UIButton!
    @IBOutlet weak var choiceButton3: UIButton!
    @IBOutlet weak var choiceButton4: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
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
    
    // Pop Up protocol properties
    var gesture: UIGestureRecognizer?
    var popUp: PopUpController?
    
    var delegate: NavigationDelegate?
    
    var deckManager: DeckManager
    var shouldResume: Bool
    
    init(deck: Deck, shouldResume: Bool) {
        self.deckManager = DeckManager(deck: deck)
        self.shouldResume = shouldResume
        super.init(nibName: String(describing: MultipleChoiceViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
extension MultipleChoiceViewController {
    
    private func setViewState(_ viewState: ViewState) {
        self.viewState = viewState
        
        switch viewState {
        case .asking(let question, let randomAnswers):
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.nextButton.setTitle("Give Up", for: .normal)
                self.choiceButton1.setTitle(randomAnswers[0].answer, for: .normal)
                self.choiceButton2.setTitle(randomAnswers[1].answer, for: .normal)
                self.choiceButton3.setTitle(randomAnswers[2].answer, for: .normal)
                self.choiceButton4.setTitle(self.deckManager.deck.cards[question]?.answer, for: .normal)
                self.questionLabel.text = question.question
                self.cardView.backgroundColor = .white
                
                self.choicesView.isHidden = false
                self.stackView.layoutIfNeeded()
                
                self.choicesView.alpha = 1.0
            }, completion: nil)
        case .answer(let answer, let isCorrect):
            UIView.animate(withDuration: 0.2) {
                self.nextButton.setTitle("Next", for: .normal)
                self.cardView.backgroundColor = isCorrect ? .myGreen : .myRed
                
                self.choicesView.isHidden = true
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
            }
        }
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

// MARK: - Card Deck Delegate
extension MultipleChoiceViewController: DeckManagerDelegate {
    
    func masteredDeck() {
        setViewState(.mastered)
    }
    
    func showAnswer(answer: Answer, isCorrect: Bool) {
        setViewState(.answer(answer.answer, isCorrect))
    }
    
    func askQuestion(question: Question, wrongAnswers: [Answer]) {
        setViewState(.asking(question, wrongAnswers))
    }
}

// MARK: - PopUpPresentationController
extension MultipleChoiceViewController: PopUpPresentationController {
    
    @objc func dismissPopUp() {
        guard let popUp = popUp, let gesture = gesture else { return }
        popUp.dismissSubviews()
        self.view.removeGestureRecognizer(gesture)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MultipleChoiceViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let popUp = popUp, let view = touch.view else { return false }
        if view.isDescendant(of: popUp.popUpController.view) {
            return false
        }
        return true
    }
}
