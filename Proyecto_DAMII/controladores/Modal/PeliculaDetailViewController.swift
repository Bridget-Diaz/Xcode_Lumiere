//
//  PeliculaDetailViewController.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 10/12/25.
//

import UIKit

class PeliculaDetailViewController: UIViewController {
    
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var tituloLabel: UILabel!
    
    @IBOutlet weak var lblDuracion: UILabel!
    
    @IBOutlet weak var lblClasificacion: UILabel!
    
    @IBOutlet weak var lblSinopsis: UILabel!
    
    @IBOutlet weak var lblNombreCine: UILabel!
    
    
    var pelicula: PeliculaEntity?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarUI()
        
    }
    
    
    func configurarUI() {
        guard let p = pelicula else { return }
        posterImageView.image = p.imagen
        tituloLabel.text = p.titulo
        lblDuracion.text = p.duracion
        lblClasificacion.text = p.clasificacion
        lblSinopsis.text = p.sinopsis
        
    }
    
    @IBAction func bntComprarEntradas(_ sender: UIButton) {
        if !Sesionmanager.shared.isLogged {
               mostrarLogin()
               return
           }

           performSegue(withIdentifier: "Inspector", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Inspector" {
            let destino = segue.destination as! SeleccionFuncionViewController
            destino.pelicula = pelicula
        }
    }
    
   
    func mostrarLogin() {
        let loginVC = LoginModalController()
        loginVC.modalPresentationStyle = .pageSheet

        if let sheet = loginVC.sheetPresentationController {
            sheet.detents = [
                .custom { context in
                    context.maximumDetentValue * 0.4
                }
            ]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(loginVC, animated: true)
    }

    

}
