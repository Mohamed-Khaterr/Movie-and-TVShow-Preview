//
//  TMDBClient.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation
import UIKit


final class TMDBClient{
    
    private let networkManager = ApiManager()
    
    private var isPaginate: Bool = false
    
    
    // MARK: - User Auth
    func getUserToken(compeltionHandler: @escaping (Error?) -> Void){
        let url = ApiManager.EndPoint.requestToken.url
        
        networkManager.prefromTask(with: url, type: TokenResponse.self) { result in
            switch result{
            case.failure(let error):
                compeltionHandler(error)
                
            case .success(let response):
                Client.shared.setToken(response.requestToken)
                compeltionHandler(nil)
            }
        }
    }
    
    
    func login(username: String, password: String, compeltionHandler: @escaping (Error?) -> Void){
        let url = ApiManager.EndPoint.login.url
        let userToken = Client.shared.getToken()!
        let parameter = LoginRequest(username: username, password: password, requestToken: userToken)
        
        let request = networkManager.createURLRequest(with: url, method: .post, parameter: parameter)
        
        networkManager.prefromTask(with: request, type: TokenResponse.self) { result in
            switch result {
            case .failure(let error):
                compeltionHandler(error)
                
            case .success(let response):
                let newToken = response.requestToken
                Client.shared.setToken(newToken)
                compeltionHandler(nil)
            }
        }
    }
    
    
    func loginViaWebsite(){
        let userToken = Client.shared.getToken()!
        let url = ApiManager.EndPoint.websiteLogin(token: userToken).url
        
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func getSessionId(compeltionHandler: @escaping (Error?) -> Void){
        let url = ApiManager.EndPoint.requestSessionId.url
        let userToken = Client.shared.getToken()!
        let parameter = SessionIdRequest(requestToken: userToken)
        let request = networkManager.createURLRequest(with: url, method: .post, parameter: parameter)
        
        networkManager.prefromTask(with: request, type: SessionIDResponse.self) { [weak self] result in
            switch result {
            case .failure(let error):
                compeltionHandler(error)

            case .success(let response):
                Client.shared.setSessionID(response.sessionId)
                self?.getAccountInfo(completionHandler: compeltionHandler)
            }
        }
    }
    
    // This func calles in getSessionId when user loged in auto get account info
    func getAccountInfo(completionHandler: @escaping (Error?) -> Void){
        let userSessionID = Client.shared.getSessionID()!
        let url = ApiManager.EndPoint.accountInfo(sessionId: userSessionID).url
        
        networkManager.prefromTask(with: url, type: Account.self) { result in
            switch result {
            case .failure(let error):
                completionHandler(error)
                
            case .success(let response):
                Client.shared.setID(response.id)
                Client.shared.setUsername(response.username)
                completionHandler(nil)
            }
        }
    }
    
    
    func logout(compeltionHandler: @escaping (Error?) -> Void){
        let url = ApiManager.EndPoint.logout.url
        let userSessionID = Client.shared.getSessionID()!
        let parameter = LogoutRequest(sessionId: userSessionID)
        let request = networkManager.createURLRequest(with: url, method: .delete, parameter: parameter)
        
        networkManager.prefromTask(with: request, type: LogoutResponse.self) { result in
            switch result {
            case .failure(let error):
                compeltionHandler(error)
                
            case .success(let response):
                if response.success {
                    compeltionHandler(nil)
                    Client.shared.logout()
                } else {
                    let logoutError = NSError(domain: "Logout Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Logout failed, Please try again later."])
                    compeltionHandler(logoutError)
                }
            }
        }
    }
    
    
    
