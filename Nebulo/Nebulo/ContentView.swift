//
//  ContentView.swift
//  Nebulo
//
//  Created by apprenant152 on 12/03/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            AuthentificationView()
                .onAppear {
                    sleep(2)
                }
        }
    }
}

#Preview {
    ContentView()
}
