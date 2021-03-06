//
//  GridViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/17/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit
import CustomPopup

class GridViewController: UIViewController, QuizModeController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Pop Up protocol properties
    var gesture: UIGestureRecognizer?
    var popUp: PopUpController?
    
    var delegate: NavigationDelegate?
    var deckManager: DeckManager
    
    init(deck: Deck) {
        self.deckManager = DeckManager(deck: deck)
        super.init(nibName: String(describing: GridViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCellsAndViews()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func registerCellsAndViews() {
        // Cell classes
        guard let collectionView = collectionView else { return }
        collectionView.register(UINib(nibName: String(describing: SingleTitleCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: SingleTitleCollectionViewCell.identifier)
        
        // Header view
        collectionView.register(UINib(nibName: String(describing: SectionHeaderCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.identifier)
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
    
    @IBAction func settingsButtonAction(_ sender: Any) {
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
}
    
// MARK: UICollectionView
extension GridViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deckManager.deck.cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleTitleCollectionViewCell.identifier, for: indexPath) as? SingleTitleCollectionViewCell else {
            fatalError("Could not dequeue cell.")
        }
        let question = deckManager.deck.questions[indexPath.row]
        cell.configure(with: question.question, showCardDetails: true)
        cell.delegate = self

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let card = collectionView.cellForItem(at: indexPath) as? SingleTitleCollectionViewCell else { return }
        let question = deckManager.deck.questions[indexPath.row]
        guard let answer = deckManager.deck.cards[question] else { return }
        
        if card.isShowingFront {
            // Pop up presentation
            let fullScreen = FullScreenCardViewController(question: question, answer: answer, isShowingFront: card.isShowingFront, flipCardAction: { (isCorrect) in
                let color: UIColor = isCorrect ? .myGreen : .myRed
                if isCorrect { self.deckManager.correct() }
                else { self.deckManager.incorrect() }
                
                UIView.transition(with: card, duration: 0.5, options: .transitionFlipFromRight, animations: {
                    card.configure(with: answer.answer, backgroundColor: color, showCardDetails: false)
                }, completion: nil)
                card.isShowingFront = false
            })
            fullScreen.delegate = self
            popUp = PopUpController(popUpView: fullScreen)
            popUp?.presentPopUp(on: self)
            
            // Add dismiss pop up gesture
            gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
            gesture?.delegate = self
            guard let gesture = gesture else { return }
            self.view.addGestureRecognizer(gesture)
        } else {
            UIView.transition(with: card, duration: 0.5, options: .transitionFlipFromRight, animations: {
                card.configure(with: question.question, backgroundColor: .white, showCardDetails: true)
            }, completion: nil)
            card.isShowingFront = true
        }
    }
}

// MARK: - Card Delegate
extension GridViewController: CardDelegate {
    func removeCard(question: String?) { return }
    
    func cardDetails(question: String?) {
        let deck = deckManager.deck
        guard let index = deck.questions.index(where: { $0.question == question }) else { return }
        let question = deck.questions[index]
        
        // Pop up presentation
        let detailsController = DetailsViewController(question: question, isTimed: deck.isTimed)
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

// MARK: - Card Deck Delegate
extension GridViewController: DeckManagerDelegate {
    func showComplete() { return }
    func showAnswer(answer: Answer, isCorrect: Bool?) { return }
    func showQuestion(question: Question, randomAnswers: [Answer]) { return }
}

// MARK: - Pop Up
extension GridViewController: PopUpPresentationController {
    var origin: CGPoint? {
        return nil
    }
    
    @objc func dismissPopUp() {
        guard let popUp = popUp, let gesture = gesture else { return }
        popUp.dismissSubviews()
        self.view.removeGestureRecognizer(gesture)
    }
}

// MARK: - Gesture Recognizer Delegate
extension GridViewController: UIGestureRecognizerDelegate {
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
extension GridViewController: NavigationDelegate {
    func dismissViewController() {
        dismissPopUp()
        navigationController?.popViewController(animated: true)
    }
}
