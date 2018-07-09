//
//  StartCollectionViewController.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class AllDecksCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Decks"
        //self.modalPresentationStyle = .
        
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
extension AllDecksCollectionViewController {
        
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
        let startController = StartDeckViewController(deck: deck)
        
//        let width = UIScreen.main.bounds.width / 2
//        let height = UIScreen.main.bounds.height / 2
//        let containerView = UIView(frame: CGRect(x: 0, y: 100, width: width, height: height))
//        containerView.addSubview(startController.view)
//        startController.view.backgroundColor = .blue
        
//        self.view.addSubview(containerView)
        
//        addChildViewController(startController)
//        startController.view.alpha = 0.0
//        startController.view.frame = CGRect(x: 150, y: 150, width: 100, height: 100)
//        startController.view.alpha = 1.0
        self.navigationController?.pushViewController(startController, animated: true)
    }
}

// MARK: - Deck Collection View Delegate
extension AllDecksCollectionViewController: NavigationDelegate {
    
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
        collectionView?.reloadData()
    }
    
}
