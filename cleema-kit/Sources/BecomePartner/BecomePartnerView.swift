//
//  Created by Kumpels and Friends on 27.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Components
import ComposableArchitecture
import MarkdownUI
import SwiftUI

public struct BecomePartnerView: View {
    let store: StoreOf<BecomePartner>

    @State var packageDataHeight: Double = 10

    public init(store: StoreOf<BecomePartner>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Paket auswählen:")
                            .font(.montserratBold(style: .title, size: 16))
                            .padding(.horizontal, 20)

                        TabView(selection: viewStore.binding(\.$selectedPackage)) {
                            ForEach(PartnerPackage.allCases) { package in
                                PackageDataView(package: package)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .reportSize(BecomePartnerView.self) { size in
                                        packageDataHeight = max(packageDataHeight, size.height)
                                    }
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
                        }

                        Spacer()

                        Button("Angebot erhalten") {
                            viewStore.send(.openMailTapped)
                        }
                        .buttonStyle(.action(maxWidth: .infinity))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .padding(20)
                .background(Color.accent)
                .alert(store.scope(state: \.alertState), dismiss: BecomePartner.Action.dismissAlert)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            viewStore.send(.dismissSheet)
                        }
                    }
                }
            }
        }
    }
}

extension PageIndexView where Page == PartnerPackage {
    init(selectedPage: Binding<Page>) {
        self.init(selectedPage: selectedPage) { _ in
            Image(systemName: "circle.fill")
        }
    }
}

struct BecomePartnerView_Previews: PreviewProvider {
    static var previews: some View {
        BecomePartnerView(store: .init(initialState: .init(), reducer: BecomePartner()))
            .padding()
            .background(Color.accent)
            .cleemaStyle()
    }
}
