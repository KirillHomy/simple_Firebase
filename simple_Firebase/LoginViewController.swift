//
//  LoginViewController.swift
//  simple_Firebase
//
//  Created by Kirill Khomytsevych on 30.04.2023.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    // MARK: - Private variables
    private var ref: DatabaseReference!

    // MARK: - Private IBOutlet
    @IBOutlet private weak var warnLabel: UILabel!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupClearTextField()
    }

    // MARK: - Private IBAction
    @IBAction private func loginAction(_ sender: Any) {
        setupLoginAction()
    }

    @IBAction private func registerAction(_ sender: Any) {
        setupRegisterAction()
    }
 
}

// MARK: - Private extension
private extension LoginViewController {

    func setupUI() {
        setupReference()
        setupNotificationCenter()
        setupAddStateDidChangeListener()
    }

    func setupReference() {
        ref = Database.database().reference(withPath: "users")
    }

    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(didShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didHiden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func setupAddStateDidChangeListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let sSelf = self else { return }

            if user != nil {
                sSelf.performSegue(withIdentifier: "tasksSegue", sender: nil)
            }
        }

    }

    func setupLoginAction() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email != "",
              password != "" else {
            setupDisplayWarningLabel(withText: "Info is incorrect")
            return }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard let sSelf = self else { return }

            if error != nil {
                sSelf.setupDisplayWarningLabel(withText: "Error occured")
                return
            }

            if user != nil {
                sSelf.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }

            sSelf.setupDisplayWarningLabel(withText: "No such user")
        }

    }

    func setupRegisterAction() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              email != "",
              password != "" else {
            setupDisplayWarningLabel(withText: "Info is incorrect")
            return }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
            guard let sSelf = self,
            error == nil,
            user != nil else { return }

            let userRef = sSelf.ref.child((user?.user.uid)!)
            userRef.setValue(["email": user?.user.email])
        }
    }

    func setupDisplayWarningLabel(withText text: String) {
        warnLabel.text = text

        UIView.animate(withDuration: 3,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            guard let sSelf = self else { return }

            sSelf.warnLabel.alpha = 1
        }) { [weak self] complete in
            guard let sSelf = self else { return }

            sSelf.warnLabel.alpha = 0
        }
    }

    func setupClearTextField() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }

}

// MARK: - @objc private extension
@objc private extension LoginViewController {

    func didShow (notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width,
                                                           height: self.view.bounds.size.height + kbFrameSize.height)
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets (top: 0,
                                                                            left: 0,
                                                                            bottom: kbFrameSize.height,
                                                                            right: 0)
    }

    func didHiden() {
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width,
                                                           height: self.view.bounds.size.height)
    }

}
