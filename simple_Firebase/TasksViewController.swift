//
//  TasksViewController.swift
//  simple_Firebase
//
//  Created by Kirill Khomytsevych on 30.04.2023.
//

import UIKit
import Firebase

class TasksViewController: UIViewController {

    // MARK: - Private IBOutlet
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private IBAction
    @IBAction private func addAction(_ sender: UIBarButtonItem) {
        //
    }

    @IBAction private func signOutAction(_ sender: UIBarButtonItem) {
        setupSignOutAction()
    }
}

// MARK: - Private extension
private extension TasksViewController {

    func setupUI() {
        //
    }

    func setupSignOutAction() {
        do {
            try  Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true)
    }
}

extension TasksViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        return cell
    }

}
