//
//  ToDoListTVC.swift
//  HomeWork-30
//
//  Created by Ваня Науменко on 28.04.22.
//

import CoreData
import UIKit

// MARK: - ToDoListTVC

class ToDoListTVC: UITableViewController {
    var categories = [CategoryModel]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var selectedCategory: CategoryModel? {
        didSet {
            title = selectedCategory?.name
            loadItems()
        }
    }

    private var itemsArray = [Item]()

    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        addNewItem()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = itemsArray[indexPath.row].title
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
           let name = itemsArray[indexPath.row]
        {
            let request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
            request.predicate = NSPredicate(format: "name==\(name)")

            if let categories = try? context.fetch(request) {
                for category in categories {
                    context.delete(category)
                }
            }
            itemsArray.remove(at: indexPath.row)
            saveContext()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    private func addNewItem() {
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Item"
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textFields = alert.textFields?.first,
               let text = textFields.text,
               text != "",
               let self = self
            {
                let newItem = Item(context: self.context)
                newItem.title = text
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemsArray.append(newItem)
                self.saveContext()
//                self.tableView.reloadData() - но этот метод проще засунуть и не страшно )))))
                self.tableView.insertRows(at: [IndexPath(row: self.itemsArray.count - 1, section: 0)], with: .automatic)
            }
        }
        alert.addAction(cancel)
        alert.addAction(addAction)
        present(alert, animated: true)
    }

    private func loadItems() {
        guard let name = selectedCategory?.name else { return }
        let categoryPredicate = NSPredicate(format: "parentCategory.name==\(name)")

        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = categoryPredicate
        do {
            itemsArray = try context.fetch(request)
        } catch {
            print(" Error with load cotegories")
        }

        tableView.reloadData()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error with save context")
        }
    }
}

// MARK: UISearchBarDelegate

extension ToDoListTVC: UISearchBarDelegate {
    func searchBar(_ search: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}
