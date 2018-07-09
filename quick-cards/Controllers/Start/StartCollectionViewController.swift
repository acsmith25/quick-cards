//
//  StartCollectionViewController.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class StartCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Decks"
        
        // Register cell classes
        guard let collectionView = collectionView else { return }
        collectionView.register(UINib(nibName: String(describing: DeckCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: DeckCollectionViewCell.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Collection View Data Source
extension StartCollectionViewController {
        
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allDecks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeckCollectionViewCell.identifier, for: indexPath) as? DeckCollectionViewCell else {
            fatalError("Could not dequeue cell.")
        }
        let deck = allDecks[indexPath.row]
        cell.configure(with: deck)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let deck = allDecks[indexPath.row]
        
        let actionSheet = UIAlertController(title: "Quiz Mode", message: "Choose how you would like your flashcards to be presented.", preferredStyle: .actionSheet)
        actionSheet.view.tintColor = GenericSection.quickResume.color
        
        QuizMode.allModes.forEach { (mode) in
            let action = UIAlertAction(title: mode.title, style: .default, handler: { (action) in
                var controller = mode.getController(with: deck)
                controller.delegate = self
                guard let viewController = controller as? UIViewController else { return }
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            actionSheet.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - Deck Collection View Delegate
extension StartCollectionViewController: NavigationDelegate {
    
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
        collectionView?.reloadData()
    }
    
}
