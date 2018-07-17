//
//  MultipleChoiceViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/12/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class MultipleChoiceViewController: UIViewController, QuizModeController, PopUpPresentationController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var choiceButton1: UIButton!
    @IBOutlet weak var choiceButton2: UIButton!
    @IBOutlet weak var choiceButton3: UIButton!
    @IBOutlet weak var choiceButton4: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var questionLabel: UILabel!

    private enum ViewState {
        case asking(Question, [Answer])
        case correct
        case incorrect(String)
        case mastered
    }
    
    private var viewState: ViewState = .mastered
    
    var deckManager: DeckManager
    var delegate: NavigationDelegate?
    
    var gesture: UIGestureRecognizer?
    var popUp: PopUpController?
    
    init(deck: Deck) {
        self.deckManager = DeckManager(deck: deck)
        super.init(nibName: String(describing: MultipleChoiceViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        cardView.addGestureRecognizer(gesture)
        
        deckManager.delegate = self
//        if shouldResume { deckManager.startDeck() }
        deckManager.startFromBeginning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func nextButtonAction(_ sender: Any) {
        switch viewState {
        case .asking(_):
            deckManager.validate(userAnswer: nil)
        default:
            deckManager.next()
        }
    }
    
    @IBAction func choiceButtonAction(_ sender: Any) {
        guard let sender = sender as? UIButton else { return }
        deckManager.validate(userAnswer: sender.title(for: .normal))
    }
}

// MARK: - View State
extension MultipleChoiceViewController {
    
    private func setViewState(_ viewState: ViewState) {
        self.viewState = viewState
        
        switch viewState {
        case .asking(let question, let randomAnswers):
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                self.questionLabel.text = question.question
                self.cardView.backgroundColor = .white
                
                self.choiceButton1.setTitle(randomAnswers[0].answer, for: .normal)
                self.choiceButton2.setTitle(randomAnswers[1].answer, for: .normal)
                self.choiceButton3.setTitle(randomAnswers[2].answer, for: .normal)
                self.choiceButton4.setTitle(self.deckManager.deck.cards[question]?.answer, for: .normal)
                self.nextButton.setTitle("Give Up", for: .normal)
                
                self.choiceButton1.alpha = 1.0
                self.choiceButton2.alpha = 1.0
                self.choiceButton3.alpha = 1.0
                self.choiceButton4.alpha = 1.0
            }, completion: nil)
        case .correct:
            UIView.animate(withDuration: 0.2) {
                self.cardView.backgroundColor = .myGreen
                self.nextButton.setTitle("Next", for: .normal)
                
                self.choiceButton1.alpha = 0.0
                self.choiceButton2.alpha = 0.0
                self.choiceButton3.alpha = 0.0
                self.choiceButton4.alpha = 0.0
            }
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.questionLabel.text = "Correct!"
            }, completion: nil)
            
        case .incorrect(let correctAnswer):
            UIView.animate(withDuration: 0.2) {
                self.cardView.backgroundColor = .myRed
                self.nextButton.setTitle("Next", for: .normal)
                
                self.choiceButton1.alpha = 0.0
                self.choiceButton2.alpha = 0.0
                self.choiceButton3.alpha = 0.0
                self.choiceButton4.alpha = 0.0            }
            UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.questionLabel.text = "Wrong: \(correctAnswer)"
            }, completion: nil)
        case .mastered:
            UIView.animate(withDuration: 0.2) {
                self.questionLabel.text = "Congratulations!\nYou have mastered this deck."
                self.cardView.backgroundColor = .white
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

extension MultipleChoiceViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let popUp = popUp, let view = touch.view else { return false }
        if view.isDescendant(of: popUp.popUpController.view) {
            return false
        }
        return true
    }
}

// MARK: - Card Deck Delegate
extension MultipleChoiceViewController: DeckManagerDelegate {
    
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
        setViewState(.asking(question, wrongAnswers))
    }
    
}
