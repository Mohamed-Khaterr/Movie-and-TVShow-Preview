//
//  ViewController.swift
//  See
//
//  Created by Khater on 10/18/22.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var trendMovieTVCollectionView: UICollectionView!
    @IBOutlet weak var discoverMovieCollectionView: UICollectionView!
    
    private let tmdbClient = TMDBClient()
    
    private var trendMoviesTVs = [Show]()
    private var discoverMovies = [Show]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchTrendingShows()
        fetchDiscoverShows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    deinit {
        print("HomeViewController deniti")
    }
    
    private func setupCollectionView(){
        trendMovieTVCollectionView.register(TrendingShowsCollectionViewCell.nib(), forCellWithReuseIdentifier: TrendingShowsCollectionViewCell.identifier)
        discoverMovieCollectionView.register(CustomCollectionViewCell.nib(), forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
       
        [trendMovieTVCollectionView, discoverMovieCollectionView].forEach { collectionView in
            collectionView?.delegate = self
            collectionView?.dataSource = self
        }
    }
        
        
    @IBAction func discoverButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: DiscoverViewController.identifier, sender: self)
    }
    
    
    private func fetchTrendingShows(){
        tmdbClient.getTrending([.movie, .tv], timeIn: .day){ [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                Alert.show(to: self, message: error.localizedDescription, compeltionHandler: nil)
            case .success(let trends):
                self.trendMoviesTVs = trends
                DispatchQueue.main.async {
                    self.trendMovieTVCollectionView.reloadData()
                }
            }
        }
    }
    

    private func fetchDiscoverShows(){
        tmdbClient.getDiscover(type: .movie, sortBy: .revenueDesc, year: Constant.currentYear){ [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                Alert.show(to: self, message: error.localizedDescription, compeltionHandler: nil)
            case.success(let discovers):
                for discover in discovers {
                    if discover.hasPosterImage && discover.title != nil && discover.genreString != ""{
                        self.discoverMovies.append(discover)
                    }
                }

                DispatchQueue.main.async {
                    self.discoverMovieCollectionView.reloadData()
                }
            }
        }
    }
}



// MARK: - CollectionVeiw DataSource
extension HomeViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (collectionView == trendMovieTVCollectionView) ? trendMoviesTVs.count : discoverMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (collectionView == trendMovieTVCollectionView) ? trendMovieTvCellForRowAt(indexPath: indexPath) : discoverMovieCellForRowAt(indexPath: indexPath)
    }
}



// MARK: - CollectionView Delegate
extension HomeViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Object of Media Details View Controller
        let showDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: ShowDetailsViewController.identifier) as! ShowDetailsViewController
        let navController = UINavigationController(rootViewController: showDetailsVC)
        navController.modalPresentationStyle = .fullScreen
        
        // User Clicked on Trend Movies/TV Show
        if collectionView == trendMovieTVCollectionView{
            // Sending ID and Type of Media (movie or tv)
            // Trends are Movies and TV Shows
            showDetailsVC.detailsOfShow(id: self.trendMoviesTVs[indexPath.row].id,
                                        type: self.trendMoviesTVs[indexPath.row].mediaType!)
        }
        
        
        // User Clicked on Discover Move
        if collectionView == discoverMovieCollectionView{
            // Sending ID and Type of Media (movie or tv)
            // All Discover are Movies
            showDetailsVC.detailsOfShow(id: self.discoverMovies[indexPath.row].id,
                                        type: .movie)
        }
        
        self.present(navController, animated: true, completion: nil)
    }
}
    


// MARK:  Flow layout
extension HomeViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return (collectionView == trendMovieTVCollectionView) ? trendMovieTvLayout() : discoverMovieLayout()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return (collectionView == trendMovieTVCollectionView) ? trendMovieTvMinimumLineSpacing() : discoverMovieMinimumLineSpacing()
    }
}



// MARK: - Trending Collection View
extension HomeViewController{
    func trendMovieTvCellForRowAt(indexPath: IndexPath) -> UICollectionViewCell{
        let cell = trendMovieTVCollectionView.dequeueReusableCell(withReuseIdentifier: TrendingShowsCollectionViewCell.identifier, for: indexPath) as! TrendingShowsCollectionViewCell
        
        let trend = trendMoviesTVs[indexPath.row]
        cell.displayData(trend)
        cell.representedIdentifier = trend.identifier
        trend.getBackdropImage { result in
            if cell.representedIdentifier != trend.identifier { return }
            
            switch result {
            case .failure(let error):
                print(error)
                cell.setImageView(with: nil)
                
            case .success(let data):
                cell.setImageView(with: data)
            }
        }
        
        return cell
    }
    
    
    func trendMovieTvLayout() -> CGSize{
        return CGSize(width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.5)
    }
    
    func trendMovieTvMinimumLineSpacing() -> CGFloat{
        return 0
    }
}



// MARK: - Discover Collection View
extension HomeViewController{
    func discoverMovieCellForRowAt(indexPath: IndexPath) -> UICollectionViewCell{
        let cell = discoverMovieCollectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as! CustomCollectionViewCell
        
        let discoverMovie = self.discoverMovies[indexPath.row]
        cell.displayData(discoverMovie)
        cell.representedIdentifier = discoverMovie.identifier
        discoverMovie.getPosterImage { result in
            if cell.representedIdentifier != discoverMovie.identifier { return }
            switch result {
            case .failure(let error):
                print(error)
                cell.setImageView(with: nil)
                
            case .success(let data):
                cell.setImageView(with: data)
            }
        }
        
        return cell
    }
    
    func discoverMovieLayout() -> CGSize{
        return CGSize(width: view.frame.width / 2.5, height: (view.frame.height * 0.3) - 1)
    }
    
    func discoverMovieMinimumLineSpacing() -> CGFloat{
        return 1
    }
}
