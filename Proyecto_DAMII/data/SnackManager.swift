//
//  SnackManager.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 11/12/25.
//

import UIKit
import CoreData
import Foundation

struct SnackEntity{
     let id: Int
     let nombre: String
     let descripcion: String
     let precio: Double
     let imagen: UIImage?
     let categoria: CategoriaSnack
}

enum CategoriaSnack :String{
     case canchita = "canchita"
     case bebida = "bebida"
     case combo = "combo"
}

class SnackManager {

    static let shared = SnackManager()
    
    //Obtenemos el contexto de Core Data
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    
    //Lista de todos los snacks iniciales para el 'seeding'
    private let initialSnacks: [SnackEntity] = [
        //canchis
        SnackEntity(id: 1, nombre: "Canchita mediana", descripcion: "Canchita clásica con mantequilla", precio: 8.50, imagen: UIImage(named: "canchita1"), categoria: .canchita),
        SnackEntity(id: 2, nombre: "Canchita grande", descripcion: "Canchita grande para compartir", precio: 12.00, imagen: UIImage(named: "canchita2"), categoria: .canchita),

        //cocacolaespuma
        SnackEntity(id: 3, nombre: "Gaseosa", descripcion: "Vaso grande con gaseosa y pajita", precio: 6.00, imagen: UIImage(named: "bebida1"), categoria: .bebida),
        SnackEntity(id: 4, nombre: "Gaseosa pero mas negra xd", descripcion: "Refrescante gaseosa con hielos", precio: 5.50, imagen: UIImage(named: "bebida2"), categoria: .bebida),

        //boeeeee
        SnackEntity(id: 5, nombre: "Combo 1", descripcion: "Canchita + Gaseosas", precio: 15.00, imagen: UIImage(named: "combo1"), categoria: .combo),
        SnackEntity(id: 6, nombre: "Combo 2", descripcion: "Canchita grande + 1 bebida", precio: 20.00, imagen: UIImage(named: "combo2"), categoria: .combo),
        SnackEntity(id: 7, nombre: "Combo 3", descripcion: "Mega canchita + bebida + hotdog", precio: 25.00, imagen: UIImage(named: "combo3"), categoria: .combo)
    ]
    
 
    func seedInitialSnacks() {
        let request: NSFetchRequest<Snack> = Snack.fetchRequest()
        
        do {
            //Verificar si ya existen snacks en la BD
            let count = try context.count(for: request)
            
            if count > 0 {
                print("✅ Core Data: Datos de snacks ya existen. No se requiere seeding.")
                return // Si hay datos,... NADA XDDDD
            }
            
            //Si no hay datos, guardar todos los snacks iniciales
            print("⏳ Core Data: Inicializando la base de datos de snacks...")
            for snackEntity in initialSnacks {
                
                //Crear un nuevo objeto Core Data 'Snack'
                let newSnack = Snack(context: context)
                
                //Asignar propiedades
                newSnack.id = Int32(snackEntity.id)
                newSnack.nombre = snackEntity.nombre
                newSnack.descripcion = snackEntity.descripcion
                newSnack.precio = snackEntity.precio
                newSnack.categoria = snackEntity.categoria.rawValue
                
                //Convertir UIImage a Data para guardarlo en Core Data
                newSnack.imagen = snackEntity.imagen?.pngData()
            }
            
            //Guardar el contexto (persistencia)
            try context.save()
            print("🎉 Core Data: Datos iniciales guardados exitosamente.")
            
        } catch {
            print("❌ Error al verificar o guardar datos iniciales: \(error)")
        }
    }
}
