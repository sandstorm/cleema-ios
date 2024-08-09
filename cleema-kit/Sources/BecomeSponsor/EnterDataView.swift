//
//  Created by Kumpels and Friends on 12.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

//
//  SwiftUIView.swift
//
//
//  Created by Gunnar Herzog on 09.01.23.
//
import Components
import ComposableArchitecture
import SwiftUI

struct EnterDataView: View {
    enum Field {
        case firstName
        case lastName
        case street
        case zip
        case location
        case iban
        case bic
    }

    let store: StoreOf<BecomeSponsor>
    @FocusState private var focusedField: Field?
    @State private var showsIBANHint = false

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GroupBox {
                VStack(alignment: .leading) {
                    Text("Daten eingeben")
                        .font(.montserratBold(style: .title, size: 16))

                    VStack(spacing: 12) {
                        VStack {
                            TextField("Vorname", text: viewStore.binding(\.$sponsorData.firstName))
                                .focused($focusedField, equals: .firstName)
                            Divider().background(Color.defaultText)
                        }

                        VStack {
                            TextField("Nachname", text: viewStore.binding(\.$sponsorData.lastName))
                                .focused($focusedField, equals: .lastName)

                            Divider().background(Color.defaultText)
                        }

                        VStack {
                            TextField(
                                "Straße / Hausnummer",
                                text: viewStore.binding(\.$sponsorData.streetAndHouseNumber)
                            )
                            .focused($focusedField, equals: .street)
                            Divider().background(Color.defaultText)
                        }

                        VStack {
                            HStack {
                                VStack {
                                    TextField("PLZ", text: viewStore.binding(\.$sponsorData.postalCode))
                                        .focused($focusedField, equals: .zip)
                                    Divider().background(Color.defaultText)
                                }
                                VStack {
                                    TextField("Ort", text: viewStore.binding(\.$sponsorData.city))
                                        .focused($focusedField, equals: .location)
                                    Divider().background(Color.defaultText)
                                }
                            }
                        }

                        VStack {
                            HStack {
                                TextField("IBAN", text: viewStore.binding(\.$sponsorData.iban))
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .iban)
                                    .frame(maxHeight: .infinity)
                                if !viewStore.sponsorData.iban.isEmpty, !viewStore.sponsorData.iban.isValidIBAN {
                                    Button(action: { showsIBANHint = true }) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .alwaysPopover(isPresented: $showsIBANHint) {
                                        Text("Die IBAN ist nicht korrekt.")
                                            .fixedSize(horizontal: false, vertical: true)
                                            .font(.montserrat(style: .caption, size: 12))
                                            .foregroundColor(.defaultText)
                                            .frame(maxWidth: 240, alignment: .leading)
                                            .padding()
                                    }
                                    .frame(maxHeight: .infinity)
                                }
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            Divider().background(Color.defaultText)
                        }

                        TextField("BIC (optional)", text: viewStore.binding(\.$sponsorData.bic))
                            .focused($focusedField, equals: .bic)
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button {
                                focusedField = nil
                            } label: {
                                Text("Fertig")
                                    .font(.montserratBold(style: .title, size: 16))
                                    .foregroundColor(.action)
                            }
                        }
                    }

                    Text(
                        "Hiermit bestätige ich, dass alle von mir gemachten Angaben zutreffend und richtig sind."
                    )
                    .font(.montserrat(style: .caption, size: 12))

                    Link(destination: URL(string: "https://cleema.app/app/datenschutz/")!, label: {
                        Text("Datenschutzinformationen")
                            .foregroundColor(.action)
                            .underline()
                    })
                    .font(.montserrat(style: .caption, size: 12))
                    .padding(.vertical, 8)

                    Button("Weiter ...") {
                        viewStore.send(.nextButtonTapped, animation: .default)
                    }
                    .buttonStyle(.action(maxWidth: .infinity))
                    .disabled(viewStore.nextButtonIsDisabled)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .leading))
            }
        }
    }
}

struct EnterDataView_Previews: PreviewProvider {
    static var previews: some View {
        EnterDataView(store: .init(initialState: .init(), reducer: BecomeSponsor()))
            .groupBoxStyle(.plain(padding: 0))
    }
}
