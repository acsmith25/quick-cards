//
//  StartDeckViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/9/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit
import CustomPopup

class DeckInfoViewController: UIViewController {

    @IBOutlet weak var masteredLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startSegmentedControl: UISegmentedControl!
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var inOrderButton: UIButton!
    @IBOutlet weak var difficultyButton: UIButton!
    @IBOutlet weak var timedButton: UIButton!
    @IBOutlet weak var notTimedButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var freeformButton: UIButton!
    @IBOutlet weak var multipleChoiceButton: UIButton!
    
    var deck: Deck
    var isViewingDeck: Bool
    
    var delegate: NavigationDelegate?
    var orderButtons: [UIButton] = []
    var modeButtons: [UIButton] = []
    var timedButtons: [UIButton] = []
    
    var newMode: QuizMode
    var newOrder: QuestionOrder
    var newTime: Bool
    
    init(deck: Deck, isViewingDeck: Bool) {
        self.deck = deck
        self.newTime = deck.isTimed
        self.newMode = deck.quizMode
        self.newOrder = deck.order
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
        
        orderButtons = [randomButton, inOrderButton, difficultyButton]
        orderButtons.forEach { (button) in
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.myTeal.cgColor
            button.layer.cornerRadius = 5.0
            if button.tag == deck.order.rawValue {
                button.layer.backgroundColor = UIColor.myTeal.cgColor
            } else {
                button.layer.backgroundColor = UIColor.white.cgColor
            }
        }
        
        modeButtons = [flipButton, typeButton, freeformButton, multipleChoiceButton]
        modeButtons.forEach { (button) in
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.myTeal.cgColor
            button.layer.cornerRadius = 5.0
            if button.tag == deck.quizMode.rawValue {
                button.layer.backgroundColor = UIColor.myTeal.cgColor
            } else {
                button.layer.backgroundColor = UIColor.white.cgColor
            }
        }
        
        timedButtons = [notTimedButton, timedButton]
        let value = deck.isTimed ? 1 : 0
        timedButtons.forEach { (button) in
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.myTeal.cgColor
            button.layer.cornerRadius = 5.0
            if button.tag == value {
                button.layer.backgroundColor = UIColor.myTeal.cgColor
            } else {
                button.layer.backgroundColor = UIColor.white.cgColor
            }
        }
        
        // Remove resume option if hasn't been started
        if deck.progressCounter == 0 {
            startSegmentedControl.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction func modeButtonAction(_ sender: UIButton) {
        modeButtons.forEach { (button) in
            if button.tag == sender.tag {
                button.layer.backgroundColor = UIColor.myTeal.cgColor
            } else {
                button.layer.backgroundColor = UIColor.white.cgColor
            }
        }
        newMode = QuizMode(rawValue: sender.tag) ?? .showAnswer
    }
    
    @IBAction func timedAction(_ sender: UIButton) {
        timedButtons.forEach { (button) in
            if button.tag == sender.tag {
                button.layer.backgroundColor = UIColor.myTeal.cgColor
            } else {
                button.layer.backgroundColor = UIColor.white.cgColor
            }
        }
        newTime = sender.tag == 1 ? true : false
    }
    
    @IBAction func orderButtonAction(_ sender: UIButton) {
        orderButtons.forEach { (button) in
            if button.tag == sender.tag {
                button.layer.backgroundColor = UIColor.myTeal.cgColor
            } else {
                button.layer.backgroundColor = UIColor.white.cgColor
            }
        }
        newOrder = QuestionOrder(rawValue: sender.tag) ?? .random
    }
    
    @IBAction func editAction(_ sender: Any) {
        let controller = EditDeckViewController(deck: deck)
        controller.delegate = self.delegate
        navigationController?.pushViewController(controller, animated: true)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    @IBAction func startDeckAction(_ sender: Any) {
        if startSegmentedControl.isHidden { startSegmentedControl.selectedSegmentIndex = 1 }
        
        switch startSegmentedControl.selectedSegmentIndex {
        case 0:
            // Resume
            if isViewingDeck {
                guard let parent = parent as? PopUpPresentationController else { return }
                if newMode == deck.quizMode && newOrder == deck.order && newTime == deck.isTimed {
//                    delegate?.dismissViewController()
                    parent.dismissPopUp()
                    return
                }
                
                if newMode == deck.quizMode {
                    deck.updateTimed(isTimed: newTime)
                    deck.updateOrder(order: newOrder)
                    parent.dismissPopUp()
//                    delegate?.dismissViewController()
                    return
                }
            }

            deck.updateMode(quizMode: newMode)
            deck.updateTimed(isTimed: newTime)
            deck.updateOrder(order: newOrder)
            
            var quizController = deck.quizMode.getController(with: deck, shouldResume: true)
            quizController.delegate = self
            
            guard let controller = quizController as? UIViewController else { return }
            navigationController?.pushViewController(controller, animated: true)
            return
        default:
            // Restart
            deck.reset()
//            if !startSegmentedControl.isHidden {
//                if newMode == deck.mode && newOrder == deck.order && newTime == deck.timed {
//                    delegate?.dismissViewController()
//                    return
//                }
//            }
            deck.updateMode(quizMode: newMode)
            deck.updateTimed(isTimed: newTime)
            deck.updateOrder(order: newOrder)
            var quizController = deck.quizMode.getController(with: deck, shouldResume: false)
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
