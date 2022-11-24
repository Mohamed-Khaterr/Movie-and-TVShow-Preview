//
//  Filter.swift
//  See
//
//  Created by Khater on 10/31/22.
//

import Foundation

// Used only in FilterViewController and CatalogeViewController
struct Filter{
    var sortby: TMDB.Sort?
    var genreId: Int?
    var rating: Double?
    var year: Int?
}
