//
//  LoginView.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct LoginView: View {
    let viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("Welcome to FartTok")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button("Sign In") {
                viewModel.signIn()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green)
            )
            .padding(.horizontal)
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
