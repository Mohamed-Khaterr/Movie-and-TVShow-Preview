//
//  SessionIdRequest.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation


struct SessionIdRequest: Encodable{
    let requestToken: String
    
    enum CodingKeys: String, CodingKey{
        case requestToken = "request_token"
    }
}
