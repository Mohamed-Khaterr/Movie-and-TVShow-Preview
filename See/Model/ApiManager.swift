//
//  ApiManager.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation
import UIKit


final class ApiManager{
    private static let api = Hidden.apiKey
    
    enum EndPoint{
        private static let baseURL = "https://api.themoviedb.org/3"
        private static let apiKey = "?api_key=\(ApiManager.api)"
        private static let imageBaseURL = "https://image.tmdb.org/t/p/original"
        
        
        case requestToken
        case login
        case websiteLogin(token: String)
        case requestSessionId
        case accountInfo(sessionId: String)
        case logout
        case image(String)
        case discover(type: ShowType, page: Int? = nil, sortBy: TMDB.Sort? = nil, year: Int? = nil, genreId: Int? = nil, rating: Double? = nil)
        case trending(type: [ShowType], timeIn: TMDB.TimeWindow)
        case topRated(type: ShowType)
        case details(id: Int, type: ShowType)
        case cast(id: Int, type: ShowType)
        case videos(id: Int, type: ShowType)
        case similar(id: Int, type: ShowType)
        case search(type: ShowType, query: String)
        case showStatus(type: String, id: Int, sessionID: String)
        case markFavorite(accountID: Int, sessionID: String)
        case markWatchlist(accountID: Int, sessionID: String)
        case rate(type: String, showID: Int, sessionID: String)
        case favoriteShows(accountID: Int, type: String, sessionID: String)
        case watchlistShows(accountID: Int, type: String, sessionID: String)
        
        
        private var stringURL: String{
            switch self {
            case .requestToken:
                return EndPoint.baseURL + "/authentication/token/new" + EndPoint.apiKey
                
            case .login:
                return EndPoint.baseURL + "/authentication/token/validate_with_login" + EndPoint.apiKey
                
            case .websiteLogin(token: let token):
                return "https://www.themoviedb.org/authenticate/" + token + "?redirect_to=khaterMovieApp:authenticate"
                
            case .requestSessionId:
                return EndPoint.baseURL + "/authentication/session/new" + EndPoint.apiKey
                
            case .accountInfo(sessionId: let sessionId):
                return EndPoint.baseURL + "/account" + EndPoint.apiKey + "&session_id=\(sessionId)"
                
            case .logout:
                return EndPoint.baseURL + "/authentication/session" + EndPoint.apiKey
                
            // MARK: Access without Auth
            case .image(let filePath):
                return EndPoint.imageBaseURL + filePath
                
                
            // MARK: Access Data without Auth
            case .discover(type: let type, page: let page, sortBy: let sort, year: let year, genreId: let genreId, rating: let rating):
                var tempExtraParameter: String = ""
                tempExtraParameter += (sort != nil)    ? "&sort_by=\(sort!.rawValue)"          : ""
                tempExtraParameter += (year != nil)    ? "&with_release_type=1&year=\(year!)" : ""
                tempExtraParameter += (page != nil)    ? "&page=\(page!)"                      : ""
                tempExtraParameter += (genreId != nil) ? "&with_genres=\(genreId!)"            : ""
                tempExtraParameter += (rating != nil)  ? "&vote_average.gte=\(rating!)"        : ""
                
                return EndPoint.baseURL + "/discover" + "/\(type.rawValue)" + EndPoint.apiKey + tempExtraParameter
                
                
            case .trending(type: let type, timeIn: let timeIn):
                let tempTypeString = (type.count > 1) ? "all" : type[0].rawValue
                
                return EndPoint.baseURL + "/trending" + "/\(tempTypeString)" + "/\(timeIn.rawValue)" + EndPoint.apiKey
                
            case .topRated(let type):
                return EndPoint.baseURL + "/\(type.rawValue)" + "/top_rated" + EndPoint.apiKey
                
            case .details(let id, let type):
                return EndPoint.baseURL + "/\(type.rawValue)" + "/\(id)" + EndPoint.apiKey
                
            case .cast(id: let id, type: let type):
                return EndPoint.baseURL + "/\(type.rawValue)" + "/\(id)" + "/credits" + EndPoint.apiKey
                
            case .videos(id: let id, type: let type):
                return EndPoint.baseURL + "/\(type.rawValue)" + "/\(id)" + "/videos" + EndPoint.apiKey
                
            case .similar(id: let id, type: let type):
                return EndPoint.baseURL + "/\(type.rawValue)" + "/\(id)" + "/similar" + EndPoint.apiKey
                
            case .search(type: let type, query: let query):
                return EndPoint.baseURL + "/search" + "/\(type)" + EndPoint.apiKey + "&query=\(query)"
                
            case .showStatus(type: let type, id: let id, sessionID: let sessionID):
                return EndPoint.baseURL + "/\(type)" + "/\(id)" + "/account_states" + EndPoint.apiKey  + "&session_id=\(sessionID)"
                
            case .markFavorite(accountID: let accountID, sessionID: let sessionID):
                return EndPoint.baseURL + "/account" + "/\(accountID)" + "/favorite" + EndPoint.apiKey + "&session_id=\(sessionID)"
                
            case .markWatchlist(accountID: let accountID, sessionID: let sessionID):
                return EndPoint.baseURL + "/account" + "/\(accountID)" + "/watchlist" + EndPoint.apiKey + "&session_id=\(sessionID)"
                
            case .rate(type: let type, showID: let showID, sessionID: let sessionID):
                return EndPoint.baseURL + "/\(type)" + "/\(showID)" + "/rating" + EndPoint.apiKey + "&session_id=\(sessionID)"
                
            case .favoriteShows(accountID: let accountID, type: let type, sessionID: let sessionID):
                let showType = (type == "movie") ? "movies" : "tv"
                return EndPoint.baseURL + "/account/\(accountID)/favorite/\(showType)" + EndPoint.apiKey + "&session_id=\(sessionID)"
                
            case .watchlistShows(accountID: let accountID, type: let type, sessionID: let sessionID):
                let showType = (type == "movie") ? "movies" : "tv"
                return EndPoint.baseURL + "/account/\(accountID)/watchlist/\(showType)" + EndPoint.apiKey + "&session_id=\(sessionID)"
            }
        }
        
