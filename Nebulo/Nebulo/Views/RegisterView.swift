//
//  RegisterView.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var validationError: String? = nil

    private var maxDate: Date {
        Calendar.current.date(byAdding: .year, value: -13, to: Date()) ?? Date()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                header
                formFields
                registerButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.accent)
        .onAppear { viewModel.errorMessage = nil }
    }

    var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.beigeClear)
                    .font(.system(size: 20, weight: .bold))
            }
            Spacer()
            Text("Créer un compte")
                .font(.system(size: 22))
                .fontWeight(.black)
                .foregroundStyle(.beigeClear)
            Spacer()
            // Spacer fantôme pour centrer le titre
            Image(systemName: "chevron.left")
                .opacity(0)
                .font(.system(size: 20))
        }
        .padding(.top, 20)
    }

    var formFields: some View {
        VStack(alignment: .leading, spacing: 20) {
            CustomTextField(data: $firstname, label: "Prénom", widthTextField: 315)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)

            CustomTextField(data: $lastname, label: "Nom", widthTextField: 315)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)

            CustomTextField(data: $email, label: "Email", widthTextField: 315)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            CustomTextField(data: $password, label: "Mot de passe", widthTextField: 315, isSecure: true)
                .textContentType(.newPassword)

            CustomTextField(data: $confirmPassword, label: "Confirmer le mot de passe", widthTextField: 315, isSecure: true)
                .textContentType(.newPassword)

            datePicker

            if let error = validationError ?? viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.system(size: 14))
                    .padding(.leading, 4)
            }
        }
    }

    var datePicker: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(.beigeClear)
                .frame(width: 315, height: 62)
            DatePicker(
                "Date de naissance",
                selection: $dateOfBirth,
                in: ...maxDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .font(.system(size: 18))
            .fontWeight(.black)
            .foregroundStyle(.accent.opacity(0.47))
            .padding(.horizontal, 12)
            .frame(width: 315)
        }
    }

    var registerButton: some View {
        Button {
            guard validate() else { return }
            Task {
                await viewModel.register(
                    firstname: firstname,
                    lastname: lastname,
                    email: email,
                    password: password,
                    dateOfBirth: dateOfBirth
                )
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.orangeCustom)
                    .frame(width: 223, height: 58)
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("S'inscrire")
                        .font(.system(size: 20))
                        .fontWeight(.black)
                        .foregroundStyle(.accent)
                }
            }
        }
        .disabled(viewModel.isLoading)
    }

    private func validate() -> Bool {
        validationError = nil

        guard !firstname.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationError = "Le prénom est requis"
            return false
        }
        guard !lastname.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationError = "Le nom est requis"
            return false
        }
        guard email.contains("@"), email.contains(".") else {
            validationError = "Adresse email invalide"
            return false
        }
        guard password.count >= 8 else {
            validationError = "Le mot de passe doit contenir au moins 8 caractères"
            return false
        }
        guard password == confirmPassword else {
            validationError = "Les mots de passe ne correspondent pas"
            return false
        }
        return true
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
