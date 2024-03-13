//
//  SearchBar.swift
//  NavRhythmPrototype
//
//  Created by Dulce on 3/1/24.
//

import SwiftUI
import MapKit


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
    @State private var flag = false
    @State private var flag2 = false
    @Binding var destinationInput: String

    @Binding var searchPopulatedResults: [MKLocalSearchCompletion] // saves locations
    @State private var searchPopulate = MKLocalSearchCompleter() // built in mapkit function
    private var searchBarD: SearchPopulate // to get locations from database var
    
    // grab values from content view
    init( destinationInput : Binding<String>, searchPopulatedResults: Binding<[MKLocalSearchCompletion]>) {
 
        _destinationInput = destinationInput
        _searchPopulatedResults = searchPopulatedResults
        searchBarD = SearchPopulate(searchResults: searchPopulatedResults)
    }

    var body: some View {
        ZStack {
            VStack {
            VStack {

                
                TextField("Destination", text: $destinationInput, onEditingChanged: { _ in
                    searchPopulate.queryFragment = destinationInput
                })
                .background(Color.gray.opacity(0.1))
                .cornerRadius(5)
                
            }
            .padding()
            .frame(maxWidth: .infinity)
            
            if !flag2 && !destinationInput.isEmpty { // list the search bar for destination input
                // display results in a list
                List(searchPopulatedResults, id: \.title)
                { result in // used as a loop
                    VStack(alignment: .leading) { // fix format
                        Text(result.title)
                        Text(result.subtitle).font(.caption) // make smaller
                            .foregroundColor(.gray) // font color
                    }
                    .onTapGesture {
                        if let index = searchPopulatedResults.firstIndex(where: { $0.title == result.title }) {
                            let pickTitle = searchPopulatedResults[index].title
                            let pickSubtitle = searchPopulatedResults[index].subtitle
                            let fullAddress = "\(pickTitle) \(pickSubtitle)"
                            
                            $destinationInput.wrappedValue = fullAddress
                            flag2.toggle()
                        }
                    }
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                flag2 = false  // reset value
                            }
                    )
                }
            }
            
        }
        .onAppear {
            searchPopulate.delegate = searchBarD
        }
        .onChange(of: destinationInput) {
            searchPopulate.queryFragment = destinationInput
        }

        }
    }
}
