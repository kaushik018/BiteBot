//
//  ForgotPasswordView.swift
//  RestaurantRecommender
//
//  Created by RENIK MULLER on 11/03/2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var email = ""
    
    private let primaryBrown = Color(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999)
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [
                    primaryBrown.opacity(0.1),
                    Color.white,
                    primaryBrown.opacity(0.05)
                ]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Forgot Password")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(primaryBrown)
                        
                        Text("Reset your password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                    
                    //Email Field
                    AuthTextField(text: $email, placeholder: "Email", icon: "envelope.fill")
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal)
                    
                    //Reset Password Button
                    Button(action: {
                        viewModel.resetPassword(email: email)
                    }) {
                        HStack {
                            Text("Reset Password")
                                .fontWeight(.semibold)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.leading, 8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(primaryBrown)
                        .foregroundStyle(.white)
                        .cornerRadius(25)
                        .shadow(color: primaryBrown.opacity(0.3), radius: 5, y: 2)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
