//
//  Client.swift
//  See
//
//  Created by Khater on 11/1/22.
//

import Foundation


struct Client{
    public static var shared = Client()
    private let userDefaults = UserDefaults.standard
    
    private let id = "clientID"
    private let username = "clientUsername"
    private let requestTokenKey = "requestToken"
    private let sessionIdKey = "sessionId"
    
    func setID(_ id: Int){
        userDefaults.set(id, forKey: self.id)
    }
    
    func getID() -> Int{
        return userDefaults.integer(forKey: self.id)
    }
    
    func setUsername(_ username: String){
        userDefaults.set(username, forKey: self.username)
    }
    
    func getUsername() -> String?{
        return userDefaults.string(forKey: self.username)
    }
    
    func setToken(_ token: String){
        userDefaults.set(token, forKey: requestTokenKey)
    }
    
    func getToken() -> String?{
        return userDefaults.string(forKey: requestTokenKey)
    }
    
    func setSessionID(_ sessionID: String){
        userDefaults.set(sessionID, forKey: sessionIdKey)
    }
    
    func getSessionID() -> String?{
        return userDefaults.string(forKey: sessionIdKey)
    }
    
    func isLogin() -> Bool {
        return getSessionID() != nil
    }
    
    func logout(){
        userDefaults.removeObject(forKey: id)
        userDefaults.removeObject(forKey: username)
        userDefaults.removeObject(forKey: requestTokenKey)
        userDefaults.removeObject(forKey: sessionIdKey)
    }
}
