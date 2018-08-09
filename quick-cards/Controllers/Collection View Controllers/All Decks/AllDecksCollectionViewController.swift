//
//  StartCollectionViewController.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit
import CustomPopup

class AllDecksCollectionViewController: UICollectionViewController {
    
    // Each section represented as a tuple
    // ("Section title", Section content)
    var sections: [(String, [Deck])] = []
    
    // Pop up protocol properties
    var popUp: PopUpController?
    var gesture: UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Decks"
        
        registerCellsAndViews()
        configureSections()
        addBarButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        dismissPopUp()
        navigationController?.navigationBar.isHidden = false
    }
    
    func registerCellsAndViews() {
        // Cell classes
        guard let collectionView = collectionView else { return }
        collectionView.register(UINib(nibName: String(describing: SingleTitleCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: SingleTitleCollectionViewCell.identifier)
        
        // Header view
        collectionView.register(UINib(nibName: String(describing: SectionHeaderCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.identifier)
    }
    
    func configureSections() {
        // Only include sections that have decks
        if !decksInProgress.isEmpty {
            sections.append(("Decks in Progress", decksInProgress))
        }
        if !userDecks.isEmpty {
            sections.append(("Your Decks", userDecks))
        }
        let decks = allDecks.filter { (deck) -> Bool in
            defaultDecks.contains(where: { $0 == deck })
        }
        sections.append(("Default Decks", decks))
    }
    
    func addBarButtonItem() {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "addIcon"), style: .plain, target: self, action: #selector(newDeckAction))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func newDeckAction() {
        let controller = EditDeckViewController(deck: nil)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
        navigationController?.navigationBar.backgroundColor = .white
    }
}

// MARK: - Collection View Data Source
extension AllDecksCollectionViewController {
        
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].1.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleTitleCollectionViewCell.identifier, for: indexPath) as? SingleTitleCollectionViewCell else {
            fatalError("Could not dequeue cell.")
        }
        let deck = sections[indexPath.section].1[indexPath.row]
        cell.configure(with: deck.title, backgroundColor: .myTeal, textColor: .white)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderCollectionReusableView.identifier, for: indexPath) as? SectionHeaderCollectionReusableView else {
            fatalError("Could not dequeue cell.")
        }
        let header = sections[indexPath.section].0
        view.configure(with: header)
        
        return view
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let deck = sections[indexPath.section].1[indexPath.row]
        
        // Pop up presentation
        let infoController = DeckInfoViewController(deck: deck, isViewingDeck: false)
        infoController.delegate = self
        popUp = PopUpController(popUpView: infoController)
        guard let popUp = popUp else { return }
        popUp.presentPopUp(on: self)
        
        // Add dismiss pop up gesture
        gesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
        gesture?.delegate = self
        guard let gesture = gesture else { return }
        self.view.addGestureRecognizer(gesture)
    }
}

// MARK: - Pop Up
extension AllDecksCollectionViewController: PopUpPresentationController {
    @objc func dismissPopUp() {
        guard let popUp = popUp, let gesture = gesture else { return }
        popUp.dismissSubviews()
        self.view.removeGestureRecognizer(gesture)
    }
}

// MARK: - Gesture Recognizer Delegate
extension AllDecksCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Dismiss pop up on tap outside of pop up view
        guard let popUp = popUp, let view = touch.view else { return false }
        if view.isDescendant(of: popUp.popUpController.view) {
            return false
        }
        return true
    }
}

// MARK: - Navigation Delegate
extension AllDecksCollectionViewController: NavigationDelegate {
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
        collectionView?.reloadData()
    }
}
