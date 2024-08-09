//
//  Created by Kumpels and Friends on 05.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import SwiftUI

public extension View {
    func alwaysPopover<Content>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View
        where Content: View
    {
        modifier(AlwaysPopoverModifier(isPresented: isPresented, contentBlock: content))
    }
}

struct AlwaysPopoverModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    let isPresented: Binding<Bool>
    let contentBlock: () -> PopoverContent

    private class Store: ObservableObject {
        @Published var anchorView = UIView()
    }

    @StateObject private var store = Store()

    func body(content: Content) -> some View {
        if isPresented.wrappedValue {
            presentPopover()
        }

        return content
            .background(InternalAnchorView(uiView: store.anchorView))
    }

    private func presentPopover() {
        let contentController = ContentViewController(rootView: contentBlock(), isPresented: isPresented)
        contentController.modalPresentationStyle = .popover

        let view = store.anchorView
        guard let popover = contentController.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = view.bounds
        popover.delegate = contentController

        guard let sourceVC = view.closestVC() else { return }
        if sourceVC.presentedViewController == nil {
//            presentedVC.dismiss(animated: true) {
//                sourceVC.present(contentController, animated: true)
//            }
//        } else {
            sourceVC.present(contentController, animated: true)
        }
    }

    private struct InternalAnchorView: UIViewRepresentable {
        typealias UIViewType = UIView
        let uiView: UIView

        func makeUIView(context _: Self.Context) -> Self.UIViewType {
            uiView
        }

        func updateUIView(_: Self.UIViewType, context _: Self.Context) {}
    }
}

class ContentViewController<V>: UIHostingController<V>, UIPopoverPresentationControllerDelegate where V: View {
    var isPresented: Binding<Bool>

    init(rootView: V, isPresented: Binding<Bool>) {
        self.isPresented = isPresented
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    @MainActor @objc dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let size = sizeThatFits(in: UIView.layoutFittingExpandedSize)
        preferredContentSize = size
    }

    func adaptivePresentationStyle(
        for _: UIPresentationController,
        traitCollection _: UITraitCollection
    ) -> UIModalPresentationStyle {
        .none
    }

    func presentationControllerDidDismiss(_: UIPresentationController) {
        isPresented.wrappedValue = false
    }
}

private struct InternalAnchorView: UIViewRepresentable {
    typealias UIViewType = UIView
    let uiView: UIView

    func makeUIView(context _: Self.Context) -> Self.UIViewType {
        uiView
    }

    func updateUIView(_: Self.UIViewType, context _: Self.Context) {}
}

extension UIView {
    func closestVC() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}
