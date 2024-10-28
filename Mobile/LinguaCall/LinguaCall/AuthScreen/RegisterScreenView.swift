import SwiftUI

struct RegistrationView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var registrationStatus: String = ""
    @State private var isRegistered = false
    @State private var isLogin = false
    @ObservedObject var settings: DebugSettings

    private var authService: AuthService

    init(settings: DebugSettings) {
        self.settings = settings
        self.authService = AuthService(settings: settings)
    }

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Registration")
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
                .ignoresSafeArea(.keyboard)

                NavigationLink(
                    destination: ChatListView(context: CoreDataStack.shared.context)
                        .navigationBarBackButtonHidden(true),
                    isActive: $isRegistered
                ) {
                    Button(action: {
                        authService.registerUser(login: email, password: password) { result in
                            switch result {
                            case .success(let user):
                              UserInfo.login = email
                              UserInfo.password = password
                                email = user.login
                                registrationStatus = "Registration successful!"
                                isRegistered = true
                            case .failure(let error):
                                registrationStatus = handleAuthError(error)
                            }
                        }
                    }) {
                        Text("Sign up")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                    .padding(.top, 30)
                }

                Text(registrationStatus)
                    .foregroundColor(.white)
                    .padding(.top, 20)
            }
            .padding()
        }.ignoresSafeArea(.all)
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
        case .decodingError:
          return "Error with decoding"
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(settings: DebugSettings())
            .previewDevice("iPhone 11 Pro")
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let userInfo = notification.userInfo,
                       let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                        self.keyboardHeight = keyboardFrame.height
                    }
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    self.keyboardHeight = 0
                }
            }
    }
}

