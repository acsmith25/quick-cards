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
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var answerTextView: UITextView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cardsHeaderLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorHeight: NSLayoutConstraint!
    
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
        
        // Set separator color to native table view color
        let tempTableView = UITableView()
        let separatorColor = tempTableView.separatorColor
        separatorView.backgroundColor = separatorColor
        
        // Set separator to one pixel on any scale
        separatorHeight.constant = 1.0 / UIScreen.main.nativeScale
        
        registerCells()
        addGestures()
        
        titleTextField.delegate = self
        answerTextView.textContainer.heightTracksTextView = true
        questionTextView.textContainer.heightTracksTextView = true
//        answerTextView.delegate = self
//        questionTextView.delegate = self
//        answerTextField.delegate = self
//        questionTextField.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.reorderingCadence = .fast
        
        guard let deck = deck else {
            self.deck = Deck(title: "New Deck", cards: [:])
            titleTextField.placeholder = "Your Deck Title"
            cardsHeaderLabel.isHidden = true
            return
        }
        
        titleTextField.text = deck.title
        titleTextField.becomeFirstResponder()
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
        self.answerTextView.resignFirstResponder()
        self.questionTextView.resignFirstResponder()
        
        guard let question = questionTextView.text, let answer = answerTextView.text else { return }
        
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

        self.cardsHeaderLabel.isHidden = false
        self.answerTextView.text = ""
        self.questionTextView.text = ""
        self.collectionView.reloadData()
    }
    
    @IBAction func editAction(_ sender: Any) {
        dismissKeyboard()
        switch viewState {
        case .add:
            collectionView.dragInteractionEnabled = true
            setViewState(viewState: .edit)
        case .edit:
            collectionView.dragInteractionEnabled = false
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
            let alertController = UIAlertController(title: "Do you want to save your changes?", message: nil, preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
                if let deck = self.deck {
                    deck.title = self.titleTextField.text ?? self.titleTextField.placeholder ?? ""
                    
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
                
                self.delegate?.dismissViewController()
            }
            let backAction = UIAlertAction(title: "Discard", style: .default) { (action) in
                self.delegate?.dismissViewController()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.view.tintColor = .myTeal
        
            alertController.addAction(saveAction)
            alertController.addAction(backAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
//            return
//        }
//        self.delegate?.dismissViewController()
    }
}

extension EditDeckViewController {
    
    private func setViewState(viewState: ViewState) {
        self.viewState = viewState
        switch viewState {
        case .add:
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.editButton.setTitle("Edit", for: .normal)
                self.editButton.setTitleColor(.myTeal, for: .normal)
                self.editButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self.editButton.contentHorizontalAlignment = .right
                self.editButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                self.editButton.backgroundColor = .none
                
                self.addCardButton.setTitle("Add Card", for: .normal)
                self.collectionView.reloadData()
            }) { (_) in
//                self.collectionView.reloadData()
            }
        case .edit:
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.editButton.setTitle("Done", for: .normal)
                self.editButton.setTitleColor(.groupTableViewBackground, for: .normal)
                self.editButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
                self.editButton.contentHorizontalAlignment = .center
                self.editButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
                self.editButton.backgroundColor = .lightGray
                
                self.addCardButton.setTitle("Update Card", for: .normal)
                self.collectionView.reloadData()
            }) { (_) in
//                self.collectionView.reloadData()
            }
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
            questionTextView.text = question.question
            answerTextView.text = answer.answer
        }
    }
}

extension EditDeckViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let item = deck?.questions[indexPath.row].question else { return [] }
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension EditDeckViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        if session.localDragSession != nil {
            if collectionView.hasActiveDrag {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of collection view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        switch coordinator.proposal.operation {
        case .move:
            let items = coordinator.items
            if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath {
                var dIndexPath = destinationIndexPath
                if dIndexPath.row >= collectionView.numberOfItems(inSection: 0) {
                    dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
                }
                collectionView.performBatchUpdates({
                    guard let question = deck?.questions[sourceIndexPath.row] else { fatalError("Could not get card")}
                    deck?.moveCard(question: question, from: sourceIndexPath.row, to: dIndexPath.row)
                    
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [dIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: dIndexPath)
            }
            break
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let previewParameters = UIDragPreviewParameters()
//        guard let cell = collectionView.cellForItem(at: indexPath) as? SingleTitleCollectionViewCell else { return nil }
//        cell.configure(isInDeleteMode: false)
        
        previewParameters.visiblePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 100, height: 100), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10))
        return previewParameters
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

// MARK: - UIGestureRecognizerDelegate
extension EditDeckViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = scrollView, let touch = touch.view else { return false }
        if touch.isDescendant(of: view) {
            return false
        }
        return true
    }
}

// MARK: - UITextFieldDelegate
extension EditDeckViewController: UITextFieldDelegate {
    
//    textview
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
}

// MARK: - Gestures
extension EditDeckViewController {
    
    func addGestures() {
        let keyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        keyboardGesture.delegate = self
        self.view.addGestureRecognizer(keyboardGesture)
    }
    
    @objc func dismissKeyboard() {
        titleTextField.endEditing(true)
        answerTextView.endEditing(true)
        questionTextView.endEditing(true)
    }
}
