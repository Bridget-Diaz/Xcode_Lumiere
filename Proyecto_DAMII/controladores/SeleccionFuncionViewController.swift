//
//  SeleccionFuncionViewController.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 11/12/25.
//

import UIKit
import CoreData


class SeleccionFuncionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var pelicula: PeliculaEntity?
    
    
    @IBOutlet weak var txtCiudad: UITextField!
    @IBOutlet weak var txtCine: UITextField!
    @IBOutlet weak var txtFecha: UITextField!
    @IBOutlet weak var lblHorarios: UILabel!
    @IBOutlet weak var stackHorarios: UIStackView!
    
    //Pickers
    let pickerCiudad = UIPickerView()
    let pickerCine = UIPickerView()
    let pickerFecha = UIPickerView()
    
    
    let ciudades = ["Lima"]
    let cines = ["CP Primavera", "CP Metro","CP Pro","CP San Isidro"]
    let fechas = ["Hoy - Miércoles 17", "Mañana - Jueves 18", "Viernes - 19", "Sábado - 20"]
    let horariosDisponibles = ["1:00 PM", "3:00 PM", "5:00 PM", "7:00 PM", "9:00 PM"]
    
    var horarioSeleccionado: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarPickers()
        lblHorarios.isHidden = true
        stackHorarios.isHidden = true
        txtCiudad.backgroundColor = .white
        txtCine.backgroundColor = .white
        txtFecha.backgroundColor = .white
    }
        func configurarPickers() {
            configurarPicker(picker: pickerCiudad, textField: txtCiudad)
            configurarPicker(picker: pickerCine, textField: txtCine)
            configurarPicker(picker: pickerFecha, textField: txtFecha)
        }

        func configurarPicker(picker: UIPickerView, textField: UITextField) {
            picker.delegate = self
            picker.dataSource = self
            textField.inputView = picker

            let dropdown = UIImageView(image: UIImage(systemName: "chevron.down"))
            dropdown.tintColor = .gray
            dropdown.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            textField.rightView = dropdown
            textField.rightViewMode = .always
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if pickerView == pickerCiudad { return ciudades.count }
            if pickerView == pickerCine { return cines.count }
            return fechas.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if pickerView == pickerCiudad { return ciudades[row] }
            if pickerView == pickerCine { return cines[row] }
            return fechas[row]
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if pickerView == pickerCiudad { txtCiudad.text = ciudades[row] }
            else if pickerView == pickerCine { txtCine.text = cines[row] }
            else { txtFecha.text = fechas[row] }

            view.endEditing(true)
            actualizarHorarios()
        }

        func actualizarHorarios() {
            guard let ciudad = txtCiudad.text, !ciudad.isEmpty,
                  let cine = txtCine.text, !cine.isEmpty,
                  let fecha = txtFecha.text, !fecha.isEmpty else {
                lblHorarios.isHidden = true
                stackHorarios.isHidden = true
                return
            }

            //Mostrar horarios si los tres campos están seleccionados
            lblHorarios.isHidden = false
            stackHorarios.isHidden = false
            mostrarBotonesHorarios()
        }

        func mostrarBotonesHorarios() {
            stackHorarios.arrangedSubviews.forEach { $0.removeFromSuperview() }

            let buttonSize: CGFloat = 60

            for horario in horariosDisponibles {
                let boton = UIButton(type: .system)
                boton.setTitle(horario, for: .normal)
                boton.setTitleColor(.white, for: .normal)
                boton.backgroundColor = .systemBlue
                boton.layer.cornerRadius = 8
                boton.translatesAutoresizingMaskIntoConstraints = false
                boton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
                boton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
                boton.addTarget(self, action: #selector(horarioTappedButton(_:)), for: .touchUpInside)

                stackHorarios.addArrangedSubview(boton)
            }

            stackHorarios.spacing = 10
            stackHorarios.alignment = .center
            stackHorarios.distribution = .fillEqually
        }

        @objc private func horarioTappedButton(_ sender: UIButton) {
            //Deseleccionar todos
            stackHorarios.arrangedSubviews.forEach { btn in
                if let button = btn as? UIButton {
                    button.backgroundColor = .systemBlue
                }
            }
            //Seleccionar el tocado
            sender.backgroundColor = .systemGreen
            horarioSeleccionado = sender.currentTitle
        }
    
    
    @IBAction func btnContinuar(_ sender: UIButton) {
        guard let ciudad = txtCiudad.text, !ciudad.isEmpty,
              let cine = txtCine.text, !cine.isEmpty,
              let fecha = txtFecha.text, !fecha.isEmpty,
              let horario = horarioSeleccionado else {
              let alert = UIAlertController(title: "Error", message: "Selecciona ciudad, cine, fecha y horario.", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              self.present(alert, animated: true)
              return
        }
        
        let funcionCD = obtenerOcrearFuncion()

            guard let asientosVC = storyboard?
                .instantiateViewController(withIdentifier: "SeleccionAsientosViewController")
                as? SeleccionAsientosViewController else { return }

            asientosVC.funcion = funcionCD
            asientosVC.pelicula = pelicula?.titulo ?? ""
            asientosVC.ciudad = txtCiudad.text!
            asientosVC.cine = txtCine.text!
            asientosVC.fecha = txtFecha.text!
            asientosVC.horario = horarioSeleccionado!

            asientosVC.modalPresentationStyle = .fullScreen
            present(asientosVC, animated: true)
    }

    
    
    func obtenerOcrearFuncion() -> FuncionCD {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext

        let peliculaCD = obtenerOcrearPelicula(context: context)

        let request: NSFetchRequest<FuncionCD> = FuncionCD.fetchRequest()
        request.predicate = NSPredicate(
            format: "pelicula == %@ AND cine == %@ AND ciudad == %@ AND fecha == %@ AND horario == %@",
            peliculaCD!,
            txtCine.text!,
            txtCiudad.text!,
            txtFecha.text!,
            horarioSeleccionado!
        )

        if let existente = try? context.fetch(request).first {
            return existente
        }

        let nueva = FuncionCD(context: context)
        nueva.id = UUID()
        nueva.cine = txtCine.text!
        nueva.ciudad = txtCiudad.text!
        nueva.fecha = txtFecha.text!
        nueva.horario = horarioSeleccionado!
        nueva.pelicula = peliculaCD

        try? context.save()
        return nueva
    }


    //Funcion auxiliar para obtener o crear PeliculaCD
    func obtenerOcrearPelicula(context: NSManagedObjectContext) -> PeliculaCD? {
        guard let titulo = pelicula?.titulo else { return nil }

        let request: NSFetchRequest<PeliculaCD> = PeliculaCD.fetchRequest()
        request.predicate = NSPredicate(format: "titulo == %@", titulo)

        if let existente = try? context.fetch(request).first {
            return existente
        }

        let nueva = PeliculaCD(context: context)
        nueva.titulo = pelicula?.titulo
        nueva.duracion = pelicula?.duracion
        nueva.clasificacion = pelicula?.clasificacion
        nueva.sinopsis = pelicula?.sinopsis
        try? context.save()
        return nueva
    }
}
    


