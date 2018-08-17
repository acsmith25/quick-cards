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

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var inOrderButton: UIButton!
    @IBOutlet weak var difficultyButton: UIButton!
    @IBOutlet weak var timedButton: UIButton!
    @IBOutlet weak var notTimedButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var freeformButton: UIButton!
    @IBOutlet weak var multipleChoiceButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timedView: UIView!
    
    @IBOutlet weak var separatorView1: UIView!
    @IBOutlet weak var separatorView2: UIView!
    @IBOutlet weak var separatorView3: UIView!
    @IBOutlet weak var separatorView4: UIView!
    @IBOutlet weak var separatorHeight1: NSLayoutConstraint!
    @IBOutlet weak var separatorHeight2: NSLayoutConstraint!
    @IBOutlet weak var separatorHeight3: NSLayoutConstraint!
    @IBOutlet weak var separatorHeight4: NSLayoutConstraint!
    
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
        
        titleLabel.text = "\(deck.title)"
        
        if #available(iOS 10.0, *) {
            // Blur background if available
            view.backgroundColor = UIColor(white: 1, alpha: 0.85)
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurEffectView, at: 0)
        }
        
        configureButtons()
        configureSeparators()
        
        // Remove resume option if hasn't been started
        if deck.progressCounter == 0 {
            stackView.removeArrangedSubview(resumeButton)
            resumeButton.removeFromSuperview()
            resumeButton.isHidden = true
            
            stackView.removeArrangedSubview(separatorView1)
            separatorView1.removeFromSuperview()
            separatorView1.isHidden = true
            
            startButton.setTitle("Start", for: .normal)
        }
    }
    
    func configureButtons() {
        orderButtons = [randomButton, inOrderButton, difficultyButton]
        orderButtons.forEach { (button) in
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.myTeal.cgColor
            button.layer.cornerRadius = 5.0
            if button.tag == deck.order.rawValue {
                button.layer.backgroundColor = UIColor.myTeal.cgColor
            } else {
                button.layer.backgroundColor = UIColor.clear.cgColor
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
                button.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
        
        timedButtons = [notTimedButton, timedButton]
        configureTimedButtons(isActive: newTime)
    }
    
    func configureTimedButtons(isActive: Bool) {
        if isActive {
            let value = deck.isTimed ? 0 : 1
            timedButtons.forEach { (button) in
                button.layer.borderWidth = 1.0
                button.layer.borderColor = UIColor.myTeal.cgColor
                button.layer.cornerRadius = 5.0
                if button.tag == value {
                    button.layer.backgroundColor = UIColor.myTeal.cgColor
                } else {
                    button.layer.backgroundColor = UIColor.clear.cgColor
                }
                button.isEnabled = true
            }
        } else {
            timedButtons.enumerated().forEach { (index, button) in
                button.layer.borderWidth = 1.0
                button.layer.borderColor = UIColor.lightGray.cgColor
                button.layer.cornerRadius = 5.0
                button.layer.backgroundColor = index == 0 ? UIColor.lightGray.cgColor : UIColor.clear.cgColor
                button.isEnabled = false
            }
        }
    }
    
    func configureSeparators() {
        // Set separator color to native table view color
        let tempTableView = UITableView()
        let separatorColor = tempTableView.separatorColor
        
        separatorView1.backgroundColor = separatorColor
        separatorHeight1.constant = 1.0 / UIScreen.main.nativeScale
        separatorView2.backgroundColor = separatorColor
        separatorHeight2.constant = 1.0 / UIScreen.main.nativeScale
        separatorView3.backgroundColor = separatorColor
        separatorHeight3.constant = 1.0 / UIScreen.main.nativeScale
        separatorView4.backgroundColor = separatorColor
        separatorHeight4.constant = 1.0 / UIScreen.main.nativeScale
    }
    
    // MARK: - Actions
    
    @IBAction func modeButtonAction(_ sender: UIButton) {
        modeButtons.forEach { (button) in
            if button.tag == sender.tag {
                button.layer.backgroundColor = UIColor.myTeal.cgColor
            } else {
                button.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
        newMode = QuizMode(rawValue: sender.tag) ?? .showAnswer
        switch newMode {
        case .showAnswer, .grid:
            configureTimedButtons(isActive: false)
        default:
            configureTimedButtons(isActive: true)
        }
    }
    
    @IBAction func timedAction(_ sender: UIButton) {
        timedButtons.forEach { (button) in
            if button.tag == sender.tag {
                button.layer.backgroundColor = UIColor.myTeal.cgColor
            } else {
                button.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
        newTime = sender.tag == 1 ? true : false
    }
    
    @IBAction func orderButtonAction(_ sender: UIButton) {
        orderButtons.forEach { (button) in
            if button.tag == sender.tag {
                button.layer.backgroundColor = UIColor.myTeal.cgColor
            } else {
                button.layer.backgroundColor = UIColor.clear.cgColor
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
        deck.reset()
        
        deck.updateMode(quizMode: newMode)
        deck.updateTimed(isTimed: newTime)
        deck.updateOrder(order: newOrder)
        var quizController = deck.quizMode.getController(with: deck)
        quizController.delegate = self
        
        guard let controller = quizController as? UIViewController else { return }
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func resumeAction(_ sender: Any) {
        if isViewingDeck {
            guard let parent = parent as? PopUpPresentationController else { return }
            if newMode == deck.quizMode && newOrder == deck.order && newTime == deck.isTimed {
                parent.dismissPopUp()
                return
            }
            if newMode == deck.quizMode {
                deck.updateTimed(isTimed: newTime)
                deck.updateOrder(order: newOrder)
                parent.dismissPopUp()
                return
            }
        }
        
        deck.updateMode(quizMode: newMode)
        deck.updateTimed(isTimed: newTime)
        deck.updateOrder(order: newOrder)
        var quizController = deck.quizMode.getController(with: deck)
        quizController.delegate = self
        
        guard let controller = quizController as? UIViewController else { return }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
    }
    
    func resetDeck() {
        let alertController = UIAlertController(title: "Confirm Start Over", message: "Are you sure you want to start this deck over? All progress will be lost.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default) { (action) in
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

}

// MARK: - Navigation Delegate
extension DeckInfoViewController: NavigationDelegate {
    func dismissViewController() {
            navigationController?.popToRootViewController(animated: true)
    }
}
