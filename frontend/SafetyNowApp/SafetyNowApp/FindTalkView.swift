import SwiftUI

struct FindTalkView: View {
    let categories: [(key: String, icon: String)] = [
        ("hazards", "pencil"),
        ("industry", "pencil"),
        ("send_talk", "calendar"),
        ("translate", "globe"),
        ("tools", "lightbulb"),
        ("calendar", "doc.on.doc")
    ]

    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Tab
    let onHazardTap: () -> Void
    let onIndustryTap: () -> Void
    @State private var showUpgrade = false
    @State private var showCalendar = false
    @State private var showTranslate = false
    @State private var showShareTalkInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(LocalizationManager.shared.localizedString(for: "findtalk.explore"))
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(categories, id: \ .key) { category in
                    let title = LocalizationManager.shared.localizedString(for: "findtalk.\(category.key)")
                    let desc = LocalizationManager.shared.localizedString(for: "findtalk.\(category.key)_desc")
                    if category.key == "hazards" {
                        Button(action: onHazardTap) {
                            tileView(title: title, desc: desc, icon: category.icon)
                        }
                    } else if category.key == "industry" {
                        Button(action: onIndustryTap) {
                            tileView(title: title, desc: desc, icon: category.icon)
                        }
                    } else if category.key == "calendar" {
                        Button(action: { showCalendar = true }) {
                            tileView(title: title, desc: desc, icon: category.icon)
                        }
                    } else if category.key == "translate" {
                        Button(action: { showTranslate = true }) {
                            tileView(title: title, desc: desc, icon: category.icon)
                        }
                    } else if category.key == "send_talk" {
                        Button(action: { showShareTalkInfo = true }) {
                            tileView(title: title, desc: desc, icon: category.icon)
                        }
                    } else {
                        tileView(title: title, desc: desc, icon: category.icon)
                    }
                }
            }
            Spacer()
            NavigationLink(destination: UpgradePlanView(), isActive: $showUpgrade) { EmptyView() }
            NavigationLink(destination: CalendarView(), isActive: $showCalendar) { EmptyView() }
            NavigationLink(destination: LanguageSelectionView(), isActive: $showTranslate) { EmptyView() }
            NavigationLink(destination: ShareTalkInfoView(), isActive: $showShareTalkInfo) { EmptyView() }
            HStack {
                Spacer()
                Button(action: { showUpgrade = true }) {
                    Text("ACCESS MORE")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .padding(.trailing, 32)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func tileView(title: String, desc: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.black)
                Spacer()
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
            Text(desc)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}
