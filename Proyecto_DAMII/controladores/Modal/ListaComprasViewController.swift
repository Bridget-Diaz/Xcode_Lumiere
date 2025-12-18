//
//  ListaComprasViewController.swift
//  Proyecto_DAMII
//
//  Created by DESIGN on 16/12/25.
//

import UIKit
import CoreData

class ListaComprasViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    var compras: [Compra] = []
    
    let emptyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "🎬\n\nAún no has realizado compras"
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 18, weight: .medium)
        lbl.textColor = .lightGray
        lbl.isHidden = true
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configurarUI()
        cargarCompras()
    }
    
    func configurarUI() {
        //Header
        let titleLabel = UILabel()
        titleLabel.text = "Mis Compras"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textColor = .systemYellow
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 28)
        closeButton.setTitleColor(.systemYellow, for: .normal)
        closeButton.addTarget(self, action: #selector(cerrarTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //ScrollView y StackView para botones
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(scrollView)
        view.addSubview(emptyLabel)
        
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    func cargarCompras() {
        guard let correo = UserDefaults.standard.string(forKey: "correoLogueado") else {
            mostrarEmpty()
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Compra> = Compra.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "usuarioCorreo == %@", correo)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fechaCompra", ascending: false)]
        
        do {
            compras = try context.fetch(fetchRequest)
            
            if compras.isEmpty {
                mostrarEmpty()
            } else {
                emptyLabel.isHidden = true
                scrollView.isHidden = false
                crearBotonesCompras()
            }
            
            print("✅ Se cargaron \(compras.count) compras")
            
        } catch {
            print("❌ Error al cargar compras: \(error)")
            mostrarEmpty()
        }
    }
    
    func crearBotonesCompras() {
        //Limpiar btns anteriores
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        //Crear un btn por cada compra
        for (index, compra) in compras.enumerated() {
            let btn = crearBotonCompra(compra: compra, index: index)
            stackView.addArrangedSubview(btn)
        }
    }
    
    func crearBotonCompra(compra: Compra, index: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.tag = index

        let pelicula = compra.pelicula ?? "Sin título"
        let fecha = compra.fecha ?? ""
        let total = String(format: "%.2f", compra.totalFinal)

        let titulo = """
        🎬 \(pelicula)
        📅 \(fecha)
        💰 S/ \(total)
        """

        btn.setTitle(titulo, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.textAlignment = .left
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.contentHorizontalAlignment = .fill
        btn.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 56)
        btn.backgroundColor = UIColor(white: 0.15, alpha: 1)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.systemYellow.cgColor
        btn.addTarget(self, action: #selector(botonCompraTapped(_:)), for: .touchUpInside)
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 110).isActive = true

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemYellow
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.isUserInteractionEnabled = false

        btn.addSubview(chevron)

        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -20),
            chevron.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 18),
            chevron.heightAnchor.constraint(equalToConstant: 18)
        ])

        return btn
    }


    
    @objc func botonCompraTapped(_ sender: UIButton) {
        let compra = compras[sender.tag]
        
        //abrir modal con detalle
        let detalleVC = DetalleCompraViewController()
        detalleVC.compra = compra
        detalleVC.modalPresentationStyle = .fullScreen
        present(detalleVC, animated: true)
    }
    
    func mostrarEmpty() {
        emptyLabel.isHidden = false
        scrollView.isHidden = true
    }
    
    @objc func cerrarTapped() {
        dismiss(animated: true)
    }
}
