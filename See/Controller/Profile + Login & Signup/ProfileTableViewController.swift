//
//  ProfileTableViewController.swift
//  See
//
//  Created by Khater on 11/1/22.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private let tmdbClient = TMDBClient()
    
    private var isLogin = false
    private var isLogoutPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLogin = Client.shared.isLogin()
        tableView.reloadData()
    }
}


// MARK: - TableView Data Source
extension ProfileViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        
        switch indexPath.row{
        case 0:
            cell.textLabel?.text = "Application settings"
            cell.accessoryType = .disclosureIndicator
            
        case 1:
            
            if isLogin{
                cell.textLabel?.text = "Log out"
                cell.imageView?.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
                
                
            }else{
                cell.textLabel?.text = "Login"
                cell.imageView?.image = UIImage(systemName: "rectangle.lefthalf.inset.filled.arrow.left")
            }
            
            cell.imageView?.tintColor = UIColor(named: Constant.blackColorName)
            
        default:
            fatalError()
        }
        
        return cell
    }
}



// MARK: - TableView Delegate
extension ProfileViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            // Go to application settings
        }
        
        if indexPath.row == 1{
            if isLogin{
                logout()
            }else{
                // Navigate To Login Page
                self.performSegue(withIdentifier: LoginViewController.identifier, sender: self)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func logout() {
        if isLogoutPressed { return }
        isLogoutPressed = true
        loadingIndicator.startAnimating()
        tmdbClient.logout { [weak self] error in
            guard let self = self else { return }
            
            if error != nil {
                Alert.show(to: self, message: error!.localizedDescription, compeltionHandler: nil)
                return
            }
            
            self.isLogin = false
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.isLogoutPressed = false
                self.tableView.reloadData()
            }
        }
    }
}



// MARK: - TableView Header
extension ProfileViewController{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !isLogin{ return nil }
        
        let headerView = UIView()
        
        let profileImageView: UIImageView = {
            let imageView = UIImageView(frame: CGRect(x: self.view.center.x - 50,
                                                      y: 24,
                                                      width: 100,
                                                      height: 100))
            imageView.image = Constant.defaultUIImage()
            imageView.tintColor = UIColor(named: Constant.blackColorName)
            imageView.cornerRadius()
            
            return imageView
        }()
        
        let usernameLabe: UILabel = {
            let label = UILabel(frame: CGRect(x: self.view.center.x - 250,
                                              y: profileImageView.frame.origin.y + profileImageView.frame.height + 18,
                                              width: 500,
                                              height: 20))
            label.text = Client.shared.getUsername()
            label.font = UIFont(name: "Inter-Medium", size: 20)
            label.textColor = UIColor(named: Constant.blackColorName)
            label.textAlignment = .center
            
            return label
        }()
        
        headerView.addSubview(profileImageView)
        headerView.addSubview(usernameLabe)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isLogin ? CGFloat(self.view.frame.width / 2) : CGFloat(0)
    }
}
