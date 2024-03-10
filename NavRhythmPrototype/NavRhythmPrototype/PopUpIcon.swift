//
//  PopUpIcon.swift
//  NavRhythmPrototype
//
//  Created by Dulce on 3/10/24.
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
