//
//  PruebaController.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 13/12/25.
//

import UIKit

class PruebaController: UIViewController {

    //peliculas
    @IBOutlet weak var lblPelicula: UILabel!
    @IBOutlet weak var lblCine: UILabel!
    @IBOutlet weak var lblCiudad: UILabel!
    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var lblHorario: UILabel!
    //asientos
    @IBOutlet weak var lblButacas: UILabel!
    @IBOutlet weak var lblTotalAsientos: UILabel!
    //confiteria
    @IBOutlet weak var lblSnacks: UILabel!
    @IBOutlet weak var lblTotalSnacks: UILabel!
    //total
    @IBOutlet weak var lblTotalFinal: UILabel!
    
    @IBOutlet weak var btnContinuar: UIButton!
    
    var pelicula: String = ""
        var ciudad: String = ""
        var cine: String = ""
        var fecha: String = ""
        var horario: String = ""
        var butacas: [String] = []
        var totalAsientos: Double = 0
        var totalSnacks: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configurarEstilos()
        cargarDatos()
    }
    
    func configurarEstilos() {
            btnContinuar.layer.cornerRadius = 12
        }
    
    func cargarDatos() {
            lblPelicula.text = "Película: \(pelicula)"
            lblCine.text = "Cine: \(cine)"
            lblCiudad.text = "Ciudad: \(ciudad)"
            lblFecha.text = "Fecha: \(fecha)"
            lblHorario.text = "Horario: \(horario)"
            
            let butacasTexto = butacas.joined(separator: ", ")
            lblButacas.text = "Asientos: \(butacasTexto)"
            lblTotalAsientos.text = "Subtotal: S/ \(String(format: "%.2f", totalAsientos))"
            
            if totalSnacks > 0 {
                lblSnacks.text = "Confitería incluida"
                lblTotalSnacks.text = "Subtotal: S/ \(String(format: "%.2f", totalSnacks))"
            } else {
                lblSnacks.text = "Sin confitería"
                lblTotalSnacks.text = "Subtotal: S/ 0.00"
            }
            
            let totalFinal = totalAsientos + totalSnacks
            lblTotalFinal.text = "TOTAL: S/ \(String(format: "%.2f", totalFinal))"
        }
    
    @IBAction func btnContinuar(_ sender: UIButton) {
        let totalFinal = totalAsientos + totalSnacks
        print("Continuar al pago")
        print("Total entradas: S/ \(totalAsientos)")
        print("Total snacks: S/ \(totalSnacks)")
        print("TOTAL A PAGAR: S/ \(totalFinal)")
        
        guard let metodoPagoVC = storyboard?
            .instantiateViewController(withIdentifier: "IrMetodoPago")
            as? SeleccionMetodoPagoController else {
                print("❌ No existe SeleccionMetodoPagoController en storyboard")
                return
            }
            
        //pasar todos los datos
        metodoPagoVC.totalAPagar = totalFinal
        metodoPagoVC.pelicula = pelicula
        metodoPagoVC.ciudad = ciudad
        metodoPagoVC.cine = cine
        metodoPagoVC.fecha = fecha
        metodoPagoVC.horario = horario
        metodoPagoVC.butacas = butacas
        metodoPagoVC.totalAsientos = totalAsientos
        metodoPagoVC.totalSnacks = totalSnacks
            
        metodoPagoVC.modalPresentationStyle = .fullScreen
        present(metodoPagoVC, animated: true)
    }
    
}
