// Devuelve el SSID de la red Wi-Fi actual.
//
// Desde macOS 14 el SSID esta redactado ("<redacted>") para cualquier proceso
// sin autorizacion de Localizacion, y `airport` ya no existe. sketchybar corre
// bajo launchd y nunca llama a CoreLocation, asi que jamas dispara el dialogo
// de permiso: por eso no aparece en Ajustes > Privacidad > Localizacion y no
// hay forma de habilitarlo desde ahi.
//
// Este binario si llama a CoreLocation, con lo que locationd lo registra como
// cliente y queda visible en esa lista para poder autorizarlo una sola vez.
// Despues sketchybar solo lo ejecuta y lee su salida.
//
// Compilar:  swiftc -O ssid.swift -o ssid
// Salida:    el SSID en stdout, o codigo 1 si no hay Wi-Fi / falta permiso.

import Foundation
import CoreLocation
import CoreWLAN

final class LocationGate: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var settled = false

    func waitForAuthorization(timeout: TimeInterval) {
        manager.delegate = self
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            settled = true
        }
        let deadline = Date().addingTimeInterval(timeout)
        while !settled && Date() < deadline {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .notDetermined { settled = true }
    }
}

// Referencia fuerte: CLLocationManager.delegate es weak, y un temporal se
// liberaria antes de que llegue la respuesta de autorizacion.
let gate = LocationGate()
gate.waitForAuthorization(timeout: 10)

guard let ssid = CWWiFiClient.shared().interface()?.ssid(),
      !ssid.isEmpty, ssid != "<redacted>" else {
    exit(1)
}
print(ssid)
