//
//  Popicon.swift
//  NavRhythmPrototype
//
//  Created by Dulce & Flor on 3/12/24.
//


import SwiftUI

struct PopUpIcon: View {
    var body: some View {
        ZStack {
            Image("Icon")

                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text("Welcome to NavRhythm!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                
                .padding()
        }
        .background(Color.green)
    }
}

struct PopUpIcon_Previews: PreviewProvider {
    static var previews: some View {
        PopUpIcon()
    }
}
