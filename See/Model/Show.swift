//
//  MovieRespnose.swift
//  See
//
//  Created by Khater on 10/20/22.
//

import Foundation


struct Show: Decodable{
    let id: Int
    let title: String? // for Movie
    let name: String? // for TV Show
    let genreIDs: [Int]
    let overview: String
    let language: String
    
    let releaseDate: String? // for Movie
    let firstAirDate: String? // for TV Show
    
    let mediaType: ShowType?
    
    let posterPath: String?
    let backdropPath: String?
    
    let popularity: Double
    let voteAverage: Double
    let voteCount: Int
    
    enum CodingKeys: String, CodingKey{
        case id
        case title
        case name
        case genreIDs = "genre_ids"
        case overview
        case language = "original_language"
        
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        
        case mediaType = "media_type"
        
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    var posterImageCache = NSCache<NSString, NSData>()
    var backdropImageCache = NSCache<NSString, NSData>()
    
    var identifier: String {
        return String(id) + (title ?? name!)
    }
    
    var hasBackdropImage: Bool {
        return backdropPath != nil
    }

    var hasPosterImage: Bool {
        return posterPath != nil
    }
    
    var releaseYear: String {
        return String(releaseDate?.prefix(4) ?? firstAirDate!.prefix(4))
    }
    
    var genreString: String{
        var temp = ""
        for id in genreIDs{
            let genre = (title != nil) ? TMDB.movieGenre[id]! : TMDB.tvShowGenre[id]!
            temp += (temp == "") ? genre : ", \(genre)"
        }
        return temp
    }
    
    var popularityString: String {
        return String(format: "%.1f", popularity)
    }
    
    var voteAverageString: String {
        return String(format: "%.1f", voteAverage)
    }
}



extension Show{
    func getPosterImage(compeltionHanlder: @escaping (Result<Data, Error>) -> Void){
        let posterError = NSError(domain: "Poster Image not found", code: 404, userInfo: [NSLocalizedDescriptionKey: "This Show has no poster (\(self.name ?? self.title!)"])
        
        guard let posterImagePath = posterPath else{
            compeltionHanlder(.failure(posterError))
            return
        }
        
        if let posterImageData = posterImageCache.object(forKey: posterImagePath as NSString){
            compeltionHanlder(.success(posterImageData as Data))
            return
        }
        
        let tmdbClient = TMDBClient()
        
        tmdbClient.downloadImage(withPath: posterImagePath) { result in
            switch result{
            case .failure(let error):
                compeltionHanlder(.failure(error))
                
            case .success(let data):
                self.posterImageCache.setObject(data as NSData, forKey: posterImagePath as NSString)
                compeltionHanlder(.success(data))
            }
        }
    }
    
    func getBackdropImage(compeltionHanlder: @escaping (Result<Data, Error>) -> Void){
        let backdropError = NSError(domain: "Backdrop Image not found", code: 404, userInfo: [NSLocalizedDescriptionKey: "This Show has no backdrop (\(self.name ?? self.title!)"])

        guard let backdropImagePath = backdropPath else {
            compeltionHanlder(.failure(backdropError))
            return
        }
        
        if let backdropImageData = backdropImageCache.object(forKey: backdropImagePath as NSString){
            compeltionHanlder(.success(backdropImageData as Data))
            return
        }
        
        let tmdbClient = TMDBClient()
        
        tmdbClient.downloadImage(withPath: backdropImagePath) { result in
            switch result{
            case .failure(let error):
                compeltionHanlder(.failure(error))
                
            case .success(let data):
                self.backdropImageCache.setObject(data as NSData, forKey: backdropImagePath as NSString)
                compeltionHanlder(.success(data))
            }
        }
    }
}
