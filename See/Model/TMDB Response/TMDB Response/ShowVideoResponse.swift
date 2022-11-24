//
//  ShowVideoResponse.swift
//  See
//
//  Created by Khater on 10/25/22.
//

import Foundation

struct ShowVideosResponse: Decodable{
    let id: Int
    let results: [ShowVideo]
}
