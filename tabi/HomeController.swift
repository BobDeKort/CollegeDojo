import UIKit
import MessageUI

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate {
    
    let cellId = "cellId"
    let savedCellId = "savedCellId"
    let freeFoodCellId = "freeFoodCellId"
    
    let titles = ["Home", "Saved", "Free Food"]
    
    var currentCell: BaseCell?{
        didSet{
            reloadCurrentCell()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        _ = appDelegate.triggerDeepLinkIfPresent()
        
        reloadCurrentCell()
        navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.setHidesBackButton(true, animated:false)

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLabel.text = "  Home"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel
        
        setupCollectionView()
        setupMenuBar()
        setupNavBarButtons()
        collectionView?.reloadData()
    }
    
    func showSingleEvent(eventId: String){
        
        ApiService.sharedInstance.fetchSingleEvent(eventId: eventId, completion: { (event) in
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            vc.event = event
            self.navigationController?.present(vc, animated: true, completion: nil)
        
        })
    }
    
    func reloadCurrentCell(){
        if let currentCell = currentCell {
            if let id = currentCell.reuseIdentifier {
                switch  id {
                case cellId:
                    let cell = currentCell as? HomeCell
                    cell?.fetchEvents()
                case savedCellId:
                    let cell = currentCell as? SavedCell
                    cell?.fetchEvents()
                case freeFoodCellId:
                    let cell = currentCell as? FreeFoodCell
                    cell?.fetchEvents()
                default:
                    break
                }
            }
        }
    }
    
    // Setup views in menu tabs
    func setupCollectionView() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(HomeCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(SavedCell.self, forCellWithReuseIdentifier: savedCellId)
        collectionView?.register(FreeFoodCell.self, forCellWithReuseIdentifier: freeFoodCellId)
        
        // TODO: change inset back to 50 for next release
        // pushes collectionview down for 5O because the menubar is 50 tall
        collectionView?.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)
        
        collectionView?.isPagingEnabled = true
        collectionView?.reloadData()
    }
    
    // Sets up more button and search button
    func setupNavBarButtons() {
        // Searchbutton
        let searchImage = UIImage(named: "search_icon")?.withRenderingMode(.alwaysOriginal)
        let searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleSearch))
        
        // More button
        let moreButton = UIBarButtonItem(image: UIImage(named: "nav_more_icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))
        
        // Order
        navigationItem.rightBarButtonItems = [moreButton, searchBarButtonItem]
    }
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        return launcher
    }()

    func handleMore() {
        //show menu
        settingsLauncher.showSettings()
        settingsLauncher.navigationController = self.navigationController
    }
    
    func showControllerForSetting(_ setting: Setting) {
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = UIColor.white
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@eventsdojo.com"])
            mail.setSubject("FEEDBACK: ")
            mail.setMessageBody("Please enter your feedback, concerns, questions, etc below: ", isHTML: false)
            
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Could not open mail", message: "This device is not setup to send emails. Please enable this to continue sending us feedback", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // searchbutton sends you to the third menu item
    func handleSearch() {
        let vc = SearchViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // Set up amount of tabs
    func scrollToMenuIndex(_ menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
        
        setTitleForIndex(menuIndex)
    }
    
    fileprivate func setTitleForIndex(_ index: Int) {
        if let titleLabel = navigationItem.titleView as? UILabel {
            titleLabel.text = "  \(titles[index])"
        }

    }
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.homeController = self
        return mb
    }()
    
    fileprivate func setupMenuBar() {
        // (0, green: 155, blue: 115)
        let blueView = UIView()
        blueView.backgroundColor = UIColor.productColor()
        view.addSubview(blueView)
        view.addConstraintsWithFormat("H:|[v0]|", views: blueView)
        view.addConstraintsWithFormat("V:[v0(50)]", views: blueView)
        
        view.addSubview(menuBar)
        view.addConstraintsWithFormat("H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat("V:[v0(50)]", views: menuBar)
        
        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 3
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = targetContentOffset.pointee.x / view.frame.width
        
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
        setTitleForIndex(Int(index))
    }
    
    func reloadView(){
        if let view = collectionView{
            view.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier: String
        if indexPath.item == 0 {
            identifier = cellId
        } else if indexPath.item == 1 {
            identifier = savedCellId
        } else {
            identifier = freeFoodCellId
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! BaseCell
        
        cell.navigationController = self.navigationController
        currentCell = cell
        cell.parentView = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 50)
    }
}






