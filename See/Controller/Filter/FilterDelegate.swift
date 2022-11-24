//
//  FilterDelegate.swift
//  See
//
//  Created by Khater on 10/30/22.
//

import Foundation

protocol FilterDelegate: AnyObject{
    func didSelectSort(sortBy: TMDB.Sort)
    func didSelectRating(rate: Double)
    func didSelectReleaseDate(year: Int)
    func didSelectGenre(_ genreId: Int)
    
    func didFinishFiltering(with filter: Filter)
}

extension FilterDelegate {
    func didSelectSort(sortBy: TMDB.Sort){}
    func didSelectRating(rate: Double){}
    func didSelectReleaseDate(year: Int){}
    func didSelectGenre(_ genreId: Int){}
    
    func didFinishFiltering(with filter: Filter){}
}
