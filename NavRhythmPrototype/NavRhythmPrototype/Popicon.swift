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
            
            Color.white

            VStack() {
               
                
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                
                Spacer().frame(height: 1)
                
                Text("Welcome to NavRhythm!")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding()
               
        
            }


        }
        .edgesIgnoringSafeArea(.all)
    }

       
    }


struct PopUpIcon_Previews: PreviewProvider {
    static var previews: some View {
        PopUpIcon()
    }
}
