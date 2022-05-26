//
//  CustomContextMenu.swift
//  PDFEDITOR
//
//  Created by Mark Khmelnitskii on 09.03.2022.
//

import SwiftUI

public extension View {
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        return conditional ? AnyView(content(self)) : AnyView(self)
    }
    
  }

extension View {
    public func previewContextMenu<Preview: View>(
        preview: Preview,
        preferredContentSize: Binding<CGSize?>,
        isActive: Binding<Bool>,
        presentAsSheet: Bool = false,
        actions: [UIAction] = []
    ) -> some View {
        modifier(
            PreviewContextViewModifier<Preview, EmptyView>(
                isActive: isActive,
                preview: preview,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }
}


public struct PreviewContextViewModifier<Preview: View, Destination: View>: ViewModifier {
    @Binding var isActive: Bool
    private let previewContent: Preview?
    private let destination: Destination?
    @Binding var preferredContentSize: CGSize?
    private let actions: [UIAction]
    private let presentAsSheet: Bool
    
    /// destination and preview must be at least one exist
    init(isActive: Binding<Bool>,
         destination: Destination? = nil,
         preview: Preview? = nil,
         preferredContentSize: Binding<CGSize?>,
         presentAsSheet: Bool = false,
         actions: [UIAction] = []) {
        _isActive = isActive
        self.destination = destination
        self.previewContent = preview
        _preferredContentSize = preferredContentSize
        self.presentAsSheet = presentAsSheet
        self.actions = actions
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        ZStack {
            if !presentAsSheet, destination != nil {
                NavigationLink(
                    destination: destination,
                    isActive: $isActive,
                    label: { EmptyView() }
                )
                .hidden()
                .frame(width: 0, height: 0)
            }
            content
                .overlay(
                    PreviewContextView(
                        content: preview,
                        preferredContentSize: $preferredContentSize,
                        actions: actions,
                        isPreviewOnly: destination == nil,
                        isActive: $isActive
                    )
                    .opacity(0.05)
                    .if(presentAsSheet) {
                        $0.sheet(isPresented: $isActive) {
                            destination
                        }
                    }
                )
        }
    }
    
    @ViewBuilder
    private var preview: some View {
        if let preview = previewContent {
            preview
        } else {
            destination
        }
    }
}

public struct PreviewContextView<Content: View>: UIViewRepresentable {
    let content: Content?
    @Binding var preferredContentSize: CGSize?
    let actions: [UIAction]
    let isPreviewOnly: Bool
    
    @Binding var isActive: Bool
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.addInteraction(UIContextMenuInteraction(delegate: context.coordinator))
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        guard let size = preferredContentSize else { return }
        uiView.sizeThatFits(size)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension PreviewContextView {
    public class Coordinator: NSObject, UIContextMenuInteractionDelegate {

        private let preview: PreviewContextView<Content>
        init(_ content: PreviewContextView<Content>) {
            self.preview = content
        }
        
        public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            if preview.isActive {
                return UIContextMenuConfiguration(
                    identifier: nil,
                    previewProvider: {
                        let hostingController = UIHostingController(rootView: self.preview.content)
                        
                        if let preferredContentSize = self.preview.preferredContentSize {
                            hostingController.preferredContentSize = preferredContentSize
                        } else {
//                            let width = CGFloat((UIScreen.main.bounds.width - 45) / 3)
//                            hostingController.preferredContentSize = CGSize(width: width, height: width)
                        }
                        
                        return hostingController
                    }, actionProvider: { _ in
                        UIMenu(title: "", children: self.preview.actions)
                    }
                )
            } else {
                return nil
            }
        }
        public func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
            animator: UIContextMenuInteractionCommitAnimating
        ) {
            guard !preview.isPreviewOnly else { return }
        }
    }
}
