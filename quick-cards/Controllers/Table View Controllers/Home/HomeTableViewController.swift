//
//  HomeTableViewController.swift
//  quick-cards
//
//  Created by Abby Smith on 6/25/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

protocol NavigationDelegate {
    func dismissViewController()
}

class HomeTableViewController: UITableViewController {
    
    // Each section represented as a tuple
    // ("Section title", Section content)
    var sections: [(String, GenericSection)] = [("", .newDeck), ("", .startDeck)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        
        self.title = "Quick Cards"
        
        registerCells()
        configureSections()
        addBarButtonItem()
        
        self.tableView.estimatedRowHeight = 300
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .white
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func registerCells() {
        tableView.register(UINib(nibName: String(describing: RightImageWithTitleTableViewCell.self), bundle: nil), forCellReuseIdentifier: RightImageWithTitleTableViewCell.identifier)
        tableView.register(UINib(nibName: String(describing: ButtonTableViewCell.self), bundle: nil), forCellReuseIdentifier: ButtonTableViewCell.identifier)
        tableView.register(UINib(nibName: String(describing: CollectionTableViewCell.self), bundle: nil), forCellReuseIdentifier: CollectionTableViewCell.identifier)
        tableView.register(UINib(nibName: String(describing: TableTableViewCell.self), bundle: nil), forCellReuseIdentifier: TableTableViewCell.identifier)
        tableView.register(UINib(nibName: String(describing: LeftTitleRightSubtitleTableViewCell.self), bundle: nil), forCellReuseIdentifier: LeftTitleRightSubtitleTableViewCell.identifier)
    }
    
    func addBarButtonItem() {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "profileIcon"), style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func configureSections() {
        if !decksInProgress.isEmpty {
            sections.append(("Quick Resume", .quickResume))
        }
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RightImageWithTitleTableViewCell.identifier, for: indexPath) as? RightImageWithTitleTableViewCell else {
                fatalError("Could not dequeue cell.")
            }
            cell.selectionStyle = .none
            cell.configure(with: section.rawValue, image: section.icon, color: section.color) {
                let controller = EditDeckViewController(isEditing: false)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return cell
        case .startDeck:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RightImageWithTitleTableViewCell.identifier, for: indexPath) as? RightImageWithTitleTableViewCell else {
                fatalError("Could not dequeue cell.")
            }
            cell.selectionStyle = .none
            cell.configure(with: section.rawValue, image: section.icon, color: section.color) {
                let controller = AllDecksCollectionViewController(nibName: String(describing: AllDecksCollectionViewController.self), bundle: nil)
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return cell
        case .quickResume:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LeftTitleRightSubtitleTableViewCell.identifier, for: indexPath) as? LeftTitleRightSubtitleTableViewCell else {
                fatalError("Could not dequeue cell.")
            }
            let deck = decksInProgress[indexPath.row]
            let title = deck.title
            let subtitle = "\(deck.mastery)% Mastered"
            cell.configure(with: title, subtitle: subtitle)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section].1
        switch section {
        case .quickResume:
            let deck = decksInProgress[indexPath.row]
            let controller = TypeAnswerViewController(deck: deck, shouldResume: true)
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
            return 16
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}

// MARK: - View Deck Controller Delegate
extension HomeTableViewController: NavigationDelegate {
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
}
