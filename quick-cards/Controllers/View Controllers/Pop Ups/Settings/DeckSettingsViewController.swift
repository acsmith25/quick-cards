//
//  EditDeckViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 7/12/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class DeckSettingsViewController: UIViewController {

    @IBOutlet weak var deckLabel: UILabel!
    @IBOutlet weak var masteredLabel: UILabel!
    
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func editAction(_ sender: Any) {
        let controller = EditDeckViewController(isEditing: true)
        navigationController?.pushViewController(controller, animated: true)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    @IBAction func restartAction(_ sender: Any) {
//        let selectedRow = quizModePickerView.selectedRow(inComponent: 0)
//        let quizMode = QuizMode.allModes[selectedRow]
        
//        var quizController = quizMode.getController(with: deck, shouldResume: false)
//        quizController.delegate = self
//        
//        guard let controller = quizController as? UIViewController else { return }
//        navigationController?.pushViewController(controller, animated: true)
    }
}
