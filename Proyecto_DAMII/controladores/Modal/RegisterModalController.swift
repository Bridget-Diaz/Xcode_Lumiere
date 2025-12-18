import UIKit

class RegisterModalController: UIViewController {

    // MARK: - CAMPOS
    let nombresField = UITextField()
    let apellidosField = UITextField()
    let correoField = UITextField()
    let telefonoField = UITextField()
    let generoField = UITextField()
    let fechaNacimientoField = UITextField()
    let dniField = UITextField()
    let contrasenaField = UITextField()

    let aceptarSwitch = UISwitch()
    let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        configurarCampos()
        configurarDatePicker()
        configurarUI()
    }

    // MARK: - Configurar los campos
    func configurarCampos() {
        func configurar(_ tf: UITextField, _ placeholder: String, secure: Bool = false, keyboard: UIKeyboardType = .default) {
            tf.placeholder = placeholder
            tf.borderStyle = .roundedRect
            tf.isSecureTextEntry = secure
            tf.backgroundColor = .darkGray
            tf.textColor = .white
            tf.keyboardType = keyboard
            tf.autocapitalizationType = .none
            tf.autocorrectionType = .no
            tf.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
        
        configurar(nombresField, "Nombres")
        configurar(apellidosField, "Apellidos")
        configurar(correoField, "Correo", keyboard: .emailAddress)
        configurar(telefonoField, "Teléfono", keyboard: .phonePad)
        configurar(generoField, "Género (opcional)")
        configurar(fechaNacimientoField, "Fecha nacimiento (opcional)")
        configurar(dniField, "DNI", keyboard: .numberPad)
        configurar(contrasenaField, "Contraseña", secure: true)
        
        
        dniField.addTarget(self, action: #selector(limitarDNI), for: .editingChanged)
        
        
        telefonoField.addTarget(self, action: #selector(limitarTelefono), for: .editingChanged)
    }
    
    @objc func limitarDNI() {
        if let text = dniField.text, text.count > 8 {
            dniField.text = String(text.prefix(8))
        }
    }
    
    @objc func limitarTelefono() {
        if let text = telefonoField.text, text.count > 9 {
            telefonoField.text = String(text.prefix(9))
        }
    }

    // MARK: - DatePicker
    func configurarDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        
        fechaNacimientoField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(seleccionarFecha))
        ]
        
        fechaNacimientoField.inputAccessoryView = toolbar
    }

    @objc func seleccionarFecha() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        fechaNacimientoField.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }

    // MARK: - UI
    func configurarUI() {

        
        let titleLabel: UILabel = {
            let lbl = UILabel()
            lbl.text = "Registro"
            lbl.font = .boldSystemFont(ofSize: 28)
            lbl.textAlignment = .center
            lbl.textColor = UIColor.systemYellow
            return lbl
        }()

        
        let terminosLabel: UILabel = {
            let lbl = UILabel()
            lbl.text = "Aceptar términos y condiciones"
            lbl.font = .systemFont(ofSize: 14)
            lbl.textColor = .white
            return lbl
        }()

        
        let registrarBtn: UIButton = {
            let btn = UIButton(type: .system)
            btn.setTitle("Registrar", for: .normal)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
            btn.backgroundColor = UIColor.systemYellow
            btn.setTitleColor(.black, for: .normal)
            btn.layer.cornerRadius = 10
            btn.addTarget(self, action: #selector(registrarTapped), for: .touchUpInside)
            btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
            return btn
        }()

        
        let camposStack = UIStackView(arrangedSubviews: [
            nombresField,
            apellidosField,
            correoField,
            telefonoField,
            generoField,
            fechaNacimientoField,
            dniField,
            contrasenaField,
            terminosLabel,
            aceptarSwitch,
            registrarBtn
        ])
        camposStack.axis = .vertical
        camposStack.spacing = 12

        
        let generalStack = UIStackView(arrangedSubviews: [
            titleLabel,
            camposStack
        ])
        generalStack.axis = .vertical
        generalStack.spacing = 20

        view.addSubview(generalStack)

        
        generalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            generalStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generalStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            generalStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }

    @objc func registrarTapped() {
        if validarCampos() {
            
            let datos: [String: Any] = [
                "nombres": nombresField.text!,
                "apellidos": apellidosField.text!,
                "correo": correoField.text!,
                "telefono": telefonoField.text!,
                "genero": generoField.text ?? "",
                "fechaNacimiento": datePicker.date,
                "dni": dniField.text!,
                "contrasena": contrasenaField.text!
            ]

            let exito = UserDataManager.shared.registrarUsuario(datos: datos)

            if exito {
                
                UserDefaults.standard.set(true, forKey: "isLogged")
                UserDefaults.standard.set(datos["correo"], forKey: "correoLogueado")

                
                NotificationCenter.default.post(name: NSNotification.Name("UsuarioLogueado"), object: nil)

                
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            else {
                mostrarAlerta(titulo: "Error", mensaje: "El correo ya existe.")
            }
        }
    }

    // MARK: - VALIDACIONES
    func validarCampos() -> Bool {
        //Validar campos obligatorios no vacíos
        if nombresField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            mostrarAlerta(titulo: "Error", mensaje: "El campo Nombres es obligatorio.")
            return false
        }
        
        if apellidosField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            mostrarAlerta(titulo: "Error", mensaje: "El campo Apellidos es obligatorio.")
            return false
        }
        
        if correoField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            mostrarAlerta(titulo: "Error", mensaje: "El campo Correo es obligatorio.")
            return false
        }
        
        if telefonoField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            mostrarAlerta(titulo: "Error", mensaje: "El campo Teléfono es obligatorio.")
            return false
        }
        
        if dniField.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            mostrarAlerta(titulo: "Error", mensaje: "El campo DNI es obligatorio.")
            return false
        }
        
        if contrasenaField.text?.isEmpty == true {
            mostrarAlerta(titulo: "Error", mensaje: "El campo Contraseña es obligatorio.")
            return false
        }
        
        //Validar nombres (solo letras y espacios)
        if !validarSoloLetras(nombresField.text!) {
            mostrarAlerta(titulo: "Error", mensaje: "El campo Nombres solo debe contener letras.")
            return false
        }
        
        if !validarSoloLetras(apellidosField.text!) {
            mostrarAlerta(titulo: "Error", mensaje: "El campo Apellidos solo debe contener letras.")
            return false
        }
        
        //Validar correo
        if !validarCorreo(correoField.text!) {
            mostrarAlerta(titulo: "Error", mensaje: "Ingresa un correo electrónico válido.")
            return false
        }
        
        //Validar teléfono (9 dígitos en Perú)
        if !validarTelefono(telefonoField.text!) {
            mostrarAlerta(titulo: "Error", mensaje: "El teléfono debe tener 9 dígitos.")
            return false
        }
        
        //Validar DNI (8 dígitos en Perú)
        if !validarDNI(dniField.text!) {
            mostrarAlerta(titulo: "Error", mensaje: "El DNI debe tener 8 dígitos.")
            return false
        }
        
        //Validar contraseña (mínimo 6 caracteres)
        if !validarContrasena(contrasenaField.text!) {
            mostrarAlerta(titulo: "Error", mensaje: "La contraseña debe tener al menos 6 caracteres.")
            return false
        }
        
        //Validar términos y condiciones
        if !aceptarSwitch.isOn {
            mostrarAlerta(titulo: "Aviso", mensaje: "Debes aceptar los términos y condiciones.")
            return false
        }
        
        return true
    }
    
    func validarSoloLetras(_ texto: String) -> Bool {
        let letrasRegex = "^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$"
        let test = NSPredicate(format: "SELF MATCHES %@", letrasRegex)
        return test.evaluate(with: texto)
    }
    
    func validarCorreo(_ correo: String) -> Bool {
        let correoRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let test = NSPredicate(format: "SELF MATCHES %@", correoRegex)
        return test.evaluate(with: correo)
    }
    
    func validarTelefono(_ telefono: String) -> Bool {
        return telefono.count == 9 && telefono.allSatisfy { $0.isNumber }
    }
    
    func validarDNI(_ dni: String) -> Bool {
        return dni.count == 8 && dni.allSatisfy { $0.isNumber }
    }
    
    func validarContrasena(_ contrasena: String) -> Bool {
        return contrasena.count >= 6
    }

    func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