    // MARK: - Image Data
    func downloadImage(withPath imagePath: String, compeltionHandler: @escaping (Result<Data, Error>) -> Void){
        let url = ApiManager.EndPoint.image(imagePath).url
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...3)) {
                guard let data = data, error == nil else {
                    compeltionHandler(.failure(error ?? NSError(domain: "NO Data", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data found"])))
                    return
                }
                compeltionHandler(.success(data))
            }
        }.resume()
    }
    
    
    
    // MARK: - Movies & TV Shows Data
    func getTrending(_ type: [ShowType], timeIn: TMDB.TimeWindow, compeltionHandler: @escaping (Result<[Show], Error>) -> Void){
        let url = ApiManager.EndPoint.trending(type: type, timeIn: timeIn).url
        
        networkManager.prefromTask(with: url, type: ShowResponse.self) { result in
            switch result {
            case .failure(let error):
                compeltionHandler(.failure(error))
                
            case .success(let response):
                var temp = [Show]()
                
                for result in response.results {
                    if result.hasBackdropImage {
                        temp.append(result)
                    }
                }
                
                let trends = temp
                
                compeltionHandler(.success(trends))
            }
        }
    }
    
    
    func getDiscover(type: ShowType, page: Int? = nil, sortBy: TMDB.Sort? = nil, year: Int? = nil, genreId: Int? = nil, rating: Double? = nil, compeltionHandler: @escaping (Result<[Show], Error>) -> Void){
        let url = ApiManager.EndPoint.discover(type: type, page: page, sortBy: sortBy, year: year, genreId: genreId, rating: rating).url
        
        networkManager.prefromTask(with: url, type: ShowResponse.self) { result in
            switch result {
            case .failure(let error):
                compeltionHandler(.failure(error))

            case .success(let response):
                compeltionHandler(.success(response.results))
            }
        }
    }
    
    
    func getDiscoverWithPagination(type: ShowType, page: Int? = nil, sortBy: TMDB.Sort? = nil, year: Int? = nil, compeltionHandler: @escaping (Result<[Show], Error>) -> Void){
        // no request when pagination is true
        if isPaginate { return }
        isPaginate = true

        let url = ApiManager.EndPoint.discover(type: type, page: page, sortBy: sortBy, year: year).url
        
        networkManager.prefromTask(with: url, type: ShowResponse.self) { [weak self] result in
            guard let self = self else { return }
            
            self.isPaginate = false
            
            switch result {
            case .failure(let error):
                compeltionHandler(.failure(error))
                
            case .success(let showResponse):
                compeltionHandler(.success(showResponse.results))
            }
        }
    }
    
    

    func getDetailsOfTheShow(id: Int, type: ShowType, compeltionHandler: @escaping (Result<ShowDetails, Error>) -> Void){
        let url = ApiManager.EndPoint.details(id: id, type: type).url
        networkManager.prefromTask(with: url, type: ShowDetails.self) { result in
            switch result {
            case .failure(let error):
                compeltionHandler(.failure(error))
                
            case .success(let showDetails):
                compeltionHandler(.success(showDetails))
            }
        }

    }
    
    
    
    func getShowTrailerVideo(id: Int, type: ShowType, compeltionHandler: @escaping (Result<ShowVideo, Error>) -> Void){
        let url = ApiManager.EndPoint.videos(id: id, type: type).url
        networkManager.prefromTask(with: url, type: ShowVideosResponse.self) { result in
            switch result {
            case .failure(let error):
                compeltionHandler(.failure(error))

            case .success(let videoResponse):
                if videoResponse.results.isEmpty {
                    let emptyError = NSError(domain: "Trailer Video", code: 404, userInfo: [NSLocalizedDescriptionKey: "No videos for this \(type.rawValue)"])
                    compeltionHandler(.failure(emptyError))
                    return
                }
                
                if let videoOffset = videoResponse.results.firstIndex(where: { $0.name == "Official"}) {
                    // Get Official Video Trailer from Array
                    let officialVideo = videoResponse.results[videoOffset]
                    compeltionHandler(.success(officialVideo))
                    
                }else{
                    // Get First Video Trailer in Array
                    let firstVideo = videoResponse.results[0]
                    compeltionHandler(.success(firstVideo))
                }
            }
        }
    }
    
    
    
    func getCastInTheShow(mediaID id: Int, type: ShowType, compeltionHandler: @escaping (Result<[Cast], Error>) -> Void){
        let url = ApiManager.EndPoint.cast(id: id, type: type).url
        networkManager.prefromTask(with: url, type: CastResponse.self) { result in
            switch result {
            case .failure(let error):
                compeltionHandler(.failure(error))
                
            case .success(let castResponse):
                let allCast = castResponse.crew + castResponse.cast
                
                // Remove Dublicate from cast
                var uniqueAllCast = [Cast]()
                for cast in allCast{
                    if !uniqueAllCast.contains(where: { $0.id == cast.id }){
                        uniqueAllCast.append(cast)
                    }
                }
                
                let sortedAllCast = uniqueAllCast.sorted(by: { $0.department < $1.department })
                
                compeltionHandler(.success(sortedAllCast))
            }
        }
    }
    
    
    
    func getSimilarShows(id: Int, type: ShowType, compeltionHandler: @escaping (Result<[Show], Error>) -> Void){
        let url = ApiManager.EndPoint.similar(id: id, type: type).url
        networkManager.prefromTask(with: url, type: ShowResponse.self) { result in
            switch result {
            case .failure(let error):
                compeltionHandler(.failure(error))

            case .success(let showResponse):
                compeltionHandler(.success(showResponse.results))
            }
        }
    }
    
    
    
    func search(byType type: ShowType, text: String, compeltionHandler: @escaping (Result<[Show], Error>) -> Void){
        let query = text.replacingOccurrences(of: " ", with: "+")
        
        let url = ApiManager.EndPoint.search(type: type, query: query).url
        
        networkManager.prefromTask(with: url, type: ShowResponse.self) { result in
            switch result {
            case .failure(let error):
                compeltionHandler(.failure(error))
                
            case .success(let showResponse):
                compeltionHandler(.success(showResponse.results))
            }
        }
    }
    
    
    
    func getShowStatus(id: Int, type: ShowType, completionHandler: @escaping (Result<ShowStatus, Error>) -> Void){
        let userSessionID = Client.shared.getSessionID()!
        let url = ApiManager.EndPoint.showStatus(type: type.rawValue, id: id, sessionID: userSessionID).url
        networkManager.prefromTask(with: url, type: ShowStatus.self){ result in
            completionHandler(result)
        }
    }
    
    
    
    func markFavorite(type: ShowType, id: Int, mark: Bool, completionHandler: @escaping (Error?) -> Void){
        let userSessionID = Client.shared.getSessionID()!
        let userID = Client.shared.getID()
        let url = ApiManager.EndPoint.markFavorite(accountID: userID, sessionID: userSessionID).url
        let parameter = MarkFavorite(type: type.rawValue, id: id, favorite: mark)
        let request = networkManager.createURLRequest(with: url, method: .post, parameter: parameter)
        networkManager.prefromTask(with: request, type: TMDBError.self) { result in
            switch result {
            case .failure(let error):
                completionHandler(error)
            case .success(let tmdbResponse):
                if let success = tmdbResponse.success, success == true {
                    completionHandler(nil)
                }else{
                    completionHandler(tmdbResponse)
                }
            }
        }
    }
    
    
    
    func markWatchlist(type: ShowType, id: Int, mark: Bool, completionHandler: @escaping (Error?) -> Void){
        let userSessionID = Client.shared.getSessionID()!
        let userID = Client.shared.getID()
        let url = ApiManager.EndPoint.markWatchlist(accountID: userID, sessionID: userSessionID).url
        let parameter = MarkWatchlist(type: type.rawValue, id: id, watchlist: mark)
        let request = networkManager.createURLRequest(with: url, method: .post, parameter: parameter)
        networkManager.prefromTask(with: request, type: TMDBError.self) { result in
            switch result {
            case .failure(let error):
                completionHandler(error)
            case .success(let tmdbResponse):
                if let success = tmdbResponse.success, success == true {
                    completionHandler(nil)
                }else{
                    completionHandler(tmdbResponse)
                }
            }
        }
    }
    
    
    
    func rateTheShow(type: ShowType, id: Int, rate: Bool, completionHandler: @escaping (Error?) -> Void){
        let userSessionID = Client.shared.getSessionID()!
        let url = ApiManager.EndPoint.rate(type: type.rawValue, showID: id, sessionID: userSessionID).url
        let parameter = Rate(value: 10)
        let method: ApiManager.RequestMethod = rate ? .post : .delete
        let request = networkManager.createURLRequest(with: url, method: method, parameter: parameter)
        networkManager.prefromTask(with: request, type: TMDBError.self) { result in
            switch result {
            case .failure(let error):
                completionHandler(error)
            case .success(let tmdbResponse):
                if let success = tmdbResponse.success, success == true {
                    completionHandler(nil)
                }else{
                    completionHandler(tmdbResponse)
                }
            }
        }
    }
    
    
    
    func getFavoriteShows(type: ShowType,completionHandler: @escaping (Result<[Show], Error>) -> Void){
        let userSessionID = Client.shared.getSessionID()!
        let userID = Client.shared.getID()
        let url = ApiManager.EndPoint.favoriteShows(accountID: userID, type: type.rawValue, sessionID: userSessionID).url
        networkManager.prefromTask(with: url, type: ShowResponse.self) { result in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
                
            case .success(let showResponse):
                completionHandler(.success(showResponse.results))
            }
        }
    }
    
    
    
    func getWatchlistShows(type: ShowType,completionHandler: @escaping (Result<[Show], Error>) -> Void){
        let userSessionID = Client.shared.getSessionID()!
        let userID = Client.shared.getID()
        let url = ApiManager.EndPoint.watchlistShows(accountID: userID, type: type.rawValue, sessionID: userSessionID).url
        networkManager.prefromTask(with: url, type: ShowResponse.self) { result in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
                
            case .success(let showResponse):
                completionHandler(.success(showResponse.results))
            }
        }
    }
}
