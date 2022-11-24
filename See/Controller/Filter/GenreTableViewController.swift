//
//  GenreTableViewController.swift
//  See
//
//  Created by Khater on 10/30/22.
//

import UIKit

class GenreTableViewController: UITableViewController {
    
    static let identifier = "goToFilterGenre"
    
    weak var delegate: FilterDelegate?
    
    private var genres: [(id: Int, name: String, isSelected: Bool)] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyGenreCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    public func selectedGenre(byID id: Int){
        let sortedGenreDictionary = TMDB.movieGenre.sorted(by: {$0.value < $1.value})
        
        for (id, name) in sortedGenreDictionary{
            genres.append((id: id, name: name, isSelected: false))
        }
        
        for i in 0..<genres.count{
            if genres[i].id == id{
                genres[i].isSelected = true
                return
            }
        }
    }
}


// MARK: - TableView Data Source
extension GenreTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  genres.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyGenreCell", for: indexPath)
        
        cell.textLabel?.text = genres[indexPath.row].name
        
        cell.accessoryType = genres[indexPath.row].isSelected ? .checkmark : .none
        
        return cell
    }
}



// MARK: - Table View Delegate
extension GenreTableViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Selecting Genre
        genres.indices.forEach({ genres[$0].isSelected = false }) // Make all not selected
        
        genres[indexPath.row].isSelected = true
                
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
        delegate?.didSelectGenre(genres[indexPath.row].id)
        navigationController?.popViewController(animated: true)
    }
}
