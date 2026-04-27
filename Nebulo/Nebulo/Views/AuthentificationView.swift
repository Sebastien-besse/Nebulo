//
//  AuthentificationView.swift
//  Nebulo
//
//  Created by apprenant152 on 16/03/2026.
//

import SwiftUI

struct AuthentificationView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showRegister: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 50) {
                Image("Logo-Nebulo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)

                textFieldGroup
                buttonSign
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.accent)
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(viewModel)
        }
    }

    var textFieldGroup: some View {
        VStack(alignment: .leading, spacing: 25) {
            CustomTextField(data: $email, label: "Email", widthTextField: 315)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            HStack(spacing: 20) {
                CustomTextField(data: $password, label: "Mot de passe", widthTextField: 235, isSecure: true)
                    .textContentType(.password)
                buttonAuth
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.system(size: 14))
                    .padding(.leading, 4)
            }
        }
    }

    var buttonAuth: some View {
        Button {
            Task {
                await viewModel.login(email: email, password: password)
            }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .frame(width: 67, height: 67)
            } else {
                Image("button-auth")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 67, height: 67)
            }
        }
        .disabled(viewModel.isLoading)
    }

    var buttonSign: some View {
        ButtonAction(name: "Créer un compte", action: {
            showRegister = true
        })
    }
}

#Preview {
    AuthentificationView()
        .environmentObject(AuthViewModel())
}
