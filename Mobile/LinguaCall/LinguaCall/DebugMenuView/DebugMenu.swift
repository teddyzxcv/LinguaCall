import SwiftUI

class DebugSettings: ObservableObject {
    @Published var baseURL: String = ""

    init() {
        loadBaseURL()
    }

    // Save the base URL to UserDefaults
    func saveBaseURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: "baseURL")
        baseURL = url
    }

    // Load the base URL from UserDefaults
    func loadBaseURL() {
        if let savedURL = UserDefaults.standard.string(forKey: "baseURL") {
            baseURL = savedURL
        } else {
            baseURL = "http://msgcgo40kcg8gggsswkwks88.89.169.150.238.sslip.io/api" // Default base URL
        }
    }
}

struct DebugMenuView: View {
    @ObservedObject var settings: DebugSettings
    @State private var newBaseURL: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Debug Menu")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Current Base URL:")
            Text(settings.baseURL)
                .foregroundColor(.blue)
                .font(.headline)

            TextField("Enter new Base URL", text: $newBaseURL)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                .autocapitalization(.none)
                .keyboardType(.URL)

            Button(action: {
                settings.saveBaseURL(newBaseURL)
            }) {
                Text("Save")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            // Prepopulate the text field with the current base URL when the view appears
            newBaseURL = settings.baseURL
        }
    }
}

struct DebugMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DebugMenuView(
            settings: DebugSettings()
        )
            .previewDevice("iPhone 11 Pro")
    }
}
