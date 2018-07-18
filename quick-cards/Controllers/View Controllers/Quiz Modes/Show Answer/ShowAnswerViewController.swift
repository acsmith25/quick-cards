//
//  ShowAnswerViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/12/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class ShowAnswerViewController: UIViewController, QuizModeController, PopUpPresentationController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    private enum ViewState {
        case asking(String?)
        case answer(String)
        case mastered
    }
    
    private var viewState: ViewState = .asking(nil)
    
    var deckManager: DeckManager
    var delegate: NavigationDelegate?
    
    var gesture: UIGestureRecognizer?
    var popUp: PopUpController?
    
    init(deck: Deck) {
        self.deckManager = DeckManager(deck: deck)
        super.init(nibName: String(describing: ShowAnswerViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        cardView.addGestureRecognizer(gesture)
        
        deckManager.delegate = self
        deckManager.startFromBeginning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        deckManager.next()
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
    
    @IBAction func settingsAction(_ sender: Any) {
        popUp = PopUpController(popUpView: DeckInfoViewController(deck: deckManager.deck, isViewingDeck: true))
        guard let popUp = popUp else { return }
        popUp.presentPopUp(on: self)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
        gesture?.delegate = self
        guard let gesture = gesture else { return }
        self.view.addGestureRecognizer(gesture)
    }

    @objc func dismissPopUp() {
        guard let popUp = popUp, let gesture = gesture else { return }
        popUp.dismissSubviews()
        self.view.removeGestureRecognizer(gesture)
    }
    
    @objc func flipCard() {
        deckManager.validate(userAnswer: nil)
    }
    
    private func setViewState(_ viewState: ViewState) {
        self.viewState = viewState
        
        switch viewState {
        case .asking(let question):
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.questionLabel.text = question
                
                self.nextButton.isHidden = true
                self.stackView.layoutIfNeeded()
                
                self.nextButton.alpha = 0.0
            }, completion: nil)
        case .answer(let answer):
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.questionLabel.text = answer
                
                self.nextButton.isHidden = false
                self.stackView.layoutIfNeeded()
                
                self.nextButton.alpha = 1.0
            }, completion: nil)
        case .mastered:
            self.questionLabel.text = "Congratulations!\nYou have mastered this deck."
            
            self.nextButton.isHidden = true
            self.stackView.layoutIfNeeded()
            
            self.nextButton.alpha = 0.0
        }
    }
    
}

extension ShowAnswerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let popUp = popUp, let view = touch.view else { return false }
        if view.isDescendant(of: popUp.popUpController.view) {
            return false
        }
        return true
    }
}

// MARK: - Card Deck Delegate
extension ShowAnswerViewController: DeckManagerDelegate {
    
    func masteredDeck() {
        setViewState(.mastered)
    }
    
    func showAnswer(correctAnswer: String? = nil) {
        guard let correctAnswer = correctAnswer else {
            return
        }
        setViewState(.answer(correctAnswer))
    }
    
    func askQuestion(question: Question, wrongAnswers: [Answer]) {
        setViewState(.asking(question.question))
    }
    
}
