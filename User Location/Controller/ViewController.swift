//
//  ViewController.swift
//  User Location
//
//  Created by Jay Phillips on 2/17/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    //Create the location manager and initialize it.
    let locationManager = CLLocationManager()
    
    // Create a constant as type Double for region settings.
    let regionInMeters: Double = 1000
    
    var previousLocation: CLLocation?
    
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the mapView delegate
        mapView.delegate = self
        setupLocationManager()
    }
    
    @IBAction func goButtonTapped(_ sender: UIButton) {
        getDirections()
    }


}

// MARK: MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    // Function to center the map's view on the user's location
    func centerViewOnUserLocation() {
        // Unwrap the locationManager coordinate to make sure it is not nil
        if let location = locationManager.location?.coordinate {
            // If locationManager is not nil, create a region and initialize it.
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            // Set the region
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Function to setup location manager.
    func setupLocationManager() {
        // Set the location manager delegate.
        locationManager.delegate = self
        // Determine the location accuracy.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Function to check and see if location services are turned on.
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // Setup location manager, then check for authorization
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    // Function to check permissions to location.
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            break
        case .notDetermined:
            // Request permission to location services.
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // Show an alert letting them know that it is restricted.
            let alert = UIAlertController(title: "Warning", message: "Your device has been restricted.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        break
        case .authorizedAlways:
            startTrackingUserLocation()
        @unknown default:
            // Show an alert stating there was an error.
            let alert = UIAlertController(title: "Warning", message: "There was an error. Could not determine authorization", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        break
        }
    }
    
    // Function to start the user location tracking
    func startTrackingUserLocation() {
        // Show the blue dot where the user is located at.
        mapView.showsUserLocation = true
        // Center the map on the user's location.
        centerViewOnUserLocation()
        // Start updating the user's location.
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    // Function to center location
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Function to get directions.
    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            // TODO: Inform the user that we don't have their current location
            return
        }
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response, error) in
            //TODO: Handle error if needed
            guard let response = response else { return } //TODO: show response not available in an alert
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    // Function to create a request to get directions
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = getCenterLocation(for: mapView).coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    // Function to reset mapview with new directions
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.cancelGeocode()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            if let _ = error {
                //TODO: Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                // Show error to user
                return
                
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self?.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}

// MARK: CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    // This will do something when the user changes authorization. In this case, we will check for authorization.

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationServices()
    }
    
}


