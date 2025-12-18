import UIKit

class LoginModalController: UIViewController {

    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Iniciar Sesión"
        lbl.font = .boldSystemFont(ofSize: 24)
        lbl.textAlignment = .center
        lbl.textColor = UIColor.systemYellow
        return lbl
    }()

    let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Correo"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.backgroundColor = .darkGray
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: "Correo",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        return tf
    }()

    let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Contraseña"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .darkGray
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: "Contraseña",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        return tf
    }()

    let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Entrar", for: .normal)
        btn.backgroundColor = UIColor.systemYellow
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        return btn
    }()

    let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Crear cuenta", for: .normal)
        btn.setTitleColor(.systemYellow, for: .normal)
        btn.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        layoutUI()
    }

    func layoutUI() {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel, emailField, passwordField,
            loginButton, registerButton
        ])
        stack.axis = .vertical
        stack.spacing = 15

        view.addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            loginButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc func loginTapped() {
        let correo = emailField.text ?? ""
           let clave = passwordField.text ?? ""

           let ok = UserDataManager.shared.validarLogin(
               correo: correo,
               contrasena: clave
           )

           if ok {
               //CREAR SESIoN OSCAR PTMR ESTO NOMA ERA
               Sesionmanager.shared.login(correo: correo)

               NotificationCenter.default.post(
                   name: NSNotification.Name("UsuarioLogueado"),
                   object: nil
               )

               dismiss(animated: true)
               print("Login correcto")
           } else {
               let alert = UIAlertController(
                   title: "Error",
                   message: "Correo o contraseña incorrectos",
                   preferredStyle: .alert
               )
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
           }
    }

    @objc func registerTapped() {
        let registroVC = RegisterModalController()
        registroVC.modalPresentationStyle = .formSheet
        present(registroVC, animated: true)
    }

}
