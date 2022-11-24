//
//  Media.swift
//  See
//
//  Created by Khater on 11/2/22.
//

import Foundation


struct TMDB{
    static let movieGenre: [Int: String] = [
        0: "All",
        12: "Adventure",
        14: "Fantasy",
        16: "Animation",
        18: "Drama",
        27: "Horror",
        28: "Action",
        35: "Comedy",
        36: "History",
        37: "Western",
        53: "Thriller",
        80: "Crime",
        99: "Documentary",
        878: "Sci-Fi",
        9648: "Mystery",
        10402: "Music",
        10749: "Romance",
        10751: "Family",
        10752: "War",
        10770: "TV Movie",
    ]
    
    static let tvShowGenre: [Int: String] = [
        10759: "Action & Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        10762: "Kids",
        9648: "Mystery",
        10763: "News",
        10764: "Reality",
        10765: "Sci-Fi & Fantasy",
        10766: "Soap",
        10767: "Talk",
        10768: "War & Politics",
        37: "Western",
    ]
    
    
    enum Sort: String{
        case popularityAsc = "popularity.asc"
        case popularityDesc = "popularity.desc"
        case releaseDateDesc = "release_date.desc"
        case releaseDateAsc = "release_date.asc"
        case revenueAsc = "revenue.asc"
        case revenueDesc = "revenue.desc"
        case primaryReleaseDateAsc = "primary_release_date.asc"
        case primaryReleaseDateDesc = "primary_release_date.desc"
        case originalTitleAsc = "original_title.asc"
        case originalTitleDesc = "original_title.desc"
        case voteAverageAsc = "vote_average.asc"
        case voteAverageDesc = "vote_average.desc"
        case voteCountAsc = "vote_count.asc"
        case voteCountDesc = "vote_count.desc"
    }
    
    
    
    enum TimeWindow: String{
        case day = "day"
        case week = "week"
    }
    
}
