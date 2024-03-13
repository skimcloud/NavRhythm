//
//  vibration.swift
//  NavRhythmPrototype
//
//  Created by Dulce on 3/10/24.
//


import SwiftUI

struct VibrationView: View {
    @State private var customOpen = false
    @State private var option = "Light"
    let listValues = ["Light", "Medium", "Strong"] // list of strings
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    customOpen.toggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit) // makes the image fit
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $customOpen) {
            VStack {
                Text("Customize Vibration Intensity")
                    .foregroundColor(.black)
      
                
                Picker(selection: $option, label: Text("patternweight")) {
                    ForEach(listValues, id: \.self) {
                        Text($0) // take from index of 0
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                Button("Close") {
                    customOpen.toggle()
                }
                .padding()
            }
            .background(Color.white)
            .padding()
         
        }
    }
}




