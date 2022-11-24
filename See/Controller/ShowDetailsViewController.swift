//
//  MediaViewController.swift
//  See
//
//  Created by Khater on 10/20/22.
//

import UIKit
import WebKit

class ShowDetailsViewController: UIViewController {

    static let identifier = "ShowDetailsViewController"
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var loadingIndicatorForHeaderImage: UIActivityIndicatorView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearAndGenreLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var watchlistButton: UIButton!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var tvShowEpisodeSeasonMainView: UIView!
    @IBOutlet weak var tvShowEpisodeSeasonView: UIView!
    @IBOutlet weak var tvShowEpisodeSeasonLabel: UILabel!
    
    @IBOutlet weak var trailerImageView: UIImageView!
    @IBOutlet weak var trailerWebKitView: WKWebView!
    @IBOutlet weak var trailerLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateCountLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    
    @IBOutlet weak var popularityView: UIView!
    @IBOutlet weak var popularityNumberLabel: UILabel!
    
    @IBOutlet weak var similarHeaderTitleSectionLabel: UILabel!
    
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var similarMediaCollectionView: UICollectionView!
    
    private let tmdbClient = TMDBClient()
    
    private var cast = [Cast]()
    private var similarShows = [Show]()
    
    // received media data from sender View Controller
    private var showId: Int?
    private var showType: ShowType?
    
    private var isLogin: Bool = false
    
    private var isInWatchlist: Bool = false
    private var isFavorite: Bool = false
    private var isRated: Bool = false
    
    public func detailsOfShow(id: Int, type: ShowType){
        self.showId = id
        self.showType = type
        
        print("Media ID: \(id), \nMeida Type: \(type)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionViews()
        fetchData()
        
        isLogin = Client.shared.isLogin()
        if isLogin {
            fetchUserStatus()
        }
    }
    
    deinit {
        print("ShowDetailsViewController deniti")
    }
}



// MARK: - Setup
extension ShowDetailsViewController{
    private func setupCollectionViews(){
        castCollectionView.register(CastCollectionViewCell.nib(), forCellWithReuseIdentifier: CastCollectionViewCell.identifier)
        similarMediaCollectionView.register(CustomCollectionViewCell.nib(), forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        
        [castCollectionView, similarMediaCollectionView].forEach { collectioView in
            collectioView?.delegate = self
            collectioView?.dataSource = self
        }
    }
    
    private func setupUI(){
        setupNavigationBar()
        setupTopImageSection()
        setupOverViewSection()
        setupTrailerSection()
        setupRatingSection()
    }
    
    private func setupNavigationBar(){
        navigationController?.hidesBarsOnSwipe = true
        
        [backButton, shareButton].forEach { button in
            button?.cornerRadius()
            button?.alpha = 0.5
        }
    }
    
    private func setupTopImageSection(){
        loadingIndicatorForHeaderImage.startAnimating()
        gradientView.makeGradientLayer()
        favoriteButton.setImage(UIImage(named: Constant.favourite), for: .normal)
        watchlistButton.setImage(UIImage(named: Constant.bookmark), for: .normal)
    }
    
    private func setupOverViewSection(){
        overviewLabel.text = "overview"
        
        tvShowEpisodeSeasonView.cornerRadius(10)
        tvShowEpisodeSeasonMainView.isHidden = true
    }
    
    private func setupTrailerSection(){
        trailerImageView.cornerRadius(20)
        trailerWebKitView.cornerRadius(20)
        trailerWebKitView.layer.masksToBounds = true
        trailerWebKitView.isHidden = true
        trailerLoadingIndicator.startAnimating()
        
        trailerWebKitView.navigationDelegate = self
    }
    
    private func setupRatingSection(){
        ratingView.cornerRadius(15)
        rateButton.cornerRadius(10)
        rateButton.setImage(UIImage(systemName: Constant.star), for: .normal)
        popularityView.cornerRadius(15)
    }
}



// MARK: - Buttons Actions
extension ShowDetailsViewController{
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        guard let id = showId, let type = showType?.rawValue, let title = titleLabel.text else { return }
        let showTitle = title.lowercased()
        // Remove Special Characters From ShowName
        let titlWithoutSpecialCahracters = showTitle.replacingOccurrences(of: "[^A-Za-z0-9]", with: "-", options: .regularExpression, range: nil)
        let showURL = URL(string: "https://www.themoviedb.org/\(type)/\(id)-\(titlWithoutSpecialCahracters)")!
        let shareSheetVC = UIActivityViewController(activityItems: [showURL], applicationActivities: nil)
        present(shareSheetVC, animated: true, completion: nil)
    }
    
