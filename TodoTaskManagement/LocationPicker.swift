//
//  Untitled 2.swift
//  TodoTaskManagement
//
//  Created by Nagaraj, Vignesh  on 10/03/25.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedLocation: TaskLocation? // Pass this from TaskEditView
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var currentLocation: CLLocationCoordinate2D?
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: currentAnnotations()) { _ in
                MapPin(coordinate: currentLocation ?? region.center, tint: .red)
            }
            .onTapGesture {
                updateCurrentLocation(to: region.center)
            }
            
            Button("Set Location") {
                if let location = currentLocation {
                    selectedLocation = TaskLocation(
                        latitude: location.latitude,
                        longitude: location.longitude,
                        radius: 100, // Use a default or custom radius
                        name: "Selected Location" 
                    )
                }
                presentationMode.wrappedValue.dismiss()
            }

            .padding()
        }
        .navigationTitle("Pick Location")
        .onAppear {
            if let selectedLocation = selectedLocation {
                region.center = CLLocationCoordinate2D(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
            }
        }
    }
    
    private func updateCurrentLocation(to location: CLLocationCoordinate2D) {
        currentLocation = location
    }
    
    private func currentAnnotations() -> [UUID] {
        return [UUID()] // Example placeholder
    }
    private func currentAnnotations() -> [Annotation] {
           return [
               Annotation(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)) // Example annotation
           ]
       }
}
struct Annotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
