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
    
    var popUpVC: UIViewController?
    var dimmerView: UIView?
    var gesture: UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Decks"
        
        registerCellsAndViews()
        configureSections()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func registerCellsAndViews() {
        // Cell classes
        guard let collectionView = collectionView else { return }
        collectionView.register(UINib(nibName: String(describing: SingleTitleCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: SingleTitleCollectionViewCell.identifier)
        
        // Header view
        collectionView.register(UINib(nibName: String(describing: SectionHeaderCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SectionHeaderCollectionReusableView.identifier)
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
        presentStartDeckPopup(for: deck)
    }
    
    func presentStartDeckPopup(for deck: Deck) {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        dimmerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        guard let dimmerView = dimmerView else { return }
        dimmerView.backgroundColor = .black
        dimmerView.alpha = 0.25
        
        popUpVC = StartDeckViewController(deck: deck)
        guard let popUp = popUpVC else { return }
        popUp.view.bounds = CGRect(x: 0, y: 0, width: width/1.25, height: deck.isInInitialState ? height/3 - 50 : height)
        popUp.view.layer.cornerRadius = 10
        popUp.view.layer.shadowOffset = CGSize(width: 0, height: 11)
        popUp.view.layer.shadowOpacity = 0.15
        popUp.view.layer.shadowRadius = 13
        
        self.view.addSubview(dimmerView)
//        navigationController?.view.addSubview(dimmerView)
        self.view.addSubview(popUp.view)
//        navigationController?.view.addSubview(popUp.view)
//        dimmerView.addSubview(popUp.view)
//        self.addChildViewController(popUp)
        popUp.view.center = self.view.center
        popUp.view.alpha = 0
//        popUp.view.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
        
        UIView.animate(withDuration: 0.2) {
            dimmerView.alpha = 0.25
//            popUp.view.transform = CGAffineTransform(scaleX: width, y: height)
            popUp.view.alpha = 1
        }
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(dismissSubviews(_:)))
        guard let gesture = gesture else { return }
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func dismissSubviews(_ sender: UITapGestureRecognizer) {
        //dismiss subviews here
        guard let popUp = popUpVC, let dimmerView = dimmerView else { return }
        UIView.animate(withDuration: 0.2, animations: {
            dimmerView.alpha = 0
            popUp.view.alpha = 0
        }) { (completion) in
            dimmerView.removeFromSuperview()
            popUp.view.removeFromSuperview()
            popUp.removeFromParentViewController()
        }
        guard let gesture = gesture else { return }
        self.view.removeGestureRecognizer(gesture)
    }
}

// MARK: - Deck Collection View Delegate
extension AllDecksCollectionViewController: NavigationDelegate {
    
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
        collectionView?.reloadData()
    }
    
}
