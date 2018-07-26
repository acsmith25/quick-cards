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
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var startSegmentedControl: UISegmentedControl!
    @IBOutlet weak var orderSegmentedControl: UISegmentedControl!
    
    var deck: Deck
    var isViewingDeck: Bool
    
    var delegate: NavigationDelegate?
    
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
        
        titleLabel.text = "\(deck.title):"
        masteredLabel.text = "\(deck.mastery)% Mastered"
        
        quizModePickerView.dataSource = self
        quizModePickerView.delegate = self
        
        // Remove resume option if hasn't been started
        if deck.isInInitialState {
            stackView.removeArrangedSubview(startSegmentedControl)
            startSegmentedControl.removeFromSuperview()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func editAction(_ sender: Any) {
        let controller = EditDeckViewController(deck: deck)
        controller.delegate = self.delegate
        navigationController?.pushViewController(controller, animated: true)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    @IBAction func startDeckAction(_ sender: Any) {
        let selectedRow = quizModePickerView.selectedRow(inComponent: 0)
        let quizMode = QuizMode.allModes[selectedRow]
        deck.mode = quizMode
        
        switch startSegmentedControl.selectedSegmentIndex {
        case 0:
            var quizController = quizMode.getController(with: deck, shouldResume: false)
            quizController.delegate = self
            
            guard let controller = quizController as? UIViewController else { return }
            navigationController?.pushViewController(controller, animated: true)
        default:
            var quizController = quizMode.getController(with: deck, shouldResume: true)
            quizController.delegate = self
            
            guard let controller = quizController as? UIViewController else { return }
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    func resetDeck() {
        let alertController = UIAlertController(title: "Confirm Start Over", message: "Are you sure you want to start this deck over? All progress will be lost.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default) { (action) in
//            self.deckManager.startFromBeginning()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
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
