//
//  DetailMovieResponse.swift
//  See
//
//  Created by Khater on 10/20/22.
//

import Foundation

// Can Be Movie or TV Show
struct ShowDetails: Decodable {
    let id: Int
    
    let title: String?
    let name: String?
    
    let overview: String
    let genres: [DetailsShowGenre]
    
    let numberOfEpisodes: Int?
    let numberOfSeasons: Int?
    
    let status: String
    
    let releaseDate: String?
    let firstAirDate: String?
    
    let posterPath: String?
    let backdropPath: String?
    
    let popularity: Double
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case overview
        case genres
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case status
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    var releaseYear: String {
        return String(releaseDate?.prefix(4) ?? firstAirDate!.prefix(4))
    }
    
    var genreString: String {
        var temp = ""
        for genre in genres {
            temp += (temp == "") ? genre.name : ", \(genre.name)"
        }
        return temp
    }
    
    var popularityString: String {
        return String(format: "%.1f", popularity)
    }
    
    var voteAverageString: String {
        return String(format: "%.1f", voteAverage)
    }
    
    var voteCountString: String {
        return String(voteCount)
    }
    
    var hasBackdropImage: Bool {
        return backdropPath != nil
    }

    var hasPosterImage: Bool {
        return posterPath != nil
    }
    
    func getPosterImage(compeltionHanlder: @escaping (Result<Data, Error>) -> Void){
        let posterError = NSError(domain: "Poster Image not found", code: 404, userInfo: [NSLocalizedDescriptionKey: "This Show has no poster (\(self.name ?? self.title!)"])
        
        guard let posterImagePath = posterPath else{
            compeltionHanlder(.failure(posterError))
            return
        }
        
        let tmdbClient = TMDBClient()
        
        tmdbClient.downloadImage(withPath: posterImagePath) { result in
            switch result{
            case .failure(let error):
                compeltionHanlder(.failure(error))
                
            case .success(let data):
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
        
        let tmdbClient = TMDBClient()
        
        tmdbClient.downloadImage(withPath: backdropImagePath) { result in
            switch result{
            case .failure(let error):
                compeltionHanlder(.failure(error))
                
            case .success(let data):
                compeltionHanlder(.success(data))
            }
        }
    }
}

struct DetailsShowGenre: Decodable{
    let id: Int
    let name: String
}
