//
//  MarkAsFavorite.swift
//  See
//
//  Created by Khater on 11/2/22.
//

import Foundation


struct MarkFavorite: Encodable{
    //let sessionID: String
    let type: String
    let id: Int
    let favorite: Bool
    
    enum CodingKeys: String, CodingKey{
        //case sessionID = "session_id"
        case type = "media_type"
        case id = "media_id"
        case favorite
    }
}
