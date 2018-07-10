//
//  StartCollectionViewController.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import UIKit

class AllDecksCollectionViewController: UICollectionViewController {
    
    var sections: [(String, [Deck])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Decks"
        
        configureSections()
        
        // Register cell classes
        guard let collectionView = collectionView else { return }
        collectionView.register(UINib(nibName: String(describing: SingleTitleCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: SingleTitleCollectionViewCell.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureSections() {
        if !userDecks.isEmpty {
            sections.append(("Your Decks", userDecks))
        }
        if !decksInProgress.isEmpty {
            sections.append(("Decks in Progress", decksInProgress))
        }
        sections.append(("Default Decks", allDecks))
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
        cell.configure(with: deck)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let deck = sections[indexPath.section].1[indexPath.row]
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let x = self.view.frame.minX
        let y = self.view.frame.minY
        
        let dimmerView = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        dimmerView.backgroundColor = .black
        dimmerView.alpha = 0.25
        
        let startView = StartDeckViewController(deck: deck)
        startView.view.bounds = CGRect(x: x, y: y, width: width/1.25, height: 300)
        startView.view.layer.cornerRadius = 5
        startView.view.layer.shadowOffset = CGSize(width: 0, height: 11)
        startView.view.layer.shadowOpacity = 0.15
        startView.view.layer.shadowRadius = 13
        
        self.view.addSubview(dimmerView)
        self.view.addSubview(startView.view)
        self.addChildViewController(startView)
        startView.view.center = self.view.center
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissSubviews(_:)))
        self.view.addGestureRecognizer(gesture)
        
//        let deck = sections[indexPath.section].1[indexPath.row]
//        let startController = StartDeckViewController(deck: deck)
//        self.navigationController?.pushViewController(startController, animated: true)
    }
    
    @objc func dismissSubviews(_ sender: UITapGestureRecognizer) {
        //dismiss subviews here
    }
}

// MARK: - Deck Collection View Delegate
extension AllDecksCollectionViewController: NavigationDelegate {
    
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
        collectionView?.reloadData()
    }
    
}
