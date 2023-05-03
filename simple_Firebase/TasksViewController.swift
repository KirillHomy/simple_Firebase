//
//  TasksViewController.swift
//  simple_Firebase
//
//  Created by Kirill Khomytsevych on 30.04.2023.
//

import UIKit
import Firebase

class TasksViewController: UIViewController {

    // MARK: - Private variables
    private var user: User!
    private var ref: DatabaseReference!
    private var tasks = Array<Task>()

    // MARK: - Private IBOutlet
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear (animated)

        ref.observe(.value, with: { [weak self] (snapshot) in
            var tasks = Array<Task> ()
            for item in snapshot .children {
                let task = Task (snapshot: item as! DataSnapshot)
                tasks.append (task)
            }
            self?.tasks = tasks
            self?.tableView.reloadData()
        })

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        ref.removeAllObservers()
    }

    // MARK: - Private IBAction
    @IBAction private func addAction(_ sender: UIBarButtonItem) {
        setuAddAction()
    }

    @IBAction private func signOutAction(_ sender: UIBarButtonItem) {
        setupSignOutAction()
    }
}

// MARK: - Private extension
private extension TasksViewController {

    func setupUI() {
        setupCurentUser()
    }

    func setupCurentUser() {
        guard let currentUser = Auth.auth().currentUser else { return }

        user = User(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }

    func setupSignOutAction() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true)
    }
    
    func setuAddAction() {
        let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        alertController.addTextField()

        let save = UIAlertAction(title: "Save", style: .default) { [weak self]_ in
            guard let textField = alertController.textFields?.first,
                  textField.text != "",
                  let sSelf = self else { return }

            let task = Task(title: textField.text!, userId: sSelf.user.uid)
            let taskRef = sSelf.ref.child(task.title.lowercased())
            taskRef.setValue(task.convertToDictionarv())
        }
        let cancel = UIAlertAction (title: "Cancel", style: .default, handler: nil)

        alertController.addAction(save)
        alertController.addAction (cancel)

        present(alertController, animated: true)
    }

}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension TasksViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = tasks[indexPath.row]

        cell.textLabel?.text = tasks[indexPath.row].title
        toggleCompletion(cell, isCompleted: task.completed)

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt
                   indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        let task = tasks[indexPath.row]
        let isCompleted = !task.completed

        toggleCompletion(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed" : isCompleted])
    }

    func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }

}
