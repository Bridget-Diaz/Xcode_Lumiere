//
//  DetalleCompraViewController.swift
//  Proyecto_DAMII
//
//  Created by DESIGN on 16/12/25.
//

import UIKit
import CoreData

class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}

class DetalleCompraViewController: UIViewController {
    
    var compra: Compra?
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configurarUI()
        cargarDetalle()
    }
    
    private func configurarUI() {
        
        //Titulo
        let titleLabel = UILabel()
        titleLabel.text = "Detalle de Compra"
        titleLabel.font = .boldSystemFont(ofSize: 28)
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

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentStack)
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])
    }
    
    private func cargarDetalle() {
        guard let compra = compra else { return }
        
        contentStack.addArrangedSubview(crearLabelDestacado(texto: compra.pelicula ?? "Sin título", icono: "🎬"))
        contentStack.addArrangedSubview(crearSeparador())
        
        contentStack.addArrangedSubview(crearSeccion(titulo: "INFORMACIÓN DE LA FUNCIÓN"))
        contentStack.addArrangedSubview(crearLabelInfo(titulo: "Fecha", valor: compra.fecha ?? "", icono: "📅"))
        contentStack.addArrangedSubview(crearLabelInfo(titulo: "Horario", valor: compra.horario ?? "", icono: "🕐"))
        contentStack.addArrangedSubview(crearLabelInfo(titulo: "Cine", valor: compra.cine ?? "", icono: "🏢"))
        contentStack.addArrangedSubview(crearLabelInfo(titulo: "Ciudad", valor: compra.ciudad ?? "", icono: "📍"))
        
        contentStack.addArrangedSubview(crearSeparador())
        contentStack.addArrangedSubview(crearSeccion(titulo: "ASIENTOS"))
        contentStack.addArrangedSubview(crearLabelAsientos(asientos: compra.butacas ?? ""))
        
        contentStack.addArrangedSubview(crearSeparador())
        contentStack.addArrangedSubview(crearSeccion(titulo: "RESUMEN DE PAGO"))
        contentStack.addArrangedSubview(crearLabelTotal(titulo: "Entradas", valor: compra.totalAsientos))
        contentStack.addArrangedSubview(crearLabelTotal(titulo: "Confitería", valor: compra.totalSnacks))
        
        contentStack.addArrangedSubview(crearSeparador())
        contentStack.addArrangedSubview(crearLabelTotalFinal(total: compra.totalFinal))
        
        if let fechaCompra = compra.fechaCompra {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            contentStack.addArrangedSubview(crearLabelFechaCompra(fecha: formatter.string(from: fechaCompra)))
        }
    }
    
    private func crearLabelDestacado(texto: String, icono: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = "\(icono) \(texto)"
        lbl.font = .boldSystemFont(ofSize: 24)
        lbl.textColor = .systemYellow
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }
    
    private func crearSeccion(titulo: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = titulo
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .systemYellow
        return lbl
    }
    
    private func crearLabelInfo(titulo: String, valor: String, icono: String) -> UILabel {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "\(icono) \(titulo): \(valor)"
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 16)
        return lbl
    }
    
    private func crearLabelAsientos(asientos: String) -> UILabel {
        let lbl = PaddingLabel()
        lbl.text = "💺 \(asientos)"
        lbl.font = .systemFont(ofSize: 18, weight: .medium)
        lbl.textColor = .white
        lbl.textAlignment = .center
        
        lbl.backgroundColor = UIColor(white: 0.15, alpha: 1)
        lbl.layer.cornerRadius = 12
        lbl.layer.borderWidth = 1
        lbl.layer.borderColor = UIColor.systemYellow.cgColor
        lbl.clipsToBounds = true
        
        return lbl
    }
    
    private func crearLabelTotal(titulo: String, valor: Double) -> UILabel {
        let lbl = UILabel()
        lbl.text = "\(titulo): S/ \(String(format: "%.2f", valor))"
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 16)
        return lbl
    }
    
    private func crearLabelTotalFinal(total: Double) -> UILabel {
        let lbl = PaddingLabel()
        lbl.text = "💰 TOTAL: S/ \(String(format: "%.2f", total))"
        lbl.font = .boldSystemFont(ofSize: 22)
        lbl.textColor = .systemGreen
        lbl.textAlignment = .center
        
        lbl.backgroundColor = UIColor(white: 0.15, alpha: 1)
        lbl.layer.cornerRadius = 12
        lbl.layer.borderWidth = 2
        lbl.layer.borderColor = UIColor.systemGreen.cgColor
        lbl.clipsToBounds = true
        
        return lbl
    }
    
    private func crearLabelFechaCompra(fecha: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = "Comprado el: \(fecha)"
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = .darkGray
        lbl.textAlignment = .center
        return lbl
    }
    
    private func crearSeparador() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.3, alpha: 1)
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }
    

    @objc private func cerrarTapped() {
        dismiss(animated: true)
    }
}
