//
//  FilterTestViewController.swift
//  See
//
//  Created by Khater on 10/29/22.
//

import UIKit


class FilterViewController: UIViewController {
    
    static let segueIdentifier = "FilterViewController"
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FilterDelegate?
    
    private var userFilterSelection = Filter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SortingTableViewCell.nib(), forCellReuseIdentifier: SortingTableViewCell.identifiter)
        tableView.register(GenreTableViewCell.nib(), forCellReuseIdentifier: GenreTableViewCell.identifiter)
        tableView.register(RatingTableViewCell.nib(), forCellReuseIdentifier: RatingTableViewCell.identifiter)
        tableView.register(ReleaseDateTableViewCell.nib(), forCellReuseIdentifier: ReleaseDateTableViewCell.identifiter)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func applyButtonPressed(_ sender: UIButton) {
        delegate?.didFinishFiltering(with: userFilterSelection)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        // Default Values
        userFilterSelection.sortby = nil
        userFilterSelection.genreId = nil
        userFilterSelection.rating = nil
        userFilterSelection.year = nil
        
        tableView.reloadData()
    }
    
    func setFilter(_ filter: Filter){
        // To get the previous filter
        self.userFilterSelection = filter
    }
}


// MARK: - TableView Data Source
extension FilterViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SortingTableViewCell.identifiter, for: indexPath) as! SortingTableViewCell
            
            cell.delegate = self
            
            if let sortBy = userFilterSelection.sortby{
                cell.sorted = sortBy
            }else{
                // Default
                cell.sorted = .popularityDesc
            }
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: GenreTableViewCell.identifiter, for: indexPath) as! GenreTableViewCell
            
            if let genreId = userFilterSelection.genreId{
                cell.selectedGenre = TMDB.movieGenre[genreId]!
                
            }else{
                // Default
                cell.selectedGenre = "All"
            }
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: RatingTableViewCell.identifiter, for: indexPath) as! RatingTableViewCell
            
            cell.delegate = self
            
            cell.rates = [
                (rate: 9, isSelected: false),
                (rate: 8, isSelected: false),
                (rate: 7, isSelected: false),
                (rate: 6, isSelected: false),
                (rate: 5, isSelected: false),
            ]

            
            if let selectedRateByUser = userFilterSelection.rating{
                cell.rates.indices.forEach { i in
                    cell.rates[i].rate == selectedRateByUser ? (cell.rates[i].isSelected = true) : (nil)
                }
            }

            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReleaseDateTableViewCell.identifiter, for: indexPath) as! ReleaseDateTableViewCell
            
            cell.delegate = self
            
            
            cell.releaseDates = []
            for i in 0...9{
                cell.releaseDates.append((year: Constant.currentYear - i, isSelected: false))
            }
            
            if let selectedYearByUser = userFilterSelection.year{
                for i in 0..<cell.releaseDates.count{
                    cell.releaseDates[i].year == selectedYearByUser ? (cell.releaseDates[i].isSelected = true) : (nil)
                }
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}


// MARK: - TableView Delegate
extension FilterViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go To Genre View Controller to pick genre
        if indexPath.row == 1{
            let genreVC = GenreTableViewController()
            
            genreVC.delegate = self
            
            if let genreId = userFilterSelection.genreId{
                genreVC.selectedGenre(byID: genreId)
            }else{
                // Default
                genreVC.selectedGenre(byID: 0) // 0 is id of All in Genre.dictionary
            }
            
            self.navigationController?.pushViewController(genreVC, animated: true)
            
            tableView.reloadData()
        }
    }
}


// MARK: - Sorting Delegate
extension FilterViewController: FilterDelegate{
    func didSelectSort(sortBy: TMDB.Sort) {
        print("Sort By \(sortBy.rawValue)")
        userFilterSelection.sortby = sortBy
    }
    
    func didSelectRating(rate: Double) {
        print("Rate \(rate)")
        userFilterSelection.rating = rate
        
        tableView.reloadData()
    }
    
    func didSelectReleaseDate(year: Int) {
        print("Release Date \(year)")
        userFilterSelection.year = year
        
        tableView.reloadData()
    }
    
    func didSelectGenre(_ genreId: Int) {
        print(genreId)
        userFilterSelection.genreId = genreId
        
        tableView.reloadData()
    }
}
