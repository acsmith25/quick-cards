//
//  HomeTableViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 6/25/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    // Each section represented as a tuple
    // ("Section title", Section content)
    var sections: [(String, GenericCell)] = [("", .newDeck), ("", .startDeck), ("All Decks", .allDecks)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Quick Cards"
        
        registerCells()
        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: String(describing: ImageTableViewCell.self), bundle: nil), forCellReuseIdentifier: ImageTableViewCell.identifier)
        tableView.register(UINib(nibName: String(describing: ButtonTableViewCell.self), bundle: nil), forCellReuseIdentifier: ButtonTableViewCell.identifier)
        tableView.register(UINib(nibName: String(describing: CollectionTableViewCell.self), bundle: nil), forCellReuseIdentifier: CollectionTableViewCell.identifier)
    }
}

// MARK: - Table View Data Source
extension HomeTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section].1
        switch section {
        case .newDeck, .startDeck:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as? ImageTableViewCell else {
                fatalError("Could not dequeue cell.")
            }
            cell.configure(with: section.rawValue, image: section.icon, color: section.color)
            return cell
        case .allDecks:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell.identifier, for: indexPath) as? CollectionTableViewCell else {
                fatalError("Could not dequeue cell.")
            }
            cell.configure(with: allDecks) { (deck) in
                let controller = ViewDeckController(deck: deck)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections[section].0 != "" {
            // Section has a title
            return 40
        } else {
            return 20
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
}

// MARK: - View Deck Controller Delegate
extension HomeTableViewController: ViewDeckControllerDelegate {
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}
