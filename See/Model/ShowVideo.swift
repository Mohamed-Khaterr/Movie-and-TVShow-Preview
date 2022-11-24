//
//  MovieVideo.swift
//  See
//
//  Created by Khater on 10/22/22.
//

import Foundation

struct ShowVideo: Decodable{
    let name: String
    let youtubeKey: String
    let id: String
    
    enum CodingKeys: String, CodingKey{
        case name
        case youtubeKey = "key"
        case id
    }
}
