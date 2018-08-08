//
//  ShowAnswerViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/12/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit
import CustomPopup

class ShowAnswerViewController: UIViewController, QuizModeController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var correctButton: UIButton!
    @IBOutlet weak var incorrectButton: UIButton!
    
    private enum ViewState {
        case asking(String?)
        case answer(String)
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
        super.init(nibName: String(describing: ShowAnswerViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addGestures()
        
        deckManager.delegate = self
        if !shouldResume { deckManager.deck.reset() }
        deckManager.startDeck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// MARK: - Actions
    
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
    
    @IBAction func moreAction(_ sender: Any) {
        guard let question = deckManager.currentQuestion else { return }
        let detailsController = DetailsViewController(question: question, isTimed: deckManager.deck.isTimed) //DeckInfoViewController(deck: deckManager.deck, isViewingDeck: true)
        detailsController.delegate = self
        popUp = PopUpController(popUpView: detailsController)
        guard let popUp = popUp else { return }
        popUp.presentPopUp(on: self)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
        gesture?.delegate = self
        guard let gesture = gesture else { return }
        self.view.addGestureRecognizer(gesture)

    }
    @IBAction func correctAction(_ sender: Any) {
        deckManager.correct()
        deckManager.next()
    }
    
    @IBAction func incorrectAction(_ sender: Any) {
        deckManager.incorrect()
        deckManager.next()
    }
}

// MARK: - View State
extension ShowAnswerViewController {
    
    private func setViewState(_ viewState: ViewState) {
        self.viewState = viewState
        
        switch viewState {
        case .asking(let question):
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.questionLabel.text = question
                
                self.moreButton.isHidden = false
                self.correctButton.isHidden = true
                self.incorrectButton.isHidden = true
                self.stackView.layoutIfNeeded()
            }, completion: nil)
        case .answer(let answer):
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.questionLabel.text = answer
                
                self.moreButton.isHidden = true
                self.correctButton.isHidden = false
                self.incorrectButton.isHidden = false
                self.stackView.layoutIfNeeded()
            }, completion: nil)
        case .mastered:
            self.questionLabel.text = "Congratulations!\nYou have mastered this deck."
            
            self.moreButton.isHidden = true
            self.correctButton.isHidden = true
            self.incorrectButton.isHidden = true
            self.stackView.layoutIfNeeded()
        }
    }
    
}

// MARK: - Gestures
extension ShowAnswerViewController {
    
    func addGestures() {
        let cardGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        cardView.addGestureRecognizer(cardGesture)
    }
    
    @objc func flipCard() {
        switch viewState {
        case .answer(_):
            return 
        default:
            guard let question = deckManager.currentQuestion else { return }
            guard let answer = deckManager.deck.cards[question] else { return }
            setViewState(.answer(answer.answer))
        }
    }
}

// MARK: - DeckManagerDelegate
extension ShowAnswerViewController: DeckManagerDelegate {
    
    func showComplete() {
        setViewState(.mastered)
    }
    
    func showAnswer(answer: Answer, isCorrect: Bool) {
//        setViewState(.answer(answer.answer))
    }
    
    func showQuestion(question: Question, randomAnswers: [Answer]) {
        setViewState(.asking(question.question))
    }
}

// MARK: - PopUpPresentationController
extension ShowAnswerViewController: PopUpPresentationController {
    
    @objc func dismissPopUp() {
        guard let popUp = popUp, let gesture = gesture else { return }
        popUp.dismissSubviews()
        self.view.removeGestureRecognizer(gesture)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ShowAnswerViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let popUp = popUp, let view = touch.view else { return false }
        if view.isDescendant(of: popUp.popUpController.view) {
            return false
        }
        return true
    }
}

// MARK: - Deck Collection View Delegate
extension ShowAnswerViewController: NavigationDelegate {
    
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}
