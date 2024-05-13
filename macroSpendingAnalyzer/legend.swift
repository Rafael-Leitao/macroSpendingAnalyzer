import SwiftUI

struct Legend: View {
    var categories: [String]
    var colors: [String: Color]

    var body: some View {
        HStack {
            ForEach(categories, id: \.self) { category in
                HStack {
                    Circle()
                        .fill(colors[category] ?? .black)
                        .frame(width: 10, height: 10)
                    Text(category)
                        .font(.caption)
                }
            }
        }
    }
}
