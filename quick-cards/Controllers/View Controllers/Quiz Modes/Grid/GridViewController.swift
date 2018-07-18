//
//  GridViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/17/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class GridViewController: UIViewController, QuizModeController, PopUpPresentationController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var deckManager: DeckManager
    var delegate: NavigationDelegate?
    
    var gesture: UIGestureRecognizer?
    var popUp: PopUpController?
    
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        //        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    func registerCellsAndViews() {
        // Cell classes
        guard let collectionView = collectionView else { return }
        collectionView.register(UINib(nibName: String(describing: SingleTitleCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: SingleTitleCollectionViewCell.identifier)
        
        // Header view
        collectionView.register(UINib(nibName: String(describing: SectionHeaderCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.identifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
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
    
    @IBAction func settingsButtonAction(_ sender: Any) {
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
}
    
    // MARK: UICollectionViewDataSource

extension GridViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return deckManager.deck.cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleTitleCollectionViewCell.identifier, for: indexPath) as? SingleTitleCollectionViewCell else {
            fatalError("Could not dequeue cell.")
        }
        let question = deckManager.deck.questions[indexPath.row]
        cell.configure(with: question.question)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let card = collectionView.cellForItem(at: indexPath) as? SingleTitleCollectionViewCell else { return }
        let question = deckManager.deck.questions[indexPath.row]
        if card.isShowingFront {
            guard let answer = deckManager.deck.cards[question] else { return }
            deckManager.validate(userAnswer: answer.answer)
            UIView.transition(with: card, duration: 0.5, options: .transitionFlipFromRight, animations: {
                card.configure(with: answer.answer, backgroundColor: .myGreen)
            }, completion: nil)
            card.isShowingFront = false
        } else {
            UIView.transition(with: card, duration: 0.5, options: .transitionFlipFromRight, animations: {
                card.configure(with: question.question, backgroundColor: .white)
            }, completion: nil)
            card.isShowingFront = true
        }
    }

}

extension GridViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let popUp = popUp, let view = touch.view else { return false }
        if view.isDescendant(of: popUp.popUpController.view) {
            return false
        }
        return true
    }
}

// MARK: - Card Deck Delegate
extension GridViewController: DeckManagerDelegate {
    
    func masteredDeck() {
        //        setViewState(.mastered)
    }
    
    func showAnswer(correctAnswer: String? = nil) {
        //        guard let correctAnswer = correctAnswer else {
        //            setViewState(.correct)
        //            return
        //        }
        //        setViewState(.incorrect(correctAnswer))
    }
    
    func askQuestion(question: Question, wrongAnswers: [Answer]) {
        //        setViewState(.asking(question))
    }
    
}
