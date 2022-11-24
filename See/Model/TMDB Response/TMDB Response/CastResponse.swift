//
//  CastResponse.swift
//  See
//
//  Created by Khater on 10/25/22.
//

import Foundation


struct CastResponse: Decodable{
    let id: Int
    let cast: [Cast]
    let crew: [Cast]
}
