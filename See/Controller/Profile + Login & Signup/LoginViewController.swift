//
//  LoginViewController.swift
//  See
//
//  Created by Khater on 10/31/22.
//

import UIKit

class LoginViewController: UIViewController {
    
    static let identifier = "LoginViewController"
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var hideAndShowButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private let tmdbClient = TMDBClient()
    
    private var username: String = ""
    private var password: String = ""
    
    private lazy var handleGetUserToke: (Error?) -> Void = { [weak self] error in
        guard let self = self else { return }
        if let error = error{
            Alert.show(to: self, title: "Login", message: error.localizedDescription, compeltionHandler: nil)
            self.enableElements(true)
            return
        }
        
        self.tmdbClient.login(username: self.username, password: self.password, compeltionHandler: self.handleLogin)
    }
    
    private lazy var handleLogin: (Error?) -> Void = { [weak self] error in
        guard let self = self else { return }
        if let error = error {
            Alert.show(to: self, title: "Login", message: error.localizedDescription, compeltionHandler: nil)
            self.enableElements(true)
            return
        }
        
        self.tmdbClient.getSessionId(compeltionHandler: self.handleGetSessionID)
    }
    
    private lazy var handleGetSessionID: (Error?) -> Void = { [weak self] error in
        guard let self = self else { return }
        self.enableElements(true)
        
        if let error = error{
            Alert.show(to: self, title: "Login", message: error.localizedDescription, compeltionHandler: nil)
            return
        }
        
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        hideAndShowButton.tintColor = .lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func showAndHidePasswordButtonPressed(_ button: UIButton) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        
        if button.tintColor == .lightGray{
            button.tintColor = .black
        }else{
            button.tintColor = .lightGray
        }
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        enableElements(false)
        username = usernameTextField.text ?? ""
        password = passwordTextField.text ?? ""
        tmdbClient.getUserToken(compeltionHandler: handleGetUserToke)
    }
    
    
    @IBAction func loginViewWebsiteButtonPressed(_ sender: UIButton) {
        tmdbClient.getUserToken { [weak self] error in
            guard let self = self else { return }
            
            if let error = error{
                Alert.show(to: self, title: "Login", message: error.localizedDescription, compeltionHandler: nil)
                self.enableElements(true)
                return
            }
            
            self.tmdbClient.loginViaWebsite()
        }
    }
    
    
    private func enableElements(_ enable: Bool){
        DispatchQueue.main.async {
            self.usernameTextField.isEnabled = enable
            self.passwordTextField.isEnabled = enable
            
            self.loginButton.isEnabled = enable
            
            enable ? (self.loadingIndicator.stopAnimating()) : (self.loadingIndicator.startAnimating())
        }
    }
    
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        self.navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
}


// MARK: - TextField Delegate
extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
