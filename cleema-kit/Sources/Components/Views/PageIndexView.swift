//
//  Created by Kumpels and Friends on 30.06.22.
//  Copyright © 2022 Kumpels and Friends. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI

public struct PageIndexView<Page: Identifiable & Equatable>: View {
    var content: [Page]
    @Binding var selectedPage: Page
    var icon: (Page) -> Image
    var spacing: CGFloat = 2

    public init(content: [Page], selectedPage: Binding<Page>, spacing: CGFloat = 2, icon: @escaping (Page) -> Image) {
        self.content = content
        self.icon = icon
        self.spacing = spacing
        _selectedPage = selectedPage
    }

    public var body: some View {
        HStack {
            Spacer()

            ForEach(content) { page in
                icon(page)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(page == selectedPage ? .accentColor : .accentColor.opacity(0.3))
                    .padding(.horizontal, spacing / 2)
                #if !os(tvOS)
                    .onTapGesture {
                        withAnimation {
                            selectedPage = page
                        }
                    }
                #endif
            }

            Spacer()
        }
    }
}

public extension PageIndexView where Page: CaseIterable {
    init(selectedPage: Binding<Page>, icon: @escaping (Page) -> Image) {
        content = Array(Page.allCases)
        _selectedPage = selectedPage
        self.icon = icon
    }
}

struct PageView_Previews: PreviewProvider {
    enum Page: Int, CaseIterable, Equatable, Identifiable {
        case one
        case two
        case three

        var id: Int { rawValue }
    }

    struct Preview: View {
        @State private var selectedPage: Page = .one

        var body: some View {
            PageIndexView(selectedPage: $selectedPage) { _ in
                Image(systemName: "hammer")
            }
        }
    }

    static var previews: some View {
        Preview()
            .frame(height: 30)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
