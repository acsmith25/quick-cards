//
//  StartCollectionViewController.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class StartCollectionViewController: UICollectionViewController {
    
    var allDecks = [ones, twos, threes, fours, fives, sixes, sevens, eights, nines, tens, elevens, twelves]
    
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
        let controller = ViewDeckController(deck: deck)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - Deck Collection View Delegate
extension StartCollectionViewController: ViewDeckControllerDelegate {
    
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
    
}
