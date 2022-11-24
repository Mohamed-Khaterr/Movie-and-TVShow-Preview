//
//  CastResponse.swift
//  See
//
//  Created by Khater on 10/21/22.
//

import Foundation

struct Cast: Decodable{
    let id: Int
    let name: String
    let department: String
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey{
        case id
        case name
        case department = "known_for_department"
        case profilePath = "profile_path"
    }
    
    let profileImageCache = NSCache<NSString, NSData>()
    
    var identifier: String {
        return String(id) + name
    }
    
    func getProfileImage(compeltionHanlder: @escaping (Result<Data, Error>) -> Void){
        let profileError = NSError(domain: "Profile Image not found", code: 404, userInfo: [NSLocalizedDescriptionKey: "no profile Image"])
        
        guard let profileImagePath = profilePath else{
            compeltionHanlder(.failure(profileError))
            return
        }
        
        if let profileImageData = profileImageCache.object(forKey: profileImagePath as NSString){
            compeltionHanlder(.success(profileImageData as Data))
            return
        }
        
        let tmdbClient = TMDBClient()
        
        tmdbClient.downloadImage(withPath: profileImagePath) { result in
            switch result{
            case .failure(let error):
                compeltionHanlder(.failure(error))
                
            case .success(let data):
                self.profileImageCache.setObject(data as NSData, forKey: profileImagePath as NSString)
                compeltionHanlder(.success(data))
            }
        }
    }
}
