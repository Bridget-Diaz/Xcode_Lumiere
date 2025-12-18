//
//  SeleccionMetodoPagoController.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 13/12/25.
//

import UIKit
import CoreData

class SeleccionMetodoPagoController: UIViewController {

    @IBOutlet weak var lblTotalPagar: UILabel!
    @IBOutlet weak var btnTarjeta: UIButton!
    @IBOutlet weak var btnApplePay: UIButton!
    @IBOutlet weak var swTerminos: UISwitch!
    @IBOutlet weak var swDatos: UISwitch!
    
    var totalAPagar: Double = 0
    
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
        
        swTerminos.isOn = false
        swDatos.isOn = false
        validarSwitches()
    }
    
    func configurarEstilos() {
        //Estilo btn Tarjeta
        btnTarjeta.layer.cornerRadius = 12
        btnTarjeta.layer.borderWidth = 2
        //btnTarjeta.layer.borderColor = UIColor.systemYellow.cgColor
            
        //Estilo btn Apple Pay
        btnApplePay.layer.cornerRadius = 12
        btnApplePay.layer.borderWidth = 2
        //btnApplePay.layer.borderColor = UIColor.systemYellow.cgColor
    }

    func cargarDatos() {
        lblTotalPagar.text = "Total a pagar: S/ \(String(format: "%.2f", totalAPagar))"
    }
    
    @IBAction func btnTarjeta(_ sender: UIButton) {
        print("💳 Seleccionó pago con Tarjeta")
        // Navegar a la vista de Pago con Tarjeta
        guard let pagoTarjetaVC = storyboard?
            .instantiateViewController(withIdentifier: "IrTarjeta")
                as? PagoTarjetaController else {
                    print("❌ No existe PagoTarjetaController en storyboard")
                    return
                }
        pagoTarjetaVC.totalAPagar = totalAPagar
        pagoTarjetaVC.pelicula = pelicula
        pagoTarjetaVC.ciudad = ciudad
        pagoTarjetaVC.cine = cine
        pagoTarjetaVC.fecha = fecha
        pagoTarjetaVC.horario = horario
        pagoTarjetaVC.butacas = butacas
        pagoTarjetaVC.totalAsientos = totalAsientos
        pagoTarjetaVC.totalSnacks = totalSnacks
                
        pagoTarjetaVC.modalPresentationStyle = .fullScreen
        present(pagoTarjetaVC, animated: true)
    }
    
        
    @IBAction func btnApplePay(_ sender: UIButton) {
        print("🍎 Seleccionó Apple Pay")
        procesarPagoApplePay()
    }
    
    @IBAction func cambioSwitch(_ sender: UISwitch) {
        validarSwitches()
    }
    
    func validarSwitches() {
        let habilitar = swTerminos.isOn && swDatos.isOn

        btnTarjeta.isEnabled = habilitar
        btnApplePay.isEnabled = habilitar
        btnTarjeta.alpha = habilitar ? 1.0 : 0.5
        btnApplePay.alpha = habilitar ? 1.0 : 0.5
    }
    
    //metodo de pago con apple pay
    func procesarPagoApplePay() {
        //Deshabilitar botones mientras procesa
        btnApplePay.isEnabled = false
        btnTarjeta.isEnabled = false
        btnApplePay.alpha = 0.5
        
        let loadingAlert = UIAlertController(title: "🍎 Apple Pay", message: "Autenticando con Face ID...", preferredStyle: .alert)
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        loadingAlert.view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: loadingAlert.view.topAnchor, constant: 50)
        ])
        
        present(loadingAlert, animated: true)
        
        //Simular delay de autenticación biométrica (2 segundos)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            loadingAlert.dismiss(animated: true) {
                //GUARDAR EN CORE DATA DESPUÉS DE AUTENTICAR
                self.confirmarReservaCoreData()
                // Rehabilitar botones
                self.btnApplePay.isEnabled = true
                self.btnTarjeta.isEnabled = true
                self.btnApplePay.alpha = 1.0
                //Mostrar confirmación de pago
                self.mostrarConfirmacionPagoApplePay()
            }
        }
    }

    //Confirmación de Pago Apple Pay
    func mostrarConfirmacionPagoApplePay() {
        let alert = UIAlertController(
            title: "✅ Pago Exitoso",
            message: "Tu pago con Apple Pay ha sido procesado correctamente.\n\nTotal pagado: S/ \(String(format: "%.2f", totalAPagar))",
            preferredStyle: .alert
        )
        
        //Btn para ver/compartir ticket
        alert.addAction(UIAlertAction(title: "📄 Ver Ticket", style: .default, handler: { _ in
            self.generarYCompartirTicketApplePay()
        }))
        
        //Btn para cerrar
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel, handler: { _ in
            // Volver al inicio (cerrar todos los modales)
            self.view.window?.rootViewController?.dismiss(animated: true)
        }))
        
        present(alert, animated: true)
    }

    //Generar y compartir ticket PDF (Apple Pay)
    func generarYCompartirTicketApplePay() {
        // Generar el PDF
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
        
        print("✅ Ticket PDF generado exitosamente (Apple Pay)")
        
        //Compartir el PDF
        let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
            
        //Para iPad (evita crash)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX,
                                        y: self.view.bounds.midY,
                                        width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        //CUANDO SE CIERRE EL SHARE SHEET, VOLVER AL INICIO
        activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            //volver al inicio (cerrar todos los modales)
            self.view.window?.rootViewController?.dismiss(animated: true)
        }
            
        present(activityVC, animated: true)
    }

    //Helper: Mostrar alerta de error
    func mostrarAlerta(mensaje: String) {
        let alert = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    //Guardar Compra del Usuario en Core Data (NUEVO)
    func guardarCompraUsuario() {
        //Verificar que el usuario esté logueado
        guard let correo = UserDefaults.standard.string(forKey: "correoLogueado") else {
            print("⚠️ Usuario no logueado, no se guardará la compra")
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        
        //Crear nueva compra
        let nuevaCompra = Compra(context: context)
        
        //Asignar todos los datos
        nuevaCompra.usuarioCorreo = correo
        nuevaCompra.pelicula = pelicula
        nuevaCompra.ciudad = ciudad
        nuevaCompra.cine = cine
        nuevaCompra.fecha = fecha
        nuevaCompra.horario = horario
        nuevaCompra.butacas = butacas.joined(separator: ", ") //Convertir array a String
        nuevaCompra.totalAsientos = totalAsientos
        nuevaCompra.totalSnacks = totalSnacks
        nuevaCompra.totalFinal = totalAPagar
        nuevaCompra.fechaCompra = Date() //Fecha actual de la compra
        
        //Guardar en Core Data
        do {
            try context.save()
            print("✅ Compra del usuario guardada exitosamente")
            print("📦 Datos guardados:")
            print("   - Usuario: \(correo)")
            print("   - Película: \(pelicula)")
            print("   - Asientos: \(butacas.joined(separator: ", "))")
            print("   - Total: S/ \(totalAPagar)")
        } catch {
            print("❌ Error al guardar compra del usuario: \(error)")
        }
    }
    
    //Confirmación completa (Reserva + Compra del Usuario)
    func confirmarReservaCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext

        //Marcar asientos como ocupados
        let requestAsientos: NSFetchRequest<AsientoCD> = AsientoCD.fetchRequest()
        requestAsientos.predicate = NSPredicate(
            format: "funcion.horario == %@ AND funcion.fecha == %@",
            horario,
            fecha
        )

        if let asientos = try? context.fetch(requestAsientos) {
            for asiento in asientos where butacas.contains(asiento.id ?? "") {
                asiento.ocupado = true
            }
        }

        //Crear la reserva
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

        //guardar la compra del usuario (NUEVO)
        guardarCompraUsuario()

        //guardar todo en Core Data
        do {
            try context.save()
            print("✅ Reserva guardada exitosamente")
        } catch {
            print("❌ Error al guardar reserva:", error)
        }
    }
}
