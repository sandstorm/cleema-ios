//
//  Created by Kumpels and Friends on 20.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import MarkdownUI
import Models
import SwiftUI

struct SelectPackageView: View {
    let store: StoreOf<BecomeSponsor>

    @State var packageDataHeight: Double = 10

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Paket auswählen:")
                        .font(.montserratBold(style: .title, size: 16))
                        .padding(.horizontal, 20)

                    TabView(selection: viewStore.binding(\.$selectedPackage)) {
                        ForEach(SponsorPackage.allCases) { package in
                            PackageDataView(package: package)
                                .fixedSize(horizontal: false, vertical: true)
                                .reportSize(SelectPackageView.self) { size in
                                    packageDataHeight = max(packageDataHeight, size.height)
                                }
                                .padding(.horizontal)
                                .tag(package)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: packageDataHeight, alignment: .top)

                    PageIndexView(selectedPage: viewStore.binding(\.$selectedPackage))
                        .accentColor(.accent)
                        .frame(height: 8)

                    ScrollView {
                        Markdown(viewStore.selectedPackage.features)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .font(.montserrat(style: .caption, size: 12))
                            .padding(.horizontal, 20)
                    }

                    Button("Weiter ...") {
                        viewStore.send(.nextButtonTapped, animation: .default)
                    }
                    .buttonStyle(.action(maxWidth: .infinity))
                    .disabled(viewStore.nextButtonIsDisabled)
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
    }
}

extension PageIndexView where Page == SponsorPackage {
    init(selectedPage: Binding<Page>) {
        self.init(selectedPage: selectedPage) { _ in
            Image(systemName: "circle.fill")
        }
    }
}

struct SelectPackageView_Previews: PreviewProvider {
    static var previews: some View {
        SelectPackageView(store: .init(initialState: .init(), reducer: BecomeSponsor()))
            .groupBoxStyle(.plain(padding: 0))
    }
}
