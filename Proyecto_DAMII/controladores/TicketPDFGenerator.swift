//
//  TicketPDFGenerator.swift
//  Proyecto_DAMII
//
//  Created by DAMII on 13/12/25.
//

import UIKit
import PDFKit

class TicketPDFGenerator {
    static func generarTicket(
            pelicula: String,
            cine: String,
            ciudad: String,
            fecha: String,
            horario: String,
            butacas: [String],
            totalAsientos: Double,
            totalSnacks: Double,
            totalPagado: Double
        ) -> URL? {
            
            let pdfMetaData = [
                kCGPDFContextCreator: "Lumiere App",
                kCGPDFContextTitle: "Ticket de Compra"
            ]
            
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData as [String: Any]
            
            //Tamaño de página (carta: 8.5 x 11 pulgadas)
            let pageWidth = 8.5 * 72.0
            let pageHeight = 11 * 72.0
            let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
            
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
            
            //Guardar en directorio temporal con nombre único
            let timestamp = Date().timeIntervalSince1970
            let filePath = FileManager.default.temporaryDirectory
                .appendingPathComponent("Ticket_\(Int(timestamp)).pdf")
            
            do {
                try renderer.writePDF(to: filePath) { context in
                    context.beginPage()
                    
                    var yPosition: CGFloat = 50
                    
                    //TÍTULO PRINCIPAL
                    let titulo = "🎬 TICKET DE COMPRA"
                    let tituloFont = UIFont.boldSystemFont(ofSize: 26)
                    let tituloAttributes: [NSAttributedString.Key: Any] = [
                        .font: tituloFont,
                        .foregroundColor: UIColor.systemBlue
                    ]
                    let tituloSize = titulo.size(withAttributes: tituloAttributes)
                    let tituloX = (pageWidth - tituloSize.width) / 2  // Centrar
                    titulo.draw(at: CGPoint(x: tituloX, y: yPosition), withAttributes: tituloAttributes)
                    yPosition += 50
                    
                    //LÍNEA SEPARADORA
                    dibujarLinea(x: 50, y: yPosition, ancho: pageWidth - 100, color: .systemBlue)
                    yPosition += 30
                    
                    //Función helper para agregar texto
                    func agregarTexto(_ texto: String, bold: Bool = false, size: CGFloat = 14) {
                        let font = bold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
                        let attributes: [NSAttributedString.Key: Any] = [
                            .font: font,
                            .foregroundColor: UIColor.black
                        ]
                        texto.draw(at: CGPoint(x: 70, y: yPosition), withAttributes: attributes)
                        yPosition += size == 14 ? 25 : 30
                    }
                    
                    //INFORMACIÓN DE LA PELÍCULA
                    agregarTexto("📽️ PELÍCULA", bold: true, size: 16)
                    agregarTexto(pelicula, size: 15)
                    yPosition += 10
                    
                    //UBICACIÓN
                    agregarTexto("📍 UBICACIÓN", bold: true, size: 16)
                    agregarTexto("\(cine)", size: 15)
                    agregarTexto("\(ciudad)", size: 15)
                    yPosition += 10
                    
                    //FECHA Y HORA
                    agregarTexto("📅 FECHA Y HORA", bold: true, size: 16)
                    agregarTexto("Fecha: \(fecha)", size: 15)
                    agregarTexto("Horario: \(horario)", size: 15)
                    yPosition += 10
                    
                    //ASIENTOS
                    agregarTexto("💺 ASIENTOS SELECCIONADOS", bold: true, size: 16)
                    let butacasTexto = butacas.joined(separator: ", ")
                    agregarTexto(butacasTexto, size: 15)
                    yPosition += 20
                    
                    //LÍNEA SEPARADORA
                    dibujarLinea(x: 50, y: yPosition, ancho: pageWidth - 100, color: .lightGray)
                    yPosition += 30
                    
                    //DESGLOSE DE PRECIOS
                    agregarTexto("💰 DESGLOSE DE PAGO", bold: true, size: 16)
                    
                    //Entradas
                    let cantidadAsientos = butacas.count
                    agregarTexto("Entradas (\(cantidadAsientos) x S/ 20.00): S/ \(String(format: "%.2f", totalAsientos))")
                    
                    //Confitería
                    if totalSnacks > 0 {
                        agregarTexto("Confitería: S/ \(String(format: "%.2f", totalSnacks))")
                    } else {
                        agregarTexto("Confitería: S/ 0.00")
                    }
                    
                    yPosition += 10
                    
                    //LÍNEA SEPARADORA
                    dibujarLinea(x: 50, y: yPosition, ancho: pageWidth - 100, color: .systemBlue, grosor: 2)
                    yPosition += 25
                    
                    //tOTAL PAGADO (destacado)
                    let totalTexto = "TOTAL PAGADO: S/ \(String(format: "%.2f", totalPagado))"
                    let totalFont = UIFont.boldSystemFont(ofSize: 20)
                    let totalAttributes: [NSAttributedString.Key: Any] = [
                        .font: totalFont,
                        .foregroundColor: UIColor.systemGreen
                    ]
                    let totalSize = totalTexto.size(withAttributes: totalAttributes)
                    let totalX = (pageWidth - totalSize.width) / 2  // Centrar
                    totalTexto.draw(at: CGPoint(x: totalX, y: yPosition), withAttributes: totalAttributes)
                    yPosition += 50
                    
                    //CÓDIGO DE COMPRA (simulado)
                    let codigoCompra = "CP-\(Int(timestamp))"
                    agregarTexto("Código de compra:", bold: true)
                    agregarTexto(codigoCompra, size: 12)
                    yPosition += 20
                    
                    //NOTA IMPORTANTE
                    let nota = "⚠️ Presenta este ticket en la entrada del cine."
                    let notaFont = UIFont.italicSystemFont(ofSize: 12)
                    let notaAttributes: [NSAttributedString.Key: Any] = [
                        .font: notaFont,
                        .foregroundColor: UIColor.darkGray
                    ]
                    nota.draw(at: CGPoint(x: 70, y: yPosition), withAttributes: notaAttributes)
                    
                    //PIE DE PÁGINA
                    yPosition = pageHeight - 60
                    let footer = "Gracias por tu compra | Lumiere App"
                    let footerFont = UIFont.systemFont(ofSize: 11)
                    let footerAttributes: [NSAttributedString.Key: Any] = [
                        .font: footerFont,
                        .foregroundColor: UIColor.gray
                    ]
                    let footerSize = footer.size(withAttributes: footerAttributes)
                    let footerX = (pageWidth - footerSize.width) / 2  // Centrar
                    footer.draw(at: CGPoint(x: footerX, y: yPosition), withAttributes: footerAttributes)
                    
                    //Fecha de generación
                    let fechaGeneracion = "Generado el: \(obtenerFechaActual())"
                    let fechaFont = UIFont.systemFont(ofSize: 9)
                    let fechaAttributes: [NSAttributedString.Key: Any] = [
                        .font: fechaFont,
                        .foregroundColor: UIColor.lightGray
                    ]
                    let fechaSize = fechaGeneracion.size(withAttributes: fechaAttributes)
                    let fechaX = (pageWidth - fechaSize.width) / 2  // Centrar
                    fechaGeneracion.draw(at: CGPoint(x: fechaX, y: yPosition + 20), withAttributes: fechaAttributes)
                }
                
                print("✅ PDF generado exitosamente en: \(filePath)")
                return filePath
                
            } catch {
                print("❌ Error al generar PDF:", error.localizedDescription)
                return nil
            }
        }
        
        static func dibujarLinea(x: CGFloat, y: CGFloat, ancho: CGFloat, color: UIColor, grosor: CGFloat = 1) {
            let lineRect = CGRect(x: x, y: y, width: ancho, height: grosor)
            color.setFill()
            UIBezierPath(rect: lineRect).fill()
        }
        
        static func obtenerFechaActual() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            return formatter.string(from: Date())
        }
        
        static func compartirTicket(desde viewController: UIViewController, pdfURL: URL) {
            let activityVC = UIActivityViewController(
                activityItems: [pdfURL],
                applicationActivities: nil
            )
            
            //Para iPad (evita crash)
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                           y: viewController.view.bounds.midY,
                                           width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            viewController.present(activityVC, animated: true)
        }
}
