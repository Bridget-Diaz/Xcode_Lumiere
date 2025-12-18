//
//  Snack.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 11/12/25.
//

import UIKit
import CoreData
import Foundation

@objc(Snack)
class Snack: NSManagedObject {
        
    //creado de manera manual xd ,en la otra maquina no funcionaba y lo hice asi
        //Ejemplo de propiedad calculada para obtener la imagen fácilmente:
        public var uiImage: UIImage? {
            // 'imagen' es el atributo Binary Data definido en Core Data
            guard let imageData = self.imagen else { return nil }
            return UIImage(data: imageData)
        }
}

extension Snack {
    //@NSManaged indica que Core Data es responsable de implementar estas propiedades
    @NSManaged public var id: Int32
    @NSManaged public var nombre: String?
    @NSManaged public var descripcion: String?
    @NSManaged public var precio: Double
    @NSManaged public var categoria: String?
    @NSManaged public var imagen: Data?
}


extension Snack : Identifiable {
//para los request p
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Snack> {
        return NSFetchRequest<Snack>(entityName: "Snack")
    }
}
