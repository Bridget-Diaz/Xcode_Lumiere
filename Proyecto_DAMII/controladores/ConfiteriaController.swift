//
//  ConfiteriaController.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 10/12/25.
//

import UIKit
import CoreData
var snack : Snack?

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


enum ConfiteriaModo {
    case independiente     //aca desde el bar
    case reserva           // desde el flujo de reserva y demas p
}





class ConfiteriaController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    
    
    weak var seleccionAsientosVC: SeleccionAsientosViewController?
    

    @IBOutlet weak var cvCanchitas: UICollectionView!
    
    @IBOutlet weak var cvCombos: UICollectionView!
    @IBOutlet weak var cvBebidas: UICollectionView!
    @IBOutlet weak var btnContinuar: UIButton!
    
    var canchitasCoreData: [Snack] = []
       var bebidasCoreData: [Snack] = []
       var combosCoreData: [Snack] = []

       var modo: ConfiteriaModo = .independiente
       var totalSnacks: Double = 0
       var detalleSnacks: [(nombre: String, cantidad: Int, subtotal: Double)] = []
       
   override func viewDidLoad() {
           super.viewDidLoad()
           
           view.backgroundColor = .black
           
           //Identificadores
           cvCanchitas.tag = 1
           cvBebidas.tag   = 2
           cvCombos.tag    = 3
           
           //Delegates + Datasource
           cvCanchitas.delegate = self
           cvBebidas.delegate   = self
           cvCombos.delegate    = self
           
           cvCanchitas.dataSource = self
           cvBebidas.dataSource   = self
           cvCombos.dataSource    = self
           
           fetchSnacks()
    
           switch modo {
           case .reserva:
               configurarModoReserva()
           case .independiente:
               configurarModoIndependiente()
           }
            configurarUIsegunModo()
           print("💰 Total snacks recibido:", totalSnacks)
           print("🎬 Modo actual:", modo)
           NotificationCenter.default.addObserver(
               self,
               selector: #selector(snackAgregado(_:)),
               name: .snackAgregado,
               object: nil
           )
       }

       
       func fetchSnacks() {
           do {
               let fetchedSnacks = try context.fetch(Snack.fetchRequest())
               canchitasCoreData = fetchedSnacks.filter { $0.categoria == "canchita" }
               bebidasCoreData   = fetchedSnacks.filter { $0.categoria == "bebida" }
               combosCoreData    = fetchedSnacks.filter { $0.categoria == "combo" }
               
         
               cvCanchitas.reloadData()
               cvBebidas.reloadData()
               cvCombos.reloadData()
               
           } catch {
               print("❌ Error al obtener los datos de Core Data: \(error)")
           }
       }
       
        
       func collectionView(_ collectionView: UICollectionView,
                           numberOfItemsInSection section: Int) -> Int {

           switch collectionView.tag {
           case 1: return canchitasCoreData.count
           case 2: return bebidasCoreData.count
           case 3: return combosCoreData.count
           default: return 0
           }
       }

       func collectionView(_ collectionView: UICollectionView,
                           cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

           switch collectionView.tag {

           //canchis
           case 1:
               let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: "CanchitaCell",
                   for: indexPath
               ) as! CanchitaCell

               let item = canchitasCoreData[indexPath.row]
               cell.imgCanchita.image = item.uiImage
               return cell


           //cocacolaespuma
           case 2:
               let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: "BebidaCell",
                   for: indexPath
               ) as! BebidaCell

               let item = bebidasCoreData[indexPath.row]
               cell.imgBebida.image = item.uiImage
               return cell


           //bueeee
           case 3:
               let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: "ComboCell",
                   for: indexPath
               ) as! ComboCell

               let item = combosCoreData[indexPath.row]
               cell.imgCombo.image = item.uiImage
               return cell

           default:
               return UICollectionViewCell()
           }
       }

     
       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           sizeForItemAt indexPath: IndexPath) -> CGSize {

           let width = collectionView.frame.width / 3.5
           return CGSize(width: width, height: width)
       }

       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 16
       }

       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 16
       }

      
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

           //comprobar por consola que elemento seleccionasmediante la columna
           print("CLICK EN ITEM: \(indexPath.row)")
           print("Modo actual al abrir detalle:", modo)

           guard let detalle = storyboard?.instantiateViewController(withIdentifier: "DetalleSnackController") as? DetalleSnackController else {
               print("❌ ERROR: No existe el ViewController con ese identifier")
               return
           }

           var snackSeleccionado: Snack?

           switch collectionView.tag {
           case 1:
               snackSeleccionado = canchitasCoreData[indexPath.row]
           case 2:
               snackSeleccionado = bebidasCoreData[indexPath.row]
           case 3:
               snackSeleccionado = combosCoreData[indexPath.row]
           default:
               return
           }

           // identificamos el snack que seleciono y el modo por donde fue abierto este controller
           detalle.snack = snackSeleccionado
           detalle.modo = modo
           
           print("Pasando modo al detalle:", modo)
           
           //Presentar como modal
           present(detalle, animated: true)
       }
       
       @objc func snackAgregado(_ notification: Notification) {

           if let subtotal = notification.userInfo?["subtotal"] as? Double {
               totalSnacks += subtotal
               print("💰 Total snacks acumulado:", totalSnacks)
           }
       }

    //funciones sin importancia ....... prints p para ver dde donde viene validacion o observador hijito
       func configurarModoReserva() {
           print("🟢 Confitería desde RESERVA")
       }

       func configurarModoIndependiente() {
           print("🔵 Confitería desde TAB BAR")
       }
       
       @IBAction func btnContinuar(_ sender: UIButton) {
           guard modo == .reserva else { return }
           //devolver total snakcs
           seleccionAsientosVC?.totalSnacks = totalSnacks
           dismiss(animated: true)
       }
       
       func configurarUIsegunModo() {
           switch modo {
           case .independiente:
               btnContinuar.isHidden = true
               print("🔵 UI: Botón continuar oculto (modo independiente)")

           case .reserva:
               btnContinuar.isHidden = false
               print("🟢 UI: Botón continuar visible (modo reserva)")
           }
       }

   }
