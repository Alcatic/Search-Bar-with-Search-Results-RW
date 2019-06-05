

import UIKit

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    let searchController = UISearchController(searchResultsController: nil)
  
    // MARK: - Properties
    
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchFooter: SearchFooter!
  var filteredCandies = [Candy]()
  
  var detailViewController: DetailViewController? = nil
  var candies = [Candy]()
  
  // MARK: - View Setup
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Create ScopeBar
    searchController.searchBar.scopeButtonTitles = ["All","Chocolate","Hard","Other"]
    
    // Setup the search footer
    tableView.tableFooterView = searchFooter

    if let splitViewController = splitViewController {
      let controllers = splitViewController.viewControllers
      detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
    
    candies = [
        Candy(category:"Chocolate", name:"Chocolate Bar"),
        Candy(category:"Chocolate", name:"Chocolate Chip"),
        Candy(category:"Chocolate", name:"Dark Chocolate"),
        Candy(category:"Hard", name:"Lollipop"),
        Candy(category:"Hard", name:"Candy Cane"),
        Candy(category:"Hard", name:"Jaw Breaker"),
        Candy(category:"Other", name:"Caramel"),
        Candy(category:"Other", name:"Sour Chew"),
        Candy(category:"Other", name:"Gummi Bear"),
        Candy(category:"Other", name:"Candy Floss"),
        Candy(category:"Chocolate", name:"Chocolate Coin"),
        Candy(category:"Chocolate", name:"Chocolate Egg"),
        Candy(category:"Other", name:"Jelly Beans"),
        Candy(category:"Other", name:"Liquorice"),
        Candy(category:"Hard", name:"Toffee Apple")
    ]
    
    
    
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Weh u wa?"
    navigationItem.searchController =  searchController
    definesPresentationContext = true
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if splitViewController!.isCollapsed {
      if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
        self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
      }
    }
    super.viewWillAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table View
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering(){
        searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: candies.count)
        return filteredCandies.count
    }
    
    searchFooter.setNotFiltering()
    return candies.count
  }
  
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    let candy: Candy
    if isFiltering(){
        candy = filteredCandies[indexPath.row]
    }else{
        candy = candies[indexPath.row]
    }
    cell.textLabel?.text = candy.name
    cell.detailTextLabel?.text = candy.category
    
    return cell
  }
   
    
    func searchBarIsEmpty() ->Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All"){
        filteredCandies = candies.filter({ candy -> Bool in
            let doesCategoryMatch = (scope == "All") || (candy.category == scope)
            if searchBarIsEmpty(){
                return doesCategoryMatch
            }else{
                return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
            }
            //return candy.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
  
  // MARK: - Segues
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let candy: Candy
        if isFiltering(){
            candy = filteredCandies[indexPath.row]
        }else{
           candy = candies[indexPath.row]
        }
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        controller.detailCandy = candy
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }
}


extension MasterViewController: UISearchResultsUpdating{
    
    //whenever new text is added in searchbar
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        //filterContentForSearchText(searchController.searchBar.text!)
    }
    
    //Check if text is in searchBar
    func isFiltering() -> Bool{
        
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
        //return searchController.isActive && !searchBarIsEmpty()
    }
    
}

extension MasterViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


