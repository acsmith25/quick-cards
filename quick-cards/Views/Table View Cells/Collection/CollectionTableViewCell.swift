//
//  CollectionTableViewCell.swift
//  quick-cards
//
//  Created by Abby Smith on 6/25/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {
    static let identifier = "COLLECTION_TABLE_CELL"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var decks: [Deck] = []
    var action: ((Deck) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: (String(describing: SingleTitleCollectionViewCell.self)), bundle: nil), forCellWithReuseIdentifier: SingleTitleCollectionViewCell.identifier)
    }
    
    func configure(with decks: [Deck], action: ((Deck) -> Void)? = nil) {
        self.decks = decks
        self.action = action
    }
    
}

// MARK: - Collection View Delegate
extension CollectionTableViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let action = action {
            action(decks[indexPath.row])
        }
    }

}

// MARK: - Collection View Data Source
extension CollectionTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return decks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleTitleCollectionViewCell.identifier, for: indexPath) as? SingleTitleCollectionViewCell else {
            fatalError("Could not dequeue deck collection cell.")
        }
        cell.configure(with: decks[indexPath.row].title)
        return cell
    }
    
}
