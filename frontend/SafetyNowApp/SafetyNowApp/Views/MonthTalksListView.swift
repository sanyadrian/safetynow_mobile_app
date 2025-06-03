import SwiftUI

struct MonthTalksListView: View {
    let month: String
    let talks: [TalkModel]
    
    var body: some View {
        List {
            ForEach(talks) { talk in
                NavigationLink(destination: TalkDetailView(talk: talk)) {
                    Text(talk.title)
                }
            }
        }
        .navigationTitle(month)
    }
}

#Preview {
    MonthTalksListView(month: "January", talks: [])
} 