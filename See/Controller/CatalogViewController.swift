//
//  CatalogViewController.swift
//  See
//
//  Created by Khater on 10/23/22.
//

import UIKit

class CatalogViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentControl: CustomSegmentControl!
    @IBOutlet weak var pagingCollectionView: PagingCollectionView!
    private var moviesCollectionView: UICollectionView!
    private var tvShowsCollectionView: UICollectionView!
    
    private let tmdbClient = TMDBClient()
    
    private var movies: [Show] = []
    private var tvShows: [Show] = []
    private var moviesPage: Int = 0
    private var tvShowsPage: Int = 0
    private var selectedType: ShowType = .movie
    private var beforeSearchTemp: (type: ShowType, show: [Show])? = nil
    
    private var selectedFilterForMovies: Filter? // Storing the User Filters on Movies
    private var selectedFilterForTVShows: Filter? // Storing the User Filters on TV Shows
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = searchBar
        searchBar.delegate = self

        setupSubCollectionViews()
        setupPagingCollectionView()
        
        fetchMovies {
            self.fetchTVShows(completion: nil)
        }
    }
    
    private func setupSubCollectionViews(){
        moviesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        tvShowsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        moviesCollectionView.register(CustomCollectionViewCell.nib(), forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        tvShowsCollectionView.register(CustomCollectionViewCell.nib(), forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
    }
    
    private func setupPagingCollectionView(){
        pagingCollectionView.pagingDataSource = self
        pagingCollectionView.pagingDelegate = self
        pagingCollectionView.addSubCollectionViews([moviesCollectionView, tvShowsCollectionView])
        pagingCollectionView.segmentControl = segmentControl
        pagingCollectionView.scrollDelegate = self
    }
    
    private func fetchMovies(completion: (() -> Void)?){
        moviesPage += 1
        tmdbClient.getDiscoverWithPagination(type: .movie, page: moviesPage) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                Alert.show(to: self, message: error.localizedDescription, compeltionHandler: nil)
            case .success(let movies):
                for movie in movies {
                    if movie.hasPosterImage{
                        self.movies.append(movie)
                    }
                }
                
                DispatchQueue.main.async {
                    self.moviesCollectionView.reloadData()
                    if let completion = completion {
                        completion()
                    }
                }
            }
        }
    }
    
    
    private func fetchTVShows(completion: (() -> Void)?){
        tvShowsPage += 1
        tmdbClient.getDiscoverWithPagination(type: .tv, page: tvShowsPage) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                Alert.show(to: self, message: error.localizedDescription, compeltionHandler: nil)

            case .success(let tvShows):
                for tvShow in tvShows {
                    if tvShow.hasPosterImage{
                        self.tvShows.append(tvShow)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tvShowsCollectionView.reloadData()
                    if let completion = completion {
                        completion()
                    }
                }
            }
        }
    }
    
    
    @IBAction func filterButtonPressed(_ button: UIBarButtonItem){
        performSegue(withIdentifier: FilterViewController.segueIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier  == FilterViewController.segueIdentifier {
            let filterVC = segue.destination as! FilterViewController

            filterVC.delegate = self
            
            switch selectedType {
            case .movie:
                if let selectedFilterForMovies = selectedFilterForMovies {
                    // Set stored Filters
                    filterVC.setFilter(selectedFilterForMovies)
                }
            case .tv:
                if let selectedFilterForTVShows = selectedFilterForTVShows {
                    // Set stored Filters
                    filterVC.setFilter(selectedFilterForTVShows)
                }
            }
            
        }
    }
    
}



// MARK: - PagingCollectionView Data Source
extension CatalogViewController: PagingCollectionViewDataSource{
    func pagingCollectionView(_ subCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if subCollectionView == moviesCollectionView{
            return movies.count
        }else if subCollectionView == tvShowsCollectionView{
            return tvShows.count
        }
        fatalError("pagingCollectionView(numberOFItemInSection:) unkown collectionView in SavedViewController")
    }
    
    func pagingCollectionView(_ subCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = subCollectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as! CustomCollectionViewCell
        
        if subCollectionView == moviesCollectionView{
            let movie = movies[indexPath.row]
            return setupCell(cell, show: movie)
            
        }else if subCollectionView == tvShowsCollectionView{
            let tv = tvShows[indexPath.row]
            return setupCell(cell, show: tv)
        }
        
        return cell
    }
    
    private func setupCell(_ cell: CustomCollectionViewCell, show: Show) -> CustomCollectionViewCell{
        cell.titleLabel.text = show.name ?? show.title
        cell.genreLabel.text = show.genreString
        
        cell.representedIdentifier = show.identifier
        
        show.getPosterImage { result in
            if cell.representedIdentifier != show.identifier { return }
            
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(let data):
                cell.imageView.image = UIImage(data: data)
            }
            
            cell.loadingIndicator.stopAnimating()
            cell.layoutIfNeeded()
        }
        
        return cell
    }
}



