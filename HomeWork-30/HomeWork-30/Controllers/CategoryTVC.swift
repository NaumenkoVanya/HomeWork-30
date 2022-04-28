//
//  CategoryTVC.swift
//  HomeWork-30
//
//  Created by Ваня Науменко on 28.04.22.
//

import CoreData
import UIKit

final class CategoryTVC: UITableViewController {
    private var categories = [CategoryModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCotegories()
    }

    @IBAction func addCategoryAction(_ sender: UIBarButtonItem) {
        addCategory()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }

    // MARC: - Delegate

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: nil)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
           let name = categories[indexPath.row].name
        {
            let request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
            request.predicate = NSPredicate(format: "name MATCHES %@", name)
            if let categories = try? context.fetch(request) {
                for category in categories {
                    context.delete(category)
                }
            }
            categories.remove(at: indexPath.row)
            saveContext()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toDoListTVC = segue.destination as? ToDoListTVC,
           let indexPath = tableView.indexPathForSelectedRow
        {
            toDoListTVC.selectedCategory = categories[indexPath.row]
        }
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error with save context")
        }
    }

    private func loadCotegories() {
        let request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
        do {
            categories = try context.fetch(request)
        } catch {
            print(" Error with load cotegories")
        }
    }

    private func addCategory() {
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Category"
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textFields = alert.textFields?.first,
               let text = textFields.text,
               text != "",
               let self = self
            {
                let newCategory = CategoryModel(context: self.context)
                newCategory.name = text
                self.categories.append(newCategory)
                self.saveContext()
//                self.tableView.reloadData() - но этот метод проще засунуть и не страшно )))))
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .automatic)
            }
        }
        alert.addAction(cancel)
        alert.addAction(addAction)
        present(alert, animated: true)
    }    
}
