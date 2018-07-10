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
