//
//  MenuModalViewController.swift
//  Proyecto_DAMII
//
//  Created by DESIGN on 16/12/25.
//

import UIKit

class MenuModalViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configurarUI()
    }
    
    func configurarUI() {
        //título
        let titleLabel = UILabel()
        titleLabel.text = "Menú"
        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.textColor = .systemYellow
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //Btn cerrar
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 28)
        closeButton.setTitleColor(.systemYellow, for: .normal)
        closeButton.addTarget(self, action: #selector(cerrarTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Btn Ver Perfil
        let perfilButton = crearBoton(
            titulo: "👤 Ver Perfil",
            subtitulo: "Información de tu cuenta",
            accion: #selector(verPerfilTapped)
        )
        
        //Btn Mis Compras
        let comprasButton = crearBoton(
            titulo: "🎬 Mis Compras",
            subtitulo: "Historial de entradas",
            accion: #selector(verComprasTapped)
        )
        
        //Stack de botones
        let buttonsStack = UIStackView(arrangedSubviews: [perfilButton, comprasButton])
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 20
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(buttonsStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            buttonsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            buttonsStack.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    func crearBoton(titulo: String, subtitulo: String, accion: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        
        //Crear texto con dos líneas
        let tituloText = NSMutableAttributedString(string: titulo + "\n")
        tituloText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 24), range: NSRange(location: 0, length: titulo.count))
        tituloText.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: titulo.count))
        
        let subtituloText = NSAttributedString(
            string: subtitulo,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.lightGray
            ]
        )
        
        tituloText.append(subtituloText)
        
        btn.setAttributedTitle(tituloText, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.textAlignment = .center
        btn.contentHorizontalAlignment = .center
        
        //Estilo
        btn.backgroundColor = UIColor(white: 0.15, alpha: 1)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.systemYellow.cgColor
        
        //Agregar icono de flecha
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemYellow
        chevron.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -20),
            chevron.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 20),
            chevron.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        btn.addTarget(self, action: accion, for: .touchUpInside)
        
        return btn
    }
    
    @objc func verPerfilTapped() {
        let isLogged = UserDefaults.standard.bool(forKey: "isLogged")

        //Si NO está logueado → abrir login como modal
        if !isLogged {
            let loginVC = LoginModalController()
            loginVC.modalPresentationStyle = .pageSheet

            if let sheet = loginVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }

            present(loginVC, animated: true)
            return
        }

        //SÍ está logueado → abrir perfil
        let perfilVC = ModalPerfilController()
        perfilVC.modalPresentationStyle = .pageSheet

        if let sheet = perfilVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(perfilVC, animated: true)
    }


    @objc func verComprasTapped() {
        let isLogged = UserDefaults.standard.bool(forKey: "isLogged")

        //NO está logueado → abrir login como modal
        if !isLogged {
            let loginVC = LoginModalController()
            loginVC.modalPresentationStyle = .pageSheet

            if let sheet = loginVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }

            present(loginVC, animated: true)
            return
        }

        //SÍ está logueado → abrir compras como modal
        let comprasVC = ListaComprasViewController()
        comprasVC.modalPresentationStyle = .pageSheet

        if let sheet = comprasVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(comprasVC, animated: true)
    }

    
    @objc func cerrarTapped() {
        dismiss(animated: true)
    }
}