    @IBAction func watchlistButtonPresses(_ button: UIButton) {
        if showLoginMessage(title: "Watch List") { return }
        
        watchlistButton.isEnabled = false
        tmdbClient.markWatchlist(type: showType!, id: showId!, mark: !isInWatchlist) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                Alert.show(to: self, title: "Watch List", message: error.localizedDescription, compeltionHandler: nil)
                return
            }
            self.updateWatchListButton(userInteraction: true, value: !self.isInWatchlist)
        }
    }
    
    
    @IBAction func favoriteButoonPressed(_ button: UIButton) {
        if showLoginMessage(title: "Favorite") { return }
        
        favoriteButton.isEnabled = false
        tmdbClient.markFavorite(type: showType!, id: showId!, mark: !isFavorite) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                Alert.show(to: self, title: "Favorite", message: error.localizedDescription, compeltionHandler: nil)
                return
            }
            self.updateFavoriteButton(userInteraction: true, value: !self.isFavorite)
        }
    }
    
    
    @IBAction func ratingButtonPresses(_ sender: UIButton) {
        if showLoginMessage(title: "Rating") { return }
        
        rateButton.isEnabled = false
        tmdbClient.rateTheShow(type: showType!, id: showId!, rate: !isRated) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                Alert.show(to: self, title: "Rating", message: error.localizedDescription, compeltionHandler: nil)
                return
            }
            self.updateRatingButton(userInteraction: true, value: !self.isRated)
        }
    }
    
    private func showLoginMessage(title: String) -> Bool{
        if !isLogin {
            Alert.show(to: self, title: title, message: "You need to login first", compeltionHandler: nil)
            return true
        }else{
            return false
        }
    }
    
    private func updateWatchListButton(userInteraction: Bool, value isInWatchlist: Bool){
        self.isInWatchlist = isInWatchlist
        if userInteraction{
            let message = isInWatchlist ? "Added to watch list successfully" : "Removed from watch list successfully"
            Alert.successMessage(to: self, message: message)
        }
        
        DispatchQueue.main.async {
            self.watchlistButton.isEnabled = true
            
            if isInWatchlist{
                self.watchlistButton.setImage(UIImage(named: Constant.bookmarkFill), for: .normal)
            }else{
                self.watchlistButton.setImage(UIImage(named: Constant.bookmark), for: .normal)
            }
        }
    }
    
    private func updateFavoriteButton(userInteraction: Bool, value isFavorite: Bool){
        self.isFavorite = isFavorite
        if userInteraction{
            let message = isFavorite ? "Added to favorite successfully" : "Removed from favorite successfully"
            Alert.successMessage(to: self, message: message)
        }
        
        DispatchQueue.main.async {
            self.favoriteButton.isEnabled = true
            
            if isFavorite{
                self.favoriteButton.setImage(UIImage(named: Constant.favouriteFill), for: .normal)
            }else{
                self.favoriteButton.setImage(UIImage(named: Constant.favourite), for: .normal)
            }
        }
    }
    
    private func updateRatingButton(userInteraction: Bool, value isRated: Bool){
        self.isRated = isRated
        if userInteraction{
            let message = isRated ? "The \(self.showType!.rawValue) is Rated successfully" : "The \(self.showType!.rawValue) unrated successfully"
            Alert.successMessage(to: self, message: message)
        }
        
        DispatchQueue.main.async {
            self.rateButton.isEnabled = true
            
            if isRated{
                self.rateButton.setImage(UIImage(systemName: Constant.starFill), for: .normal)
                self.rateButton.setTitle("Rated", for: .normal)
            }else{
                self.rateButton.setImage(UIImage(systemName: Constant.star), for: .normal)
                self.rateButton.setTitle("Rate", for: .normal)
            }
        }
    }
}




