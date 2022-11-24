//
//  RequestTokenResponse.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation


struct TokenResponse: Decodable{
    let success: Bool
    let expiresAt: String
    let requestToken: String
    
    enum CodingKeys: String, CodingKey{
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}
