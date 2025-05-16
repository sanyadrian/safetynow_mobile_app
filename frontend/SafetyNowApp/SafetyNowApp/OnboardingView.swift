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
        OnboardingSlide(imageName: "onboarding1", title: "Keep Workplace Safety Top of Mind \n", description: "Make sure your OHS message is compliant & engaging so that it's effective too."),
        OnboardingSlide(imageName: "onboarding2", title: "Reduce Accidents & Incidents in Your Workplace", description: "The right safety message at the right time makes all the difference.")
    ]

    var body: some View {
        TabView(selection: $currentIndex) {
            // First 2 slides
            ForEach(slides.indices, id: \.self) { index in
                OnboardingSlideView(slide: slides[index], currentIndex: currentIndex, totalSlides: slides.count + 1)
                    .tag(index)
            }

            // Third slide is actual login view
            LoginView(currentIndex: $currentIndex)
                .tag(slides.count)
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea(.all)
    }
}

struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    let currentIndex: Int
    let totalSlides: Int

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.gray
                Group {
                    if let uiImage = UIImage(named: slide.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .padding(40)
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.5)

            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    ForEach(0..<totalSlides, id: \.self) { dot in
                        Circle()
                            .fill(Color.blue.opacity(dot == currentIndex ? 1 : 0.4))
                            .frame(width: 8, height: 8)
                    }
                }

                Text(slide.title)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(slide.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .ignoresSafeArea(edges: .top)
    }
}
