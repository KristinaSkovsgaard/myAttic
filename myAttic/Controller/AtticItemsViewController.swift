//
//  AtticItemsViewController.swift
//  myAttic
//
//  Created by App og Blog on 16/02/2021.
//

import UIKit
import CoreData

class AtticItemsViewController: UITableViewController {
    
    var itemsArray = [AtticItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
        didSet{ //happens as soon as this property is set
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    
    }

    // MARK: - Tableview data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "atticItemCell", for: indexPath)

        let item = itemsArray[indexPath.row]
        
        cell.textLabel?.text = item.title

        return cell
    }
    
    //MARK: - Tableview delegate
    
    
    //MARK: - Add item
    
    @IBAction func addItemsPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
    
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in

            let newItem = AtticItem(context:self.context)
            newItem.title = textField.text!
            newItem.parentCategory = self.selectedCategory
            
            self.itemsArray.append(newItem)
            
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
  
    
    
    
    
    //MARK: - Data manipulation
    
    func loadItems(with request: NSFetchRequest<AtticItem> = AtticItem.fetchRequest(), predicate: NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate{ //if predicate is NOT nil
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else{
            request.predicate = categoryPredicate
        }
        
        do{
            itemsArray = try context.fetch(request) //All the items
        }catch{
            print("Error fetching data from context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func saveItems()  {

        do{
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }

}

//MARK: - Searchbar

extension AtticItemsViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<AtticItem> = AtticItem.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)] //Array, so it can contain more describtor. We just have one here.
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //When searchBar is cleared. Not called from beginning.
        if searchBar.text?.count == 0{
            loadItems() //Doesn't need parameter - uses default parameter
            
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
