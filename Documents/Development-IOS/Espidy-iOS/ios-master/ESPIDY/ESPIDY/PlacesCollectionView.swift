//
//  PlacesCollectionView.swift
//  ESPIDY
//
//  Created by FreddyA on 9/26/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

protocol PlacesColletionViewDelegate: class {
    func didSelectedCell(_ placePrediction: GMSAutocompletePrediction)
}

class PlacesColletionView: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var delegate: PlacesColletionViewDelegate?
    
    var isVisible = false
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.delaysContentTouches = false
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 44
    
    var places: [GMSAutocompletePrediction]?
    
    weak var mainViewController: MainViewController?
    
    func showPlaces() {
        if let window = UIApplication.shared.keyWindow {
            
            isVisible = true
            window.addSubview(collectionView)
            
            var countPlaces = 0
            if places!.count > 3 {
                countPlaces =  3
            } else {
                countPlaces = places!.count
            }
            let height: CGFloat = CGFloat(countPlaces) * cellHeight
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .transitionCrossDissolve, animations: {
                
                self.collectionView.frame = CGRect(x: 8, y: 176, width: window.frame.width - 16, height: height)
                
                }, completion: nil)
        }
    }
    
    func handleDismiss() {
        isVisible = false
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .transitionCrossDissolve, animations: {
            self.collectionView.alpha = 0
        }) { (completed: Bool) in
            self.collectionView.removeFromSuperview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return places!.count
        if places!.count > 3 {
            return 3
        } else {
            return places!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PlacesCell
        
        let place = places![indexPath.item]
        cell.place = place
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let place = self.places![indexPath.item]
        delegate?.didSelectedCell(place)
    }
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(PlacesCell.self, forCellWithReuseIdentifier: cellId)
    }
    
}