// MARK: - Fetching Data
extension ShowDetailsViewController{
    private func fetchUserStatus(){
        tmdbClient.getShowStatus(id: showId!, type: showType!) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(let status):
                self.updateWatchListButton(userInteraction: false, value: status.watchlist)
                self.updateFavoriteButton(userInteraction: false, value: status.favorite)
                self.updateRatingButton(userInteraction: false, value: status.rated)
            }
        }
    }
    
    private func fetchData(){
        guard let id = showId, let type = showType else {
            Alert.show(to: self, message: "Sorry, something go wrong we will fix it as soon as possible") {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        fetchShowDetails(id: id, type: type)
        fetchTrailer(id: id, type: type)
        fetchCast(id: id, type: type)
        fetchSimilarShows(id: id, type: type)
    }
    
    private func fetchShowDetails(id: Int, type: ShowType){
        tmdbClient.getDetailsOfTheShow(id: id, type: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                Alert.show(to: self, message: error.localizedDescription) {
                    self.dismiss(animated: true, completion: nil)
                }
                
            case .success(let show):
                DispatchQueue.main.async {
                    self.upadateShowDetailsInUI(with: show, type: type)
                }
            }
        }
    }
    
    
    private func fetchTrailer(id: Int, type: ShowType){
        tmdbClient.getShowTrailerVideo(id: id, type: type) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(_):
                DispatchQueue.main.async {
                    self.noTrailer(true)
                }
                
            case .success(let video):
                let url = URL(string: "https://www.youtube.com/embed/\(video.youtubeKey)")!
                DispatchQueue.main.async {
                    self.trailerWebKitView.load(URLRequest(url: url))
                }
            }
        }
    }
    
    
    private func fetchCast(id: Int, type: ShowType){
        tmdbClient.getCastInTheShow(mediaID: id, type: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
            case .success(let cast):
                self.cast = cast
                DispatchQueue.main.async {
                    self.castCollectionView.reloadData()
                }
            }
        }
    }
    
    private func fetchSimilarShows(id: Int, type: ShowType){
        tmdbClient.getSimilarShows(id: id, type: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(let shows):
                self.similarShows = shows
                DispatchQueue.main.async {
                    self.similarMediaCollectionView.reloadData()
                }
            }
        }
    }
}
    

// MARK: - Update UI when fetching details of the show is done
extension ShowDetailsViewController{
    private func upadateShowDetailsInUI(with show: ShowDetails, type: ShowType){
        if show.hasBackdropImage {
            show.getBackdropImage(compeltionHanlder: handleGettingShowImage(result:))
        }else{
            if show.hasPosterImage{
                show.getPosterImage(compeltionHanlder: handleGettingShowImage(result:))
            }
        }
        
        titleLabel.text = show.title ?? show.name! // title for Movie and name for TV Show
        yearAndGenreLabel.text = show.genreString + ", " + show.releaseYear
        
        overviewLabel.text = show.overview
        
        switch type{
        case .movie:
            tvShowEpisodeSeasonMainView.isHidden = true
            
        case .tv:
            tvShowEpisodeSeasonMainView.isHidden = false
            tvShowEpisodeSeasonLabel.text = "\(show.numberOfEpisodes!) episode"
            self.tvShowEpisodeSeasonLabel.text! += ", \(show.numberOfSeasons!) season"
        }
        
        rateLabel.text = show.voteAverageString
        rateCountLabel.text = String(show.voteCount) + " ratings"
        popularityNumberLabel.text = show.popularityString
        
        similarHeaderTitleSectionLabel.text = "Similar \(showType!)"
    }
    
    
    private func handleGettingShowImage(result: Result<Data, Error>){
        self.loadingIndicatorForHeaderImage.stopAnimating()
        switch result {
        case .failure(_):
            print("No Backdrop Image for this Movie/TV Show")
            self.addMessageLabel(to: self.headerImageView, message: "No Image found")
            
        case .success(let data):
            self.headerImageView.image = UIImage(data: data)
        }
    }
    
    
    private func addMessageLabel(to element: UIView, message: String){
        let label = UILabel()
        label.center = element.center
        label.font = UIFont(name: "Inter-Regular", size: 15)
        label.textColor = .white
        label.text = message
        label.textAlignment = .center
        label.numberOfLines = 0
        label.frame.size.width = element.frame.width
        label.frame.size.height = element.frame.height
        label.frame.origin.x = 0
        label.frame.origin.y = 0
        label.tag = 10110
        
        element.addSubview(label)
    }
    
