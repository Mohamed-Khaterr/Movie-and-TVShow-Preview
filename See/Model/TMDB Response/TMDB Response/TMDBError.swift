//
//  ErrorResponse.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation


struct TMDBError: Decodable{
    let success: Bool?
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey{
        case success
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

extension TMDBError: LocalizedError{
    var errorDescription: String?{
        return statusMessage
    }
}
