//
//  Created by Kumpels and Friends on 19.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import ComposableArchitecture
import ConfettiSwiftUI
import MarkdownUI
import Styling
import SwiftUI

struct ConfirmView: View {
    let store: StoreOf<BecomeSponsor>

    @State private var confettiCounter: Int = 0

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Überprüfen und Senden")
                        .font(.montserratBold(style: .title, size: 16))
                        .padding(.horizontal, 20)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Mein gewähltes Paket:")
                                    .bold()
                                Text("cleema \(viewStore.selectedPackage.title)")

                                Button("Ändern ...") {
                                    viewStore.send(.changePackageTapped, animation: .default)
                                }
                                .buttonStyle(.plain)
                                .font(.montserratBold(style: .caption, size: 12))
                                .foregroundColor(.action)
                                .padding(.top, 2)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Monatlicher Preis:")
                                    .bold()
                                Text("\(viewStore.selectedPackage.priceInEuro),- Euro")
                                    .foregroundColor(.answer)
                                    .font(.body.weight(.heavy))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Meine Daten:")
                                    .bold()
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(viewStore.sponsorData.fullName)
                                    Text(viewStore.sponsorData.address)
                                    Text("IBAN: \(viewStore.sponsorData.iban)")
                                    if !viewStore.sponsorData.bic.trimmingCharacters(in: .whitespacesAndNewlines)
                                        .isEmpty
                                    {
                                        Text("BIC: \(viewStore.sponsorData.bic)")
                                    }
                                    Link(destination: URL(string: "https://cleema.app/app/datenschutz/")!, label: {
                                        Text("Datenschutzinformationen")
                                            .foregroundColor(.action)
                                            .underline()
                                    })
                                    .font(.montserrat(style: .caption, size: 12))
                                }
                                .font(.montserrat(style: .caption, size: 14))
                            }
                            Button("Ändern ...") {
                                viewStore.send(.changeSponsorDataTapped, animation: .default)
                            }
                            .buttonStyle(.plain)
                            .font(.montserratBold(style: .caption, size: 12))
                            .foregroundColor(.action)
                            .padding(.top, 2)

                            Toggle(isOn: viewStore.binding(\.$isSEPAConfirmed)) {
                                VStack(alignment: .leading) {
                                    Text("SEPA-Lastschriftmandat für wiederkehrende Zahlungen")
                                        .bold()

                                    Text(
                                        "Ich ermächtige die cleema GmbH Zahlungen von meinem Konto mittels Lastschrift einzuziehen. Zugleich weise ich mein Kreditinstitut an, die von der cleema GmbH auf mein Konto gezogenen Lastschriften einzulösen.\n\nHinweis: Dieses Lastschriftmandat dient nur für den Einzug von Lastschriften auf Konten der cleema GmbH. Ich kann innerhalb von acht Wochen, beginnend mit dem Belastungsdatum, die Erstattung des belasteten Betrages verlangen. Es gelten dabei die mit meinem Kreditinstitut vereinbarten Bedingungen."
                                    )
                                    .font(.montserrat(style: .caption, size: 14))
                                }
                            }
                            .toggleStyle(CheckboxStyle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Enthaltene Leistungen:")
                                    .bold()
                                Markdown(viewStore.selectedPackage.features)
                                    .font(.montserrat(style: .caption, size: 12))
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Button {
                        confettiCounter += 1
                        viewStore.send(.nextButtonTapped, animation: .default)
                    } label: {
                        if viewStore.nextButtonIsDisabled, viewStore.isSending {
                            ProgressView().tint(.white)
                        } else {
                            Text("Jetzt Sponsor werden")
                        }
                    }
                    .buttonStyle(.action(maxWidth: .infinity))
                    .disabled(viewStore.nextButtonIsDisabled)
                    .confettiCannon(
                        counter: $confettiCounter,
                        num: 50,
                        confettis: [.shape(.circle)],
                        colors: [.action, .answer, .defaultText, .selfChallenge],
                        openingAngle: Angle(degrees: 0),
                        closingAngle: Angle(degrees: 360),
                        radius: 200
                    )
                    .padding(.horizontal, 20)
                }
                .font(.montserrat(style: .body, size: 16))
                .foregroundColor(.defaultText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 20)
                .alert(store.scope(state: \.alertState), dismiss: BecomeSponsor.Action.dismissAlert)
            }
        }
    }
}

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .imageScale(.large)
                .font(.system(.body).bold())
                .foregroundColor(.defaultText)
            configuration.label
        }
        .onTapGesture { configuration.isOn.toggle() }
    }
}

struct ConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmView(store: .init(initialState: .init(), reducer: BecomeSponsor()))
            .groupBoxStyle(.plain(padding: 0))
    }
}