    private func noTrailer(_ isEmpty: Bool){
        trailerLoadingIndicator.stopAnimating()
        trailerLoadingIndicator = nil
        
        trailerWebKitView.isHidden = isEmpty
        if isEmpty{
            trailerWebKitView = nil
            addMessageLabel(to: trailerImageView, message: "No Trailer found")
        }
    }
}



// MARK: - WebKit View Delegate
extension ShowDetailsViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        noTrailer(false)
    }
}



// MARK: - Collection View
extension ShowDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (collectionView == castCollectionView) ? cast.count : similarShows.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (collectionView == castCollectionView) ? castCollcetionViewCellForItemAt(indexPath: indexPath) : similarShowsCollcetionViewCellForItemAt(indexPath: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.similarMediaCollectionView{
            similarShowsDidSelectItemAt(indexPath: indexPath)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return (collectionView == castCollectionView) ? castCollectionViewSizeForItemAt() : similarMediaCollectionViewSizeForItemAt()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}



// MARK: - Cast Collection View
extension ShowDetailsViewController{
    private func castCollcetionViewCellForItemAt(indexPath: IndexPath) -> UICollectionViewCell{
        let cell = self.castCollectionView.dequeueReusableCell(withReuseIdentifier: CastCollectionViewCell.identifier, for: indexPath) as! CastCollectionViewCell

        let person = cast[indexPath.row]
        cell.displayData(cast: person)
        cell.representedIdentifier = person.identifier
        person.getProfileImage { result in
            if cell.representedIdentifier != person.identifier { return }
            switch result {
            case .failure(_):
                cell.setProfileImage(with: nil)
                
            case .success(let data):
                cell.setProfileImage(with: data)
            }
        }
        
        return cell
    }
    
    private func castCollectionViewSizeForItemAt() -> CGSize{
        return CGSize(width: view.frame.width / 4, height: (view.frame.height * 0.2) - 1)
    }
}



// MARK: - Similar Shows Collection View
extension ShowDetailsViewController{
    private func similarShowsCollcetionViewCellForItemAt(indexPath: IndexPath) -> UICollectionViewCell{
        let cell = self.similarMediaCollectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as! CustomCollectionViewCell
        
        let similarShow = self.similarShows[indexPath.row]
        cell.displayData(similarShow)
        
        cell.representedIdentifier = similarShow.identifier
        
        similarShow.getPosterImage { result in
            if cell.representedIdentifier != similarShow.identifier { return }
            switch result {
            case .failure(_):
                cell.setImageView(with: nil)
                
            case .success(let data):
                cell.setImageView(with: data)
            }
        }
        
        return cell
    }
    
    
    // MARK: - Did Select Similar Show
    private func similarShowsDidSelectItemAt(indexPath: IndexPath){
        guard let type = self.showType else { return }
        let id = self.similarShows[indexPath.row].id
        
        // Object of Media Details View Controller
        let showDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: ShowDetailsViewController.identifier) as! ShowDetailsViewController
        let navController = UINavigationController(rootViewController: showDetailsVC)
        navController.modalPresentationStyle = .fullScreen
        
        showDetailsVC.detailsOfShow(id: id, type: type)
        
        self.present(navController, animated: true)
    }
    
    
    private func similarMediaCollectionViewSizeForItemAt() -> CGSize{
        return CGSize(width: view.frame.width / 2.5, height: (view.frame.height * 0.35) - 1)
    }
}
