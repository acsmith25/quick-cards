//
//  StartDeckViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/9/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class StartDeckViewController: UIViewController {

    @IBOutlet weak var quizModePickerView: UIPickerView!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet var resumeButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet var startButtonBottomConstraint: NSLayoutConstraint!
    
    var deck: Deck
    
    init(deck: Deck) {
        self.deck = deck
        super.init(nibName: String(describing: StartDeckViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.quizModePickerView.dataSource = self
        self.quizModePickerView.delegate = self
        
        // Remove resume button if hasn't been started
        if deck.isInInitialState {
            self.resumeButton.isHidden = true
            view.removeConstraint(resumeButtonBottomConstraint)
            NSLayoutConstraint.activate([
                startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            ])
            updateViewConstraints()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func editAction(_ sender: Any) {
        let controller = NewDeckViewController(isEditing: true)
        navigationController?.pushViewController(controller, animated: true)
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

extension StartDeckViewController: NavigationDelegate {
    func dismissViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension StartDeckViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
