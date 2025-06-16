import SwiftUI

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

struct OnboardingView: View {
    @State private var currentIndex = 0

    private let slides: [OnboardingSlide] = [
        OnboardingSlide(imageName: "OHS-box-graphics-01-landscape", title: "Keep Workplace Safety Top of Mind \n", description: "Make sure your OHS message is compliant & engaging so that it's effective too."),
        OnboardingSlide(imageName: "OHS-box-graphics-13-landscape", title: "Reduce Accidents & Incidents in Your Workplace", description: "The right safety message at the right time makes all the difference.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentIndex) {
                ForEach(slides.indices, id: \ .self) { index in
                    OnboardingSlideView(slide: slides[index])
                        .tag(index)
                }
                LoginView(currentIndex: $currentIndex)
                    .tag(slides.count)
            }
            .tabViewStyle(PageTabViewStyle())
            .ignoresSafeArea(.all, edges: .top)

            // Dot indicators (only for slides, not login)
            if currentIndex < slides.count {
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \ .self) { dot in
                        Circle()
                            .fill(Color.blue.opacity(dot == currentIndex ? 1 : 0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}

struct OnboardingSlideView: View {
    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: 0) {
            if let uiImage = UIImage(named: slide.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .padding(40)
            }

            Text(slide.title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top, 16)

            Text(slide.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding()
        .ignoresSafeArea(edges: .top)
    }
}
