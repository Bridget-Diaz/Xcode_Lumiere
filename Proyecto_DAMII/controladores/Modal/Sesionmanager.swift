//
//  Sesionmanager.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 15/12/25.
//

import UIKit

class Sesionmanager {
    
    static let shared = Sesionmanager()
       private init() {}

       private let defaults = UserDefaults.standard

       private let keyLogged = "isLogged"
       private let keyCorreo = "correoLogueado"

       var isLogged: Bool {
           defaults.bool(forKey: keyLogged)
       }

       var correo: String? {
           defaults.string(forKey: keyCorreo)
       }

       func login(correo: String) {
           defaults.set(true, forKey: keyLogged)
           defaults.set(correo, forKey: keyCorreo)
       }

       func logout() {
           defaults.set(false, forKey: keyLogged)
           defaults.removeObject(forKey: keyCorreo)
       }
}