// MARK: - PagingCollectionView Delegate
extension CatalogViewController: PagingCollectionViewDelegate{
    func pagingCollectionView(_ subCollectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Object of Media Details View Controller
        let showDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: ShowDetailsViewController.identifier) as! ShowDetailsViewController
        let navController = UINavigationController(rootViewController: showDetailsVC)
        navController.modalPresentationStyle = .fullScreen
        
        switch selectedType{
        case .movie:
            showDetailsVC.detailsOfShow(id: movies[indexPath.row].id,
                                        type: .movie)
        case .tv:
            showDetailsVC.detailsOfShow(id: tvShows[indexPath.row].id,
                                        type: .tv)
        }
        
        self.present(navController, animated: true, completion: nil)
    }
}



// MARK: - PagingCollectionView FlowLayout Delegate
extension CatalogViewController: PagingCollectionViewDelegateFlowLayout{
    func pagingCollectionView(_ subCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: pagingCollectionView.frame.width / 2, height: (pagingCollectionView.frame.height / 2) + 18)
    }
}



// MARK: - PagingCollectionView Scroll Delegate
extension CatalogViewController: PagingCollectionViewScrollDelegate{
    func pagingCollectionViewDidSelectSubCollectionView(at index: Int) {
        setSelectedType(index: index)
    }
    
    func pagingCollectionViewsDidScrollSubCollectionView(_ scrollView: UIScrollView) {
        let contentHeight = getContentHeightForCurrentCollectionView(scrollViewHeight: scrollView.frame.height)
        let currentPosition = scrollView.contentOffset.y
        
        removeActivityIndicatorFromSuperView()
        if currentPosition == contentHeight{
            addActivityIndicatorToSuperView()
            fetchNewDataForCurrentCollectionView()
        }
    }
    
    private func setSelectedType(index: Int){
        if index == 0 {
            selectedType = .movie
            
        }else if index == 1{
            selectedType = .tv
        }
    }
    
    private func getContentHeightForCurrentCollectionView(scrollViewHeight: CGFloat) -> CGFloat{
        var contentHeight: CGFloat = 0
        switch selectedType{
        case .movie:
            contentHeight = moviesCollectionView.contentSize.height - scrollViewHeight

        case .tv:
            contentHeight = tvShowsCollectionView.contentSize.height - scrollViewHeight
        }
        
        return contentHeight
    }
    
    private func addActivityIndicatorToSuperView(){
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.frame = CGRect(x: 0, y: view.frame.height - 120, width: 50, height: 50)
        loadingIndicator.center.x = view.center.x
        loadingIndicator.tag = 111000
        
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    private func removeActivityIndicatorFromSuperView(){
        view.subviews.forEach { view in
            if view.tag == 111000{
                view.removeFromSuperview()
            }
        }
    }
    
    private func fetchNewDataForCurrentCollectionView(){
        switch selectedType{
        case .movie:
            fetchMovies(){ [weak self] in
                self!.removeActivityIndicatorFromSuperView()
            }
            
        case .tv:
            fetchTVShows(){ [weak self] in
                self!.removeActivityIndicatorFromSuperView()
            }
        }
    }
}



// MARK: - Search Bar Delegate
extension CatalogViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        switch selectedType{
        case .movie:
            beforeSearchTemp = (type: .movie, show: movies)
        case .tv:
            beforeSearchTemp = (type: .tv, show: tvShows)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            switch beforeSearchTemp!.type{
            case .movie:
                movies = beforeSearchTemp!.show
                moviesCollectionView.reloadData()
            case .tv:
                tvShows = beforeSearchTemp!.show
                tvShowsCollectionView.reloadData()
            }
            return
        }
        
        tmdbClient.search(byType: selectedType, text: searchText) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("Search Error: \(error)")
                
            case .success(let shows):
                switch self.selectedType{
                case .movie:
                    self.movies = shows
                    
                    DispatchQueue.main.async {
                        self.moviesCollectionView.reloadData()
                    }
                    
                case .tv:
                    self.tvShows = shows
                    
                    DispatchQueue.main.async {
                        self.tvShowsCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}



// MARK: - Filter Delegate
extension CatalogViewController: FilterDelegate{
    func didFinishFiltering(with filter: Filter) {
        switch selectedType {
        case .movie:
            selectedFilterForMovies = filter
            
        case .tv:
            selectedFilterForTVShows = filter
        }
            
        tmdbClient.getDiscover(type: selectedType, sortBy: filter.sortby, year: filter.year, genreId: filter.genreId, rating: filter.rating){ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                Alert.show(to: self, title: "Filter", message: error.localizedDescription, compeltionHandler: nil)
                
            case .success(let shows):
                var tempShow = [Show]()
                for show in shows{
                    if show.hasPosterImage{
                        tempShow.append(show)
                    }
                }
                switch self.selectedType {
                case .movie:
                    self.movies = tempShow
                    DispatchQueue.main.async {
                        self.moviesCollectionView.reloadData()
                    }
                    
                case .tv:
                    self.tvShows = tempShow
                    DispatchQueue.main.async {
                        self.tvShowsCollectionView.reloadData()
                    }
                }
            }
        }
    }
}
