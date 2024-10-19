import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var loginStatus: String = ""
    @State private var isRegister: Bool = false
    @State private var isLogin: Bool = false
    @ObservedObject var settings: DebugSettings
    private var authService: AuthService

    init(settings: DebugSettings) {
        self.settings = settings
        self.authService = AuthService(settings: settings) // Inject DebugSettings into AuthService
    }

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 15) {
                    Text("Email")
                        .foregroundColor(.white)
                        .font(.headline)

                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    Text("Password")
                        .foregroundColor(.white)
                        .font(.headline)

                    HStack {
                        if isPasswordVisible {
                            TextField("Enter your password", text: $password)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Enter your password", text: $password)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                        }

                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()

                NavigationLink(
                    destination: ChatScreenView(viewModel: ChatViewModel(user: User(name: email)))
                        .navigationBarBackButtonHidden(true),
                    isActive: $isLogin
                ) {
                    Button(action: {
                        authService.loginUser(login: email, password: password) { result in
                            switch result {
                            case .success(let message):
                                loginStatus = message
                                isLogin = true
                            case .failure(let error):
                                loginStatus = handleAuthError(error)
                            }
                        }
                    }) {
                        Text("Sign in")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                    .padding(.top, 30)
                }

                Text("or")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                NavigationLink(
                    destination: RegistrationView(settings: settings)
                        .navigationBarBackButtonHidden(true),
                    isActive: $isRegister
                ) {
                    Button(
                        action: {
                            isRegister = true
                        }
                    ) {
                        Text("Sign up")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                }

                Text(loginStatus)
                    .foregroundColor(.white)
                    .padding(.top, 20)
            }
            .padding()
        }
    }

    // Handle Auth Errors
    func handleAuthError(_ error: AuthError) -> String {
        switch error {
        case .invalidURL:
            return "Invalid URL."
        case .requestFailed(let errorMessage):
            return "Request failed: \(errorMessage)"
        case .invalidData:
            return "Invalid data received."
        case .userAlreadyExists:
            return "User already exists."
        case .invalidCredentials:
            return "Invalid login or password."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(settings: DebugSettings())
            .previewDevice("iPhone 11 Pro")
    }
}
