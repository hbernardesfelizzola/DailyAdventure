//
//  WeatherProvider.swift
//  DailyAdventure
//

import Foundation
import CoreLocation
import WeatherKit

@Observable
@MainActor
final class WeatherProvider: NSObject {
    private(set) var temperatureString: String?
    private(set) var conditionSymbolName: String?

    private let locationManager = CLLocationManager()
    private var lastFetchDate: Date?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func fetchIfNeeded() {
        if let last = lastFetchDate, Calendar.current.isDateInToday(last) { return }
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }

    private func fetch(for location: CLLocation) {
        Task {
            do {
                let weather = try await WeatherService.shared.weather(for: location)
                temperatureString = weather.currentWeather.temperature
                    .formatted(.measurement(width: .narrow, usage: .weather))
                conditionSymbolName = weather.currentWeather.symbolName
                lastFetchDate = Date()
            } catch {
                // Weather is a non-critical feature — silently degrade on failure
            }
        }
    }
}

extension WeatherProvider: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in self.fetch(for: location) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in self.fetchIfNeeded() }
    }
}
