//
//  StartDeckViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/9/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class DeckInfoViewController: UIViewController {

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var masteredLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quizModePickerView: UIPickerView!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bigEditButton: UIButton!
    
    var deck: Deck
    var isViewingDeck: Bool
    
    init(deck: Deck, isViewingDeck: Bool) {
        self.deck = deck
        self.isViewingDeck = isViewingDeck
        super.init(nibName: String(describing: DeckInfoViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = deck.title
        
        if isViewingDeck {
            editButton.isHidden = true
            masteredLabel.text = "\(deck.mastery)% Mastered"
            stackView.removeArrangedSubview(resumeButton)
            resumeButton.removeFromSuperview()
        } else {
            masteredLabel.isHidden = true
            stackView.removeArrangedSubview(bigEditButton)
            bigEditButton.removeFromSuperview()
        }
        
        quizModePickerView.dataSource = self
        quizModePickerView.delegate = self
        
        // Remove resume button if hasn't been started
        if deck.isInInitialState {
            startButton.setTitle("Start Deck", for: .normal)
            stackView.removeArrangedSubview(resumeButton)
            resumeButton.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Actions
    
    @IBAction func editAction(_ sender: Any) {
        let controller = EditDeckViewController(isEditing: true)
        navigationController?.pushViewController(controller, animated: true)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    @IBAction func startDeckAction(_ sender: Any) {
        let selectedRow = quizModePickerView.selectedRow(inComponent: 0)
        let quizMode = QuizMode.allModes[selectedRow]

        var quizController = quizMode.getController(with: deck, shouldResume: false)
        quizController.delegate = self

        guard let controller = quizController as? UIViewController else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func resumeDeckAction(_ sender: Any) {
        let selectedRow = quizModePickerView.selectedRow(inComponent: 0)
        let quizMode = QuizMode.allModes[selectedRow]
        
        var quizController = quizMode.getController(with: deck, shouldResume: true)
        quizController.delegate = self
        
        guard let controller = quizController as? UIViewController else { return }
        navigationController?.pushViewController(controller, animated: true)
    }

}

extension DeckInfoViewController: NavigationDelegate {
    func dismissViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension DeckInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return QuizMode.allModes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return QuizMode.allModes[row].title
    }
}
