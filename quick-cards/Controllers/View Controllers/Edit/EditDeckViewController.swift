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
    @IBOutlet weak var tableView: UITableView!
    
    var deck: Deck?
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
        
        guard let deck = self.deck else {
            self.deck = Deck(title: "New Deck", cards: [:])
            titleTextField.placeholder = self.deck?.title
            return
        }
        
        registerCells()
        
        titleTextField.placeholder = deck.title
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: String(describing: QuestionAnswerTableViewCell.self), bundle: nil), forCellReuseIdentifier: QuestionAnswerTableViewCell.identifier)
    }
    
    // MARK: - Actions
    
    @IBAction func addCardAction(_ sender: Any) {
        self.answerTextField.resignFirstResponder()
        self.questionTextField.resignFirstResponder()

        guard let question = questionTextField.text, let answer = answerTextField.text else {
            let alertController = UIAlertController(title: "Error adding card", message: "Please provide a valid question and answer.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        deck?.addCard(question: question, answer: answer)
         tableView.reloadData()
    }

    @IBAction func saveAction(_ sender: Any) {
        if let deck = deck {
            allDecks.append(deck)
            userDecks.append(deck)
            DeckSaver.saveDecks(decks: allDecks, key: allDecksKey)
            DeckSaver.saveDecks(decks: userDecks, key: allDecksKey)
        }
        delegate?.dismissViewController()
    }
    
    @IBAction func backAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Are you sure?", message: "All progress creating this deck will be lost.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.delegate?.dismissViewController()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension EditDeckViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let deck = deck else {
            return 0
        }
        return deck.cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuestionAnswerTableViewCell.identifier, for: indexPath) as? QuestionAnswerTableViewCell else {
            fatalError("Could not qeueue cell")
        }
        
        guard let deck = deck else { fatalError() }
        let question = deck.questions[indexPath.row]
        let answer = deck.cards[question]
        cell.configure(question: question.question, answer: answer?.answer ?? "")
        
        return cell
    }
    
}
