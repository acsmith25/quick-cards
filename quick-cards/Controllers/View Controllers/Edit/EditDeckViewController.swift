//
//  NewDeckViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 6/27/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class EditDeckViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    private enum ViewState {
        case add
        case edit
    }
    
    private var viewState: ViewState = .add
    
    var deck: Deck?
    var currentQuestion: Question?
    var delegate: NavigationDelegate?
    
    init(deck: Deck?) {
        self.deck = deck
        super.init(nibName: String(describing: EditDeckViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        
        registerCells()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        guard let deck = deck else {
            self.deck = Deck(title: "New Deck", cards: [:])
            titleTextField.placeholder = "Your Deck Title"
            return
        }
        
        titleTextField.text = deck.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func registerCells() {
        collectionView.register(UINib(nibName: String(describing: SingleTitleCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: SingleTitleCollectionViewCell.identifier)
    }
    
    // MARK: - Actions
    
    @IBAction func addCardAction(_ sender: Any) {
        self.answerTextField.resignFirstResponder()
        self.questionTextField.resignFirstResponder()
        
        guard let question = questionTextField.text, let answer = answerTextField.text else { return }
        
        guard !question.isEmpty, !answer.isEmpty else {
            let alertController = UIAlertController(title: "Error adding card", message: "Please provide a valid question and answer.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        guard let deck = deck else { return }
        
        switch viewState {
        case .add:
            deck.addCard(question: question, answer: answer)
        case .edit:
            guard let currentQuestion = currentQuestion else { return }
            deck.updateQuestion(oldQuestion: currentQuestion, newQuestion: question, newAnswer: answer)
            self.currentQuestion = nil
        }

        self.answerTextField.text = ""
        self.questionTextField.text = ""
        self.collectionView.reloadData()
    }
    
    @IBAction func editAction(_ sender: Any) {
        switch viewState {
        case .add:
            setViewState(viewState: .edit)
        case .edit:
            setViewState(viewState: .add)
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let deck = deck {
            deck.title = titleTextField.text ?? titleTextField.placeholder ?? ""
            
            // Update all references to deck
            let allDecksIndex = decksInProgress.index { $0 == deck }
            if let index = allDecksIndex {
                allDecks[index] = deck
            } else {
                allDecks.append(deck)
            }
            let inProgressIndex = decksInProgress.index { $0 == deck }
            if let index = inProgressIndex {
                decksInProgress[index] = deck
            }
            let defaultDeckIndex = defaultDecks.index { $0 == deck }
            if let index = defaultDeckIndex {
                defaultDecks[index] = deck
            } else {
                if let userDeckIndex = userDecks.index(where: { $0 == deck }) {
                    userDecks[userDeckIndex] = deck
                } else {
                    userDecks.append(deck)
                }
            }
            
            // Save decks
            DeckSaver.saveAllDecks()
        }
        
        delegate?.dismissViewController()
    }
    
    @IBAction func backAction(_ sender: Any) {
//        guard let question = questionTextField.text, let answer = answerTextField.text else { return }
//        guard deck?.questions.isEmpty else {
            let alertController = UIAlertController(title: "Are you sure?", message: "Any changes since the last save deck will be lost.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                self.delegate?.dismissViewController()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
//            return
//        }
        self.delegate?.dismissViewController()
    }
}

extension EditDeckViewController {
    
    private func setViewState(viewState: ViewState) {
        self.viewState = viewState
        switch viewState {
        case .add:
            editButton.setTitle("Edit Deck", for: .normal)
            addCardButton.setTitle("Add Card", for: .normal)
            collectionView.reloadData()
        case .edit:
            editButton.setTitle("Done Editing", for: .normal)
            addCardButton.setTitle("Update Card", for: .normal)
            collectionView.reloadData()
        }
    }
}

extension EditDeckViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let deck = deck else {
            return 0
        }
        return deck.cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleTitleCollectionViewCell.identifier, for: indexPath) as? SingleTitleCollectionViewCell else {
            fatalError("Could not qeueue cell")
        }
        
        guard let deck = deck else { fatalError() }
        let question = deck.questions[indexPath.row]
        cell.configure(with: question.question, isInDeleteMode: viewState == .edit)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let card = collectionView.cellForItem(at: indexPath) as? SingleTitleCollectionViewCell else { return }
        guard let question = deck?.questions[indexPath.row] else { return }
        guard let answer = deck?.cards[question] else { return }
        
        switch viewState {
        case .add:
            if card.isShowingFront {
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
        case .edit:
            currentQuestion = question
            questionTextField.text = question.question
            answerTextField.text = answer.answer
        }
    }
}

extension EditDeckViewController: CardDelegate {
    
    func removeCard(question: String?) {
        if let index = deck?.questions.index(where: { $0.question == question }) {
            if let question = deck?.questions[index] {
                deck?.removeCard(question: question)
            }
        }
        collectionView.reloadData()
    }
}
