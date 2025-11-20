import SwiftUI

struct TestView: View {
    var body: some View {
        ZStack {
            Color.orange
                .ignoresSafeArea()

            VStack {
                Text("CipherForge")
                    .font(.largeTitle)
                    .foregroundColor(.black)

                Text("Test View - App is Working!")
                    .foregroundColor(.black)
            }
        }
    }
}
