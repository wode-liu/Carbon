#if canImport(SwiftUI) && canImport(Combine)

import SwiftUI

@available(iOS 13.0, *)
public extension Component where Self: View {
    /// Declares the content and behavior of this view.
    var body: some View {
        ComponentView(self)
    }
}

@available(iOS 13.0, *)
private struct ComponentView<C: Component>: View {
    var component: C
    var proxy = ComponentViewProxy()

    init(_ component: C) {
        self.component = component
    }

    var body: some View {
        ComponentRepresenting(component: component, proxy: proxy)
            .onAppear { self.proxy.uiView?.contentWillDisplay() }
            .onDisappear { self.proxy.uiView?.contentDidEndDisplay() }
    }
}

private struct ComponentRepresenting<C: Component>: UIViewRepresentable {
    var component: C
    var proxy: ComponentViewProxy

    func makeUIView(context: Context) -> UIComponentView {
        UIComponentView()
    }

    func updateUIView(_ uiView: UIComponentView, context: Context) {
        uiView.render(component: AnyComponent(component))
        proxy.uiView = uiView
    }
}

private final class UIComponentView: UIView, ComponentRenderable {
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
    }

    override var intrinsicContentSize: CGSize {
        guard let referenceSize = renderedComponent?.referenceSize(in: bounds) else {
            return super.intrinsicContentSize
        }
        return referenceSize
    }
}

private final class ComponentViewProxy {
    var uiView: UIComponentView?
}

#endif
