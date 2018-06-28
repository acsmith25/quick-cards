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
        return userDecks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeckCollectionViewCell.identifier, for: indexPath) as? DeckCollectionViewCell else {
            fatalError("Could not dequeue cell.")
        }
        let deck = userDecks[indexPath.row]
        cell.configure(with: deck)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let deck = userDecks[indexPath.row]
        let controller = ViewDeckController(deck: deck)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Deck Collection View Delegate
extension StartCollectionViewController: NavigationDelegate {
    
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
        collectionView?.reloadData()
    }
    
}
