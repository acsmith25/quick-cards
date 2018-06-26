//
//  TableTableViewCell.swift
//  quick-cards
//
//  Created by Abby Smith on 6/26/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class TableTableViewCell: UITableViewCell {
    static let identifier = "TABLE_TABLE_CELL"
    
    @IBOutlet weak var tableView: UITableView!
    
    var decks: [DeckManager] = []
    var action: ((Deck) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: String(describing: DeckTableViewCell.self), bundle: nil), forCellReuseIdentifier: DeckTableViewCell.identifier)
    }

    func configure(with decks: [DeckManager], action: ((Deck) -> Void)? = nil) {
        self.decks = decks
        self.action = action
    }
    
}

// MARK: - Table View Delegate
extension TableTableViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let action = action {
            action(decks[indexPath.row].deck)
        }
    }
    
}

// MARK: - Table View Data Source
extension TableTableViewCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DeckTableViewCell.identifier, for: indexPath) as? DeckTableViewCell else {
            fatalError("Could not dequeue cell.")
        }
        let title = decks[indexPath.row].deck.title
        let subtitle = "\(decks[indexPath.row].calculateMastery())% Mastered"
        cell.configure(with: title, subtitle: subtitle)
        return cell
    }
}