        public var url: URL{
            return URL(string: self.stringURL)!
        }
    }
    
    
    
    enum RequestMethod: String{
        case post = "POST"
        case get = "GET"
        case delete = "DELETE"
    }
}




// MARK: - Fetching Functions
extension ApiManager{
    public func prefromTask<ResponseType: Decodable>(with url: URL, type: ResponseType.Type, compeltionHandler: @escaping (Result<ResponseType, Error>) -> Void){
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                compeltionHandler(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "Preform Task with URL", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data found!"])
                compeltionHandler(.failure(noDataError))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(type, from: data)
                compeltionHandler(.success(decodedData))
                
            } catch {
                print("Error Decode TMDB Data:", error)
                do {
                    let errorDescription = try JSONDecoder().decode(TMDBError.self, from: data)
                    compeltionHandler(.failure(errorDescription))
                } catch {
                    print("Error Decode TMDB Error:", error)
                }
            }
        }
        
        task.resume()
    }
    
    
    public func prefromTask<ResponseType: Decodable>(with request: URLRequest, type: ResponseType.Type, compeltionHandler: @escaping (Result<ResponseType, Error>) -> Void){
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                compeltionHandler(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "Preform Task with URLRequest", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data found!"])
                compeltionHandler(.failure(noDataError))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(type, from: data)
                compeltionHandler(.success(decodedData))
                
            } catch {
                print("Error Decode TMDB Data:", error)
                do {
                    let errorDescription = try JSONDecoder().decode(TMDBError.self, from: data)
                    compeltionHandler(.failure(errorDescription))
                } catch {
                    print("Error Decode TMDB Error:", error)
                }
            }
        }
        
        task.resume()
    }
    
    
    
    public func createURLRequest<ParametersType: Encodable>(with url: URL, method: RequestMethod, parameter: ParametersType) -> URLRequest{
        var request = URLRequest(url: url)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = method.rawValue
        
        request.httpBody = try! JSONEncoder().encode(parameter)
        
        return request
    }
}
