//
//  SeleccionAsientosViewController.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 11/12/25.
//

import UIKit
import CoreData

class SeleccionAsientosViewController: UIViewController {

       //Datos recibidos
       var pelicula: String = ""
       var ciudad: String = ""
       var cine: String = ""
       var fecha: String = ""
       var horario: String = ""
       
       //Precio por asiento
       let precioAsiento: Int = 20
       
       //Butacas
       let filas = ["A","B","C","D"]
       let columnas = 8
       var butacasOcupadas: [String] = []
       var butacasSeleccionadas: [String] = []
       var totalAsientos: Int = 0
       var totalSnacks: Double = 0

    @IBOutlet weak var lblPelicula: UILabel!
    @IBOutlet weak var lblCine: UILabel!
    @IBOutlet weak var lblCiudad: UILabel!
    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var lblHorario: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var stackButacas: UIStackView!
    
    var funcion: FuncionCD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cargarAsientosCoreData()
        //Mostrar datos recibidos
              lblPelicula.text = "Película: \(pelicula)"
              lblCiudad.text = "Ciudad: \(ciudad)"
              lblCine.text = "Cine: \(cine)"
              lblFecha.text = "Fecha: \(fecha)"
              lblHorario.text = "Horario: \(horario)"
              lblTotal.text = "Total: S/ 0"
              
              configurarMapaButacas()

    }
    func configurarMapaButacas() {
        stackButacas.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let buttonSize: CGFloat = 40 //tamaño fijo

        for filaIndex in 0..<filas.count {
            let filaStack = UIStackView()
            filaStack.axis = .horizontal
            filaStack.spacing = 5
            filaStack.distribution = .fillEqually
            filaStack.translatesAutoresizingMaskIntoConstraints = false
            filaStack.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true

            for columna in 0..<columnas {
                let asientoButton = UIButton(type: .system)
                let asientoID = "\(filas[filaIndex])\(columna + 1)"

                asientoButton.setTitle(asientoID, for: .normal)
                asientoButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                asientoButton.layer.cornerRadius = 5
                asientoButton.setTitleColor(.white, for: .normal)
                asientoButton.translatesAutoresizingMaskIntoConstraints = false
                asientoButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
                asientoButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true

                if butacasOcupadas.contains(asientoID) {
                    //Asiento ocupado
                    asientoButton.backgroundColor = .systemGray
                    asientoButton.isEnabled = false
                } else {
                    //asiento disponible
                    asientoButton.backgroundColor = .systemGreen
                    asientoButton.addTarget(self, action: #selector(asientoTapped(_:)), for: .touchUpInside)
                }

                filaStack.addArrangedSubview(asientoButton)
            }

            stackButacas.addArrangedSubview(filaStack)
        }

        //Ajustar stack principal
        stackButacas.spacing = 5
        stackButacas.alignment = .center
        stackButacas.distribution = .fillEqually
    }

        
        @objc func asientoTapped(_ sender: UIButton) {
            guard let asientoID = sender.currentTitle else { return }
            
            if butacasSeleccionadas.contains(asientoID) {
                //Deseleccionar asiento
                butacasSeleccionadas.removeAll { $0 == asientoID }
                sender.backgroundColor = .systemGreen
            } else {
                //Seleccionar asiento
                butacasSeleccionadas.append(asientoID)
                sender.backgroundColor = .systemYellow
            }
            
            actualizarTotal()
        }
        
        //Actualizar total
    func actualizarTotal() {
        totalAsientos = butacasSeleccionadas.count * precioAsiento
           lblTotal.text = "Total: S/ \(totalAsientos)"
        
    }
    
    
    
    
    
    @IBAction func btnSnacks(_ sender: Any) {
     /*   guard let confiteriaVC = storyboard?.instantiateViewController(
                withIdentifier: "ConfiteriaVC"
            ) as? ConfiteriaController else { return }

            confiteriaVC.modo = .reserva
            present(confiteriaVC, animated: true)
       */
        guard let confiteriaVC = storyboard?
                .instantiateViewController(withIdentifier: "ConfiteriaVC")
                as? ConfiteriaController else { return }

            confiteriaVC.modo = .reserva

            //PASAMOS EL VC PADRE
            confiteriaVC.seleccionAsientosVC = self

            present(confiteriaVC, animated: true)
    }
    
    
    
    @IBAction func btnIrDetalle(_ sender: UIButton) {
        guard let detalleVC = storyboard?
                .instantiateViewController(withIdentifier: "IrDetalle")
                as? PruebaController else {
                    print("❌ No existe IrDetalle en storyboard")
                    return
                }

        //PASAR TODOS LOS DATOS
            detalleVC.pelicula = pelicula
            detalleVC.ciudad = ciudad
            detalleVC.cine = cine
            detalleVC.fecha = fecha
            detalleVC.horario = horario
            detalleVC.butacas = butacasSeleccionadas
            detalleVC.totalAsientos = Double(totalAsientos)
            detalleVC.totalSnacks = totalSnacks

            detalleVC.totalSnacks = totalSnacks
           

            present(detalleVC, animated: true)
        
    }
    
    func cargarAsientosCoreData() {
        guard let funcion = funcion else {
            print("❌ ERROR: funcion es nil")
            return
        }

        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext

        let request: NSFetchRequest<AsientoCD> = AsientoCD.fetchRequest()
        request.predicate = NSPredicate(format: "funcion == %@", funcion)

        if let asientos = try? context.fetch(request), !asientos.isEmpty {
            butacasOcupadas = asientos
                .filter { $0.ocupado }
                .compactMap { $0.id }
            return
        }

        for fila in filas {
            for numero in 1...columnas {
                let asiento = AsientoCD(context: context)
                asiento.id = "\(fila)\(numero)"
                asiento.ocupado = false
                asiento.funcion = funcion
            }
        }

        try? context.save()
    }

    
}
