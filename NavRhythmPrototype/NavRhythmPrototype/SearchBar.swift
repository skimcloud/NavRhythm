//
//  SearchBar.swift
//  NavRhythmPrototype
//
//  Created by Dulce on 3/1/24.
//

import SwiftUI
import MapKit

// need to use class to use mapkit MKLocalSearchCompleter
// error if i don't put NSObject
class SearchPopulate: NSObject, MKLocalSearchCompleterDelegate { /// need MKLocalSearchCompleterDelegate to use the mapkit location database
    var searchResults: Binding<[MKLocalSearchCompletion]>
    init(searchResults: Binding<[MKLocalSearchCompletion]>) {
        self.searchResults = searchResults // get var of mapkit
    }
    
    // completerDidUpdateResults method in mapkit
    func completerDidUpdateResults(_ searchBar: MKLocalSearchCompleter) {
        searchResults.wrappedValue = searchBar.results
    }

}

struct SearchBarView: View {
    @Binding var destinationInput: String
    @Binding var startInput : String
    @Binding var searchPopulatedResults: [MKLocalSearchCompletion] // saves locations
    @State private var searchPopulate = MKLocalSearchCompleter() // built in mapkit function
    private var searchBarD: SearchPopulate // to get locations from database var
    
    // grab values from content view
    init(startInput : Binding<String>, destinationInput : Binding<String>, searchPopulatedResults: Binding<[MKLocalSearchCompletion]>) {
        _startInput = startInput
        _destinationInput = destinationInput
        _searchPopulatedResults = searchPopulatedResults
        searchBarD = SearchPopulate(searchResults: searchPopulatedResults)
    }

    var body: some View {
        VStack {
            VStack {
                TextField("Start", text: $startInput, onEditingChanged: { _ in
                    searchPopulate.queryFragment = startInput
                })
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)
                
                TextField("Destination", text: $destinationInput, onEditingChanged: { _ in
                    searchPopulate.queryFragment = destinationInput
                })
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(5)

            }
            .padding()
            .frame(maxWidth: .infinity)
            
            if !destinationInput.isEmpty { // list the search bar for destination input
                // display results in a list
                List(searchPopulatedResults, id: \.title) 
                { result in // used as a loop 
                    VStack(alignment: .leading) { // fix format
                        Text(result.title)
                        Text(result.subtitle).font(.caption) // make smaller
                         .foregroundColor(.gray) // font color
                    }
                }
            }
            if !startInput.isEmpty { // list the search bar for start input
                List(searchPopulatedResults, id: \.title) { result in
                    VStack(alignment: .leading) {
                        Text(result.title)
                        Text(result.subtitle).font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear {
            searchPopulate.delegate = searchBarD
        }
        // when  text input destination changes
        .onChange(of: destinationInput) { _ in
            searchPopulate.queryFragment = destinationInput
        }
        // when  text input of  start changes
        .onChange(of: startInput) { _ in
            searchPopulate.queryFragment = startInput
        }
    }
}
