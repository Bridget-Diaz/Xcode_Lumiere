//
//  DetalleSnackController.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 11/12/25.
//

import UIKit
import CoreData

class DetalleSnackController: UIViewController {
    
    var modo: ConfiteriaModo = .independiente
    
    
    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblPrecio: UILabel!
    @IBOutlet weak var imgDetalle: UIImageView!
    @IBOutlet weak var lblDescripcion: UILabel!
    @IBOutlet weak var lblTipo: UILabel!
    @IBOutlet weak var btnContinuar: UIButton!//nose a que referencia apunta deberia ser arrastrado desde el storyboard pero bueno ,ahora ya lo referencie wa
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblCantidad: UILabel!
    @IBOutlet weak var btnAumentarOutlet: UIButton!
    @IBOutlet weak var btnDisminuirOutlet: UIButton!
    @IBOutlet weak var btnCancelar: UIButton!
    
      var cantidad: Int = 0
      var snack: Snack?
      
      override func viewDidLoad() {
          super.viewDidLoad()
          view.backgroundColor = .black
          cargarDatos()
          
          print("🔍 Modo recibido:", modo)
          print("btnContinuar:", btnContinuar as Any)
      }
      
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          
          //Configurar UI cuando la vista está completamente lista
          configurarUISegunModo()
      }
      
      
      //Configura mos lo que se a de mostrar segun el modo como ingresemos
      func configurarUISegunModo() {
          switch modo {
          case .independiente:
              lblCantidad.isHidden = true
              lblTotal.isHidden = true
              btnAumentarOutlet?.isHidden = true
              btnDisminuirOutlet?.isHidden = true
              //esta wea ahora solo cierra modal crj
              btnContinuar.setTitle("Cerrar", for: .normal)
              
          case .reserva:
              lblCantidad.isHidden = false
              lblTotal.isHidden = false
              btnAumentarOutlet?.isHidden = false
              btnDisminuirOutlet?.isHidden = false
              actualizarCantidadUI()
          }
      }
      
      
      @IBAction func btnDisminuir(_ sender: UIButton) {
          if cantidad > 0 {
              cantidad -= 1
          }
          actualizarCantidadUI()
      }
      
      @IBAction func btnCancelar(_ sender: UIButton) {
          dismiss(animated: true)
      }
      
      @IBAction func btnAumentar(_ sender: UIButton) {
          cantidad += 1
          actualizarCantidadUI()
      }
      
      func actualizarCantidadUI() {
          lblCantidad.text = String(format: "%04d", cantidad)
          
          if let price = snack?.precio {
              let total = Double(cantidad) * price
              lblTotal.text = "Total: S/ \(String(format: "%.2f", total))"
          }
      }
      
      func cargarDatos() {
          guard let s = snack else { return }
          
          //usa la propiedad calculada uiImage
          imgDetalle.image = s.uiImage
          
          //nombre p
          lblNombre.text = s.nombre
          
          //categoria es String?, no enum
          lblTipo.text = "Categoría: \(s.categoria?.capitalized ?? "Sin categoría")"
          
          //Precio
          lblPrecio.text = "S/ \(String(format: "%.2f", s.precio))"
          
          //Descripción
          lblDescripcion.text = s.descripcion
      }
      
      
      @IBAction func btnContinuar(_ sender: UIButton) {
          guard modo == .reserva else {
              dismiss(animated: true)
              return
          }
          
          guard let snack = snack, cantidad > 0 else {
              dismiss(animated: true)
              return
          }
          
          let subtotal = Double(cantidad) * snack.precio
          
          NotificationCenter.default.post(
              name: .snackAgregado,
              object: nil,
              userInfo: ["subtotal": subtotal]
          )
          
          dismiss(animated: true)
      }
  }


  extension Notification.Name {
      static let snackAgregado = Notification.Name("snackAgregado")
  }
