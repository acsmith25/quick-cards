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
    var sections: [(String, GenericSection)] = [("", .newDeck), ("", .startDeck), ("Progress", .allDecks)]
    
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
        tableView.register(UINib(nibName: String(describing: TableTableViewCell.self), bundle: nil), forCellReuseIdentifier: TableTableViewCell.identifier)
        tableView.register(UINib(nibName: String(describing: DeckTableViewCell.self), bundle: nil), forCellReuseIdentifier: DeckTableViewCell.identifier)
    }
}

// MARK: - Table View Data Source
extension HomeTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].1.rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section].1
        switch section {
        case .newDeck:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as? ImageTableViewCell else {
                fatalError("Could not dequeue cell.")
            }
            cell.selectionStyle = .none
            cell.configure(with: section.rawValue, image: section.icon, color: section.color) {
                let controller = NewDeckViewController(nibName: String(describing: NewDeckViewController.self), bundle: nil)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return cell
        case .startDeck:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as? ImageTableViewCell else {
                fatalError("Could not dequeue cell.")
            }
            cell.selectionStyle = .none
            cell.configure(with: section.rawValue, image: section.icon, color: section.color) {
                let controller = StartCollectionViewController(nibName: String(describing: StartCollectionViewController.self), bundle: nil)
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return cell
        case .allDecks:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DeckTableViewCell.identifier, for: indexPath) as? DeckTableViewCell else {
                fatalError("Could not dequeue cell.")
            }
            let deck = userDecks[indexPath.row]
            let title = deck.title
            let subtitle = "\(deck.mastery)% Mastered"
            cell.configure(with: title, subtitle: subtitle)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section].1
        switch section {
        case .allDecks:
            let deck = userDecks[indexPath.row]
            let controller = ViewDeckController(deck: deck)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        default:
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections[section].0 != "" {
            // Section has a title
            return 40
        } else {
            return 20
        }
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
