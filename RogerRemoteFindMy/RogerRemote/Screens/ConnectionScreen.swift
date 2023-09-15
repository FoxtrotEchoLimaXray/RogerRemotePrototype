//
//  ConnectionScreen.swift
//  RogerRemote
//
//  Created by El-Hoiydi, Felix on 08.09.23.
//

import SwiftUI

struct ConnectionScreen: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint:.black))
                .scaleEffect(1.5)
            Spacer()
                .frame(height: 20)
            Text("Connection")
            
        }
        .padding()
        .navigationBarBackButtonHidden()
    }
}

struct ConnectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionScreen()
    }
}


