import UIKit
import CoreData

class ModalPerfilController: UIViewController {

    private let inicialButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("U", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 26, weight: .bold)
        btn.setTitleColor(.systemYellow, for: .normal)
        btn.backgroundColor = .darkGray
        btn.layer.cornerRadius = 28
        btn.clipsToBounds = true
        btn.isUserInteractionEnabled = false
        return btn
    }()

    private let nombreLabel = UILabel()
    private let correoLabel = UILabel()
    private let telefonoLabel = UILabel()
    private let fechaNacLabel = UILabel()
    private let dniLabel = UILabel()

    private let verComprasButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("🎬 Ver Mis Compras", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .systemYellow
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(verComprasTapped), for: .touchUpInside)
        return btn
    }()

    private let cerrarSesionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cerrar Sesión", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.backgroundColor = .clear
        btn.layer.borderColor = UIColor.systemRed.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(cerrarSesionTapped), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarSheet()
        configurarUI()
        cargarDatosUsuario()
    }

    private func configurarSheet() {
        modalPresentationStyle = .pageSheet
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()] // Reducido el largo
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
    }

    private func configurarUI() {

        view.backgroundColor = UIColor(white: 0.18, alpha: 1)

        let labels = [nombreLabel, correoLabel, telefonoLabel, fechaNacLabel, dniLabel]
        labels.forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .white
            $0.numberOfLines = 0
            $0.textAlignment = .left
        }

        nombreLabel.font = .systemFont(ofSize: 21, weight: .bold)
        nombreLabel.textColor = .systemYellow

        let infoStack = UIStackView(arrangedSubviews: [
            nombreLabel,
            correoLabel,
            telefonoLabel,
            fechaNacLabel,
            dniLabel
        ])
        infoStack.axis = .vertical
        infoStack.spacing = 10
        infoStack.alignment = .fill
        infoStack.translatesAutoresizingMaskIntoConstraints = false

      
        let buttonsStack = UIStackView(arrangedSubviews: [
            verComprasButton,
            cerrarSesionButton
        ])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 20
        buttonsStack.alignment = .center
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(inicialButton)
        view.addSubview(infoStack)
        view.addSubview(buttonsStack)

        inicialButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            
            inicialButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            inicialButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inicialButton.widthAnchor.constraint(equalToConstant: 56),
            inicialButton.heightAnchor.constraint(equalToConstant: 56),

            
            infoStack.topAnchor.constraint(equalTo: inicialButton.bottomAnchor, constant: 18),
            infoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            infoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),

            
            buttonsStack.topAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: 22),
            buttonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            
            verComprasButton.widthAnchor.constraint(equalToConstant: 160), // Ajusté el ancho
            verComprasButton.heightAnchor.constraint(equalToConstant: 42),
            
            cerrarSesionButton.widthAnchor.constraint(equalToConstant: 160), // Ajusté el ancho
            cerrarSesionButton.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    private func cargarDatosUsuario() {
        let isLogged = UserDefaults.standard.bool(forKey: "isLogged")

        guard isLogged,
              let correo = UserDefaults.standard.string(forKey: "correoLogueado"),
              let usuario = UserDataManager.shared.obtenerUsuarioPorCorreo(correo)
        else {
            inicialButton.setTitle("U", for: .normal)
            nombreLabel.text = "Usuario"
            verComprasButton.isHidden = true
            cerrarSesionButton.isHidden = true
            return
        }

        verComprasButton.isHidden = false
        cerrarSesionButton.isHidden = false

        if let inicial = usuario.nombres?.first {
            inicialButton.setTitle(String(inicial).uppercased(), for: .normal)
        }

        let nombreCompleto = "\(usuario.nombres ?? "") \(usuario.apellidos ?? "")"
        nombreLabel.text = nombreCompleto

        configurarLabel(correoLabel, titulo: "Correo", valor: usuario.correo ?? "")
        configurarLabel(telefonoLabel, titulo: "Teléfono", valor: usuario.telefono ?? "")
        configurarLabel(dniLabel, titulo: "DNI", valor: usuario.dni ?? "")

        if let fecha = usuario.fechaNacimiento {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            configurarLabel(fechaNacLabel, titulo: "Nacimiento", valor: formatter.string(from: fecha))
        } else {
            configurarLabel(fechaNacLabel, titulo: "Nacimiento", valor: "Sin fecha")
        }
    }

    private func configurarLabel(_ label: UILabel, titulo: String, valor: String) {
        let texto = "\(titulo): \(valor)"
        let attributed = NSMutableAttributedString(string: texto)
        attributed.addAttribute(.foregroundColor, value: UIColor.systemYellow,
                                range: NSRange(location: 0, length: titulo.count + 1))
        attributed.addAttribute(.foregroundColor, value: UIColor.white,
                                range: NSRange(location: titulo.count + 2, length: valor.count))
        label.attributedText = attributed
    }

    @objc private func verComprasTapped() {
        let comprasVC = ListaComprasViewController()
        comprasVC.modalPresentationStyle = .fullScreen
        present(comprasVC, animated: true)
    }

    @objc private func cerrarSesionTapped() {
        UserDefaults.standard.set(false, forKey: "isLogged")
        UserDefaults.standard.removeObject(forKey: "correoLogueado")
        NotificationCenter.default.post(name: NSNotification.Name("UsuarioCerroSesion"), object: nil)
        dismiss(animated: true)
    }
}
