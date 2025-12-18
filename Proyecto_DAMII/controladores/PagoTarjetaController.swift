//
//  PagoTarjetaController.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 13/12/25.
//

import UIKit
import CoreData

class PagoTarjetaController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var lblTotalPagar: UILabel!
    @IBOutlet weak var txtTipoTarjeta: UITextField!
    @IBOutlet weak var txtNumeroTarjeta: UITextField!
    @IBOutlet weak var txtNombreTitular: UITextField!
    @IBOutlet weak var txtFechaVencimiento: UITextField!
    @IBOutlet weak var txtCVV: UITextField!
    @IBOutlet weak var btnPagar: UIButton!
    @IBOutlet weak var btnCancelar: UIButton!
    
    var totalAPagar: Double = 0
        var pelicula: String = ""
        var ciudad: String = ""
        var cine: String = ""
        var fecha: String = ""
        var horario: String = ""
        var butacas: [String] = []
        var totalAsientos: Double = 0
        var totalSnacks: Double = 0
    
       let pickerTipoTarjeta = UIPickerView()
       let tiposTarjeta = ["Débito", "Crédito"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarEstilos()
        configurarPicker()
        cargarDatos()
    }
    
    func configurarEstilos() {
        btnPagar.layer.cornerRadius = 12
        btnCancelar.layer.cornerRadius = 12

        let textFields = [
            txtTipoTarjeta,
            txtNumeroTarjeta,
            txtNombreTitular,
            txtFechaVencimiento,
            txtCVV
        ]

        textFields.forEach { tf in
            guard let tf = tf else { return }

            tf.backgroundColor = .darkGray
            tf.textColor = .white
            tf.layer.cornerRadius = 8
            tf.layer.borderWidth = 1
            tf.layer.borderColor = UIColor.systemYellow.cgColor
            tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
            tf.leftViewMode = .always
            
            //PLACEHOLDER VISIBLE
            tf.attributedPlaceholder = NSAttributedString(
                string: tf.placeholder ?? "",
                attributes: [
                    .foregroundColor: UIColor.systemYellow.withAlphaComponent(0.7)
                ]
            )
        }

        let dropdown = UIImageView(image: UIImage(systemName: "chevron.down"))
        dropdown.tintColor = .systemYellow
        dropdown.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        dropdown.contentMode = .scaleAspectFit
        txtTipoTarjeta.rightView = dropdown
        txtTipoTarjeta.rightViewMode = .always
        txtNumeroTarjeta.keyboardType = .numberPad
        txtCVV.keyboardType = .numberPad
    }
    
    func configurarPicker() {
            pickerTipoTarjeta.delegate = self
            pickerTipoTarjeta.dataSource = self
            txtTipoTarjeta.inputView = pickerTipoTarjeta
            
            //toolbar para cerrar el picker
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Listo", style: .done, target: self, action: #selector(cerrarPicker))
            toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: false)
            txtTipoTarjeta.inputAccessoryView = toolbar
        }
    
    @objc func cerrarPicker() {
            view.endEditing(true)
        }
       
    //Cargar Datos
        func cargarDatos() {
            lblTotalPagar.text = "Total a pagar: S/ \(String(format: "%.2f", totalAPagar))"
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return tiposTarjeta.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return tiposTarjeta[row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            txtTipoTarjeta.text = tiposTarjeta[row]
        }
        
    func validarCampos() -> Bool {
           guard let tipoTarjeta = txtTipoTarjeta.text, !tipoTarjeta.isEmpty else {
               mostrarAlerta(mensaje: "Selecciona el tipo de tarjeta")
               return false
           }
           
           guard let numeroTarjeta = txtNumeroTarjeta.text, numeroTarjeta.count >= 16 else {
               mostrarAlerta(mensaje: "Ingresa un número de tarjeta válido (16 dígitos)")
               return false
           }
           
           guard let nombreTitular = txtNombreTitular.text, !nombreTitular.isEmpty else {
               mostrarAlerta(mensaje: "Ingresa el nombre del titular")
               return false
           }
           
           guard let fechaVencimiento = txtFechaVencimiento.text, !fechaVencimiento.isEmpty else {
               mostrarAlerta(mensaje: "Ingresa la fecha de vencimiento (MM/AA)")
               return false
           }
           
           guard let cvv = txtCVV.text, cvv.count == 3 else {
               mostrarAlerta(mensaje: "Ingresa un CVV válido (3 dígitos)")
               return false
           }
           
           return true
       }
    
    func mostrarAlerta(mensaje: String) {
            let alert = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    @IBAction func btnPagar(_ sender: UIButton) {
        //Validar campos
                guard validarCampos() else { return }
                
                print("💳 Procesando pago con tarjeta...")
                print("Tipo: \(txtTipoTarjeta.text ?? "")")
                print("Número: \(txtNumeroTarjeta.text ?? "")")
                print("Titular: \(txtNombreTitular.text ?? "")")
                print("Vencimiento: \(txtFechaVencimiento.text ?? "")")
                print("CVV: \(txtCVV.text ?? "")")
                print("💰 Monto: S/ \(totalAPagar)")
                
                //se simula el pago exitoso
                mostrarConfirmacionPago()
    }
    
    @IBAction func btnCancelar(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func mostrarConfirmacionPago() {
        confirmarReservaCoreData()
        let alert = UIAlertController(
            title: "✅ Pago Exitoso",
            message: "Tu compra ha sido procesada correctamente.\n\nTotal pagado: S/ \(String(format: "%.2f", totalAPagar))",
            preferredStyle: .alert
        )
        
        //Btn para ver/compartir ticket
        alert.addAction(UIAlertAction(title: "📄 Ver Ticket", style: .default, handler: { _ in
            self.generarYCompartirTicket()
        }))
        
        //Btn para cerrar
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: { _ in
            //Volver al inicio (cerrar todos los modals que se abrieron)
            self.view.window?.rootViewController?.dismiss(animated: true)
        }))
        
        present(alert, animated: true)
    }

    func generarYCompartirTicket() {
        //generador de pdf
        guard let pdfURL = TicketPDFGenerator.generarTicket(
            pelicula: pelicula,
            cine: cine,
            ciudad: ciudad,
            fecha: fecha,
            horario: horario,
            butacas: butacas,
            totalAsientos: totalAsientos,
            totalSnacks: totalSnacks,
            totalPagado: totalAPagar
        ) else {
            mostrarAlerta(mensaje: "Error al generar el ticket. Intenta nuevamente.")
            return
        }
        
        print("✅ Ticket PDF generado exitosamente")
        
        //Compartir el PDF
        /*TicketPDFGenerator.compartirTicket(desde: self, pdfURL: pdfURL)*/
        
            let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            
            //Para iPad (evita crash)
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: self.view.bounds.midX,
                                           y: self.view.bounds.midY,
                                           width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            //Esto se ejecuta cuando termina la acción (compartir/cancelar)
            activityVC.completionWithItemsHandler = { _, completed, _, _ in
                //Regresar al inicio siempre, si quieres
                DispatchQueue.main.async {
                    self.view.window?.rootViewController?.dismiss(animated: true)
                }
            }
            
            present(activityVC, animated: true)
    }
    
    func guardarCompraUsuario() {
        // Verificar que el usuario esté logueado
        guard let correo = UserDefaults.standard.string(forKey: "correoLogueado") else {
            print("⚠️ Usuario no logueado, no se guardará la compra")
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        
        // Crear nueva compra
        let nuevaCompra = Compra(context: context)
        
        // Asignar todos los datos
        nuevaCompra.usuarioCorreo = correo
        nuevaCompra.pelicula = pelicula
        nuevaCompra.ciudad = ciudad
        nuevaCompra.cine = cine
        nuevaCompra.fecha = fecha
        nuevaCompra.horario = horario
        nuevaCompra.butacas = butacas.joined(separator: ", ") // Convertir array a String
        nuevaCompra.totalAsientos = totalAsientos
        nuevaCompra.totalSnacks = totalSnacks
        nuevaCompra.totalFinal = totalAPagar
        nuevaCompra.fechaCompra = Date() // Fecha actual de la compra
        
        // Guardar en Core Data
        do {
            try context.save()
            print("✅ Compra del usuario guardada exitosamente (Tarjeta)")
            print("📦 Datos guardados:")
            print("   - Usuario: \(correo)")
            print("   - Película: \(pelicula)")
            print("   - Asientos: \(butacas.joined(separator: ", "))")
            print("   - Total: S/ \(totalAPagar)")
        } catch {
            print("❌ Error al guardar compra del usuario: \(error)")
        }
    }
    
    func confirmarReservaCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext

        // Marcar asientos como ocupados
        let request: NSFetchRequest<AsientoCD> = AsientoCD.fetchRequest()
        request.predicate = NSPredicate(format: "funcion.horario == %@ AND funcion.fecha == %@", horario, fecha)

        if let asientos = try? context.fetch(request) {
            for asiento in asientos where butacas.contains(asiento.id ?? "") {
                asiento.ocupado = true
            }
        }

        // Crear la reserva
        let reserva = ReservaCD(context: context)
        reserva.id = UUID()
        reserva.fechaReserva = Date()
        reserva.totalAsientos = totalAsientos
        reserva.totalSnacks = totalSnacks
        reserva.totalFinal = totalAPagar
        reserva.funcionHorario = horario
        reserva.funcionFecha = fecha
        reserva.peliculaTitulo = pelicula
        reserva.cine = cine
        reserva.ciudad = ciudad

        // GUARDAR LA COMPRA DEL USUARIO (NUEVO)
        guardarCompraUsuario()

        // Guardar todo en Core Data
        do {
            try context.save()
            print("✅ Reserva guardada exitosamente (Tarjeta)")
        } catch {
            print("❌ Error al guardar reserva:", error)
        }
    }
    
}
