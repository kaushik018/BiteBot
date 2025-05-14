import SwiftUI
import FirebaseAuth

enum AuthenticationState {
    case signIn
    case signUp
}

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var name = ""
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let primaryBrown = Color(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999)
    
    // Password validation
    private func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // Email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func signIn(completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = self?.handleAuthError(error) ?? "Sign in failed"
                    self?.showError = true
                    completion(false)
                } else {
                    // Save user session
                    UserDefaults.standard.set(true, forKey: "isAuthenticated")
                    completion(true)
                }
            }
        }
    }
    
    func signUp(completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        guard isValidPassword(password) else {
            errorMessage = "Password must be at least 8 characters and contain uppercase, lowercase, and numbers"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.isLoading = false
                    self?.errorMessage = self?.handleAuthError(error) ?? "Sign up failed"
                    self?.showError = true
                    completion(false)
                    return
                }
                
                // Update user profile with name
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self?.name
                changeRequest?.commitChanges { [weak self] error in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if let error = error {
                            self?.errorMessage = "Failed to update profile: \(error.localizedDescription)"
                            self?.showError = true
                            completion(false)
                        } else {
                            // Save user session
                            UserDefaults.standard.set(true, forKey: "isAuthenticated")
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    func resetPassword(email: String) {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            showError = true
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        isLoading = true
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = self?.handleAuthError(error) ?? "Password reset failed"
                    self?.showError = true
                } else {
                    self?.errorMessage = "Password reset email sent. Please check your inbox."
                    self?.showError = true
                }
            }
        }
    }
    
    private func handleAuthError(_ error: Error) -> String {
        let authError = error as NSError
        switch authError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Invalid email or password"
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email address"
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Email is already in use"
        case AuthErrorCode.weakPassword.rawValue:
            return "Password is too weak"
        case AuthErrorCode.userNotFound.rawValue:
            return "Account not found"
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please try again"
        default:
            return "Authentication failed: \(error.localizedDescription)"
        }
    }
}

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var authState: AuthenticationState = .signIn
    @State private var animateBackground = false
    @Binding var isAuthenticated: Bool
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var showForgotPasswordView = false
    
    private let primaryBrown = Color(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated background
                LinearGradient(
                    gradient: Gradient(colors: [
                        primaryBrown.opacity(0.1),
                        Color.white,
                        primaryBrown.opacity(0.05)
                    ]),
                    startPoint: animateBackground ? .topLeading : .bottomTrailing,
                    endPoint: animateBackground ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                        animateBackground.toggle()
                    }
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Logo with animation
                        Image("Bitebotlogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(.top, 100)
                            .scaleEffect(animateBackground ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateBackground)
                        
                        // Title with slide-in animation
                        Text(authState == .signIn ? "Welcome Back" : "Create Account")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(primaryBrown)
                            .transition(.slide)
                        
                        // Auth Form with fade-in animation
                        VStack(spacing: 16) {
                            if authState == .signUp {
                                AuthTextField(
                                    text: $viewModel.name,
                                    placeholder: "Username",
                                    icon: "person.fill"
                                )
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                            }
                            
                            AuthTextField(
                                text: $viewModel.email,
                                placeholder: "Email",
                                icon: "envelope.fill"
                            )
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            
                            AuthTextField(
                                text: $viewModel.password,
                                placeholder: "Password",
                                icon: "lock.fill",
                                isSecure: true
                            )
                            
                            if authState == .signUp {
                                AuthTextField(
                                    text: $viewModel.confirmPassword,
                                    placeholder: "Confirm Password",
                                    icon: "lock.fill",
                                    isSecure: true
                                )
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            // Action Button with loading state
                            Button(action: {
                                if authState == .signIn {
                                    viewModel.signIn { success in
                                        if success {
                                            withAnimation {
                                                isAuthenticated = true
                                                userSettings.isLoggedIn = true
                                            }
                                        }
                                    }
                                } else {
                                    viewModel.signUp { success in
                                        if success {
                                            withAnimation {
                                                isAuthenticated = true
                                                userSettings.isLoggedIn = true
                                            }
                                        }
                                    }
                                }
                            }) {
                                HStack {
                                    Text(authState == .signIn ? "Sign In" : "Create Account")
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
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .shadow(color: primaryBrown.opacity(0.3), radius: 5, y: 2)
                            }
                            .disabled(viewModel.isLoading)
                            
                            if authState == .signIn {
                                Button("Forgot Password?") {
                                    // Handle forgot password
                                    showForgotPasswordView = true
                                }
                                .foregroundColor(primaryBrown)
                                .font(.system(size: 14))
                                .sheet(isPresented: $showForgotPasswordView) {
                                    ForgotPasswordView()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Switch Auth State with animation
                        HStack(spacing: 8) {
                            Text(authState == .signIn ? "Don't have an Account?" : "Already have an Account?")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            Button(authState == .signIn ? "Sign Up" : "Sign In") {
                                withAnimation(.spring()) {
                                    authState = authState == .signIn ? .signUp : .signIn
                                }
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(primaryBrown)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .preferredColorScheme(.light)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isSecure: Bool = false
    
    private let primaryBrown = Color(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999)
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(primaryBrown.opacity(0.7))
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .frame(height: 50)
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(primaryBrown.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(isAuthenticated: .constant(false))
    }
} 
