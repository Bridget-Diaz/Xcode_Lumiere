import Foundation
import CoreData
import UIKit

class UserDataManager {

    static let shared = UserDataManager()

    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //REGISTRAR USUARIO
    func registrarUsuario(datos: [String: Any]) -> Bool {
        // Evitar correos duplicados
        if obtenerUsuarioPorCorreo(datos["correo"] as! String) != nil {
            return false
        }

        let usuario = Usuario(context: context)
        usuario.nombres = datos["nombres"] as? String
        usuario.apellidos = datos["apellidos"] as? String
        usuario.correo = datos["correo"] as? String
        usuario.telefono = datos["telefono"] as? String
        usuario.genero = datos["genero"] as? String
        usuario.fechaNacimiento = datos["fechaNacimiento"] as? Date
        usuario.dni = datos["dni"] as? String
        usuario.contrasena = datos["contrasena"] as? String

        do {
            try context.save()
            return true
        } catch {
            print("Error guardando:", error)
            return false
        }
    }

    //LOGIN
    func validarLogin(correo: String, contrasena: String) -> Bool {
        if let user = obtenerUsuarioPorCorreo(correo) {
            return user.contrasena == contrasena
        }
        return false
    }

    //OBTENER USUARIO
    func obtenerUsuarioPorCorreo(_ correo: String) -> Usuario? {
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "correo == %@", correo)

        do {
            return try context.fetch(request).first
        } catch {
            print("Error al buscar:", error)
            return nil
        }
    }
}
