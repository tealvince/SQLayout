//
//  SQLayoutView.swift
//  SQLayout
//
//  Created by Vince Lee on 2/6/23.
//  (c)2023 All Rights Reserved
//

import UIKit

public typealias SQLayoutViewArrangedItemsBuilder = (SQLayoutView) -> [any SQLayoutItem]
public typealias SQLayoutViewInsetsCalculator = (SQLayoutView) -> UIEdgeInsets
public typealias SQLayoutViewCallback = (SQLayoutView) -> Void

///
/// A container view that supports sequential layout on subviews
///
/// ````
/// ┌────────────────────────────┐
/// │  ┌──────────────────────┐  │
/// │  │                      │ ──────── Layout Insets
/// │  │                      │  │
/// │  │ Layout items go here │  │──── Layout Bounds
/// │  │                      │  │
/// │  │                      │  │
/// │  └──────────────────────┘  │
/// └────────────────────────────┘
///
@objcMembers
public class SQLayoutView: UIView {

    // MARK: - Public properties
    public var layoutInsetsCalculator: SQLayoutViewInsetsCalculator? = nil
    public var layoutInsets: UIEdgeInsets { get { layoutInsetsCalculator?(self) ?? .zero } set { layoutInsetsCalculator = {_ in newValue } } }

    // Set to true to disable handling of taps in this view while still allowing
    // userInteractionEnabled, which may still be desirable for keyboard handling, etc
    public var isPointNeverInside = false

    /// Convenience property to add additional behavior after view is laid out, such as updating coordinating views
    public var didLayoutSubviewsCallback: SQLayoutViewCallback?

    /// Convenience properties to define items using swift resultBuilder or callback
    public var arrangedItemsBuilder: SQLayoutViewArrangedItemsBuilder? { didSet { buildArrangedItems() }}

    /// Default calculators for arranged items (if not specifically set by item decorator)
    public var defaultSizeCalculator: SQSizeCalculator?
    public var defaultFrameCalculator: SQFrameCalculator?
    public var defaultSizingFrameCalculator: SQFrameCalculator?
    public var defaultSpacingCalculator: SQSpacingCalculator?
    public var defaultPaddingCalculator: SQPaddingCalculator?
    public var defaultLayoutOptionsCalculator: SQLayoutOptionsCalculator?
    public var defaultLayoutObserver: SQLayoutObserver?

    // MARK: - Private properties
    private let container = SQLayoutContainer()

    // MARK: - Initializers
    public required init(layoutInsetsCalculator: @escaping SQLayoutViewInsetsCalculator) {
        self.layoutInsetsCalculator = layoutInsetsCalculator
        super.init(frame: .zero)
    }

    public convenience init(layoutInsets: UIEdgeInsets = .zero) {
        self.init(layoutInsetsCalculator: { _ in layoutInsets })
    }

    // Set items with an inline result builder
    public convenience init(@SQLayoutItemsBuilder resultBuilder: @escaping () -> [any SQLayoutItem]) {

        self.init(layoutInsetsCalculator: { _ in .zero })
        self.arrangedItemsBuilder = { _ in resultBuilder() }
        self.buildArrangedItems()
    }

    public init() {
        self.layoutInsetsCalculator = { _ in .zero }
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    ///
    /// Convenience factory method for creating an auto-sizing layoutView added as a subview to a parent view
    ///
    @discardableResult
    public static func addAutosizedView(to view: UIView, layoutGuide: UILayoutGuide? = nil, layoutInsets: UIEdgeInsets = .zero, ignoreTopAnchor: Bool = false, ignoreBottomAnchor: Bool = false) -> Self {
        let contentView = Self.init(layoutInsetsCalculator:{ _ in layoutInsets })

        return contentView.addAutosized(to: view, layoutGuide: layoutGuide, layoutInsets: layoutInsets, ignoreTopAnchor: ignoreTopAnchor, ignoreBottomAnchor: ignoreBottomAnchor)
    }

    public func addAutosized(to view: UIView, layoutGuide: UILayoutGuide? = nil, layoutInsets: UIEdgeInsets = .zero, ignoreTopAnchor: Bool = false, ignoreBottomAnchor: Bool = false) -> Self {

        // Add content view as subview
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false

        // Set constraints
        if let layoutGuide = layoutGuide {
            if !ignoreTopAnchor {
                self.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
            }
            if !ignoreBottomAnchor {
                self.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
            }
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
            ])
        } else {
            if !ignoreTopAnchor {
                self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            }
            if !ignoreBottomAnchor {
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        return self
    }

    ///
    /// Update arranged items with existing builder or provider
    ///
    public func buildArrangedItems() {
        if let builder = arrangedItemsBuilder {
            setArrangedItems(builder(self))
        }
    }

    ///
    /// Add an item (typically a raw or decorated UIView), as an arranged item.
    /// If the item represents a view then add it as a subview as well.
    /// Returns self to support chaining.
    ///
    public func addArrangedItem(_ item: any SQLayoutItem) {

        // Add item to container
        container.arrangedItems.append(item)

        // Add as subview if item represents a view
        if let subview = item.sq_rootItem as? UIView {
            self.addSubview(subview)
        }
        setNeedsLayout()
    }

    ///
    /// Remove an arranged item.  If the item represents a view, remove it as subview.
    ///
    public func removeArrangedItem(_ item: any SQLayoutItem) {

        if let index = container.arrangedItems.firstIndex(where: { $0.sq_rootItem === item.sq_rootItem }) {
            // Remove from container
            container.arrangedItems.remove(at: index)

            // Unlink subview, if appropriate
            if let subview = item.sq_rootItem as? UIView, subview.superview === self {
                subview.removeFromSuperview()
            }
            setNeedsLayout()
        }
    }

    ///
    /// Remove all arranged items
    ///
    public func removeAllArrangedItems() {
        for item in container.arrangedItems {
            removeArrangedItem(item)
        }
    }

    ///
    /// Set arranged subview items
    ///
    public func setArrangedItems(_ items: [SQLayoutItem]) {

        // Unlink any subviews we are no longer arranging
        for item in container.arrangedItems {
            if let subview = item.sq_rootItem as? UIView, subview.superview === self {
                subview.removeFromSuperview()
            }
        }

        // Update container
        container.arrangedItems = items

        // Add new subviews
        for item in items {
            if let subview = item.sq_rootItem as? UIView {
                self.addSubview(subview)
            }
        }
        setNeedsLayout()
    }

    // MARK: - Public (Chaining support)

    @discardableResult
    public func containingArrangedItem(_ item: any SQLayoutItem) -> Self {
        addArrangedItem(item)
        return self
    }

    @discardableResult
    public func containingArrangedItemsBuilder(_ builder: SQLayoutViewArrangedItemsBuilder?) -> Self {
        arrangedItemsBuilder = builder
        return self
    }

    @discardableResult
    public func containingArrangedItemsResultBuilder( @SQLayoutItemsBuilder _ resultBuilder: @escaping () -> [any SQLayoutItem]) -> Self {
        arrangedItemsBuilder = { _ in resultBuilder() }
        return self
    }

    @discardableResult
    public func containingLayoutInsetsCalculator(_ c: @escaping SQLayoutViewInsetsCalculator) -> Self {
        layoutInsetsCalculator = c
        return self
    }

    @discardableResult
    public func containingLayoutInsets(_ insets: UIEdgeInsets) -> Self {
        return containingLayoutInsetsCalculator({ _ in insets })
    }

    @discardableResult
    public func containingPointNeverInside(_ neverInside: Bool) -> Self {
        isPointNeverInside = neverInside
        return self
    }

    ///
    /// Convenience method for inserting customization code for
    /// a layout view created in a chain of ".containingXXX" methods
    ///
    @discardableResult
    public func containingCustomization(_ customization: (SQLayoutView) -> Void) -> Self {
        customization(self)
        return self
    }

    // MARK: - Public (Decorator Defaults)

    ///
    /// These functions are equivalent to the withSQxxxx() decorator functions applied to individual items,
    /// but allow one to specify a default value for any arranged item that doesn't have a custom value.
    /// These return self to allow convenient chaining of options.  Note that if the layout view is itself a
    /// layout item in another layout view, the "containing" functions must precede any "withSQxxx" functions.
    ///

    @discardableResult
    public func containingDefaultSizeCalculator(_ c: @escaping SQSizeCalculator) -> Self {
        defaultSizeCalculator = c
        return self
    }

    @discardableResult
    public func containingDefaultSize(_ size: CGSize) -> Self {
        defaultSizeCalculator = {_ in size }
        return self
    }

    @discardableResult
    public func containingDefaultFrameCalculator(_ c: @escaping SQFrameCalculator) -> Self {
        defaultFrameCalculator = c
        return self
    }

    @discardableResult
    public func containingDefaultFrame(_ frame: CGRect) -> Self {
        defaultFrameCalculator = {_ in frame }
        return self
    }

    @discardableResult
    public func containingDefaultSizingFrameCalculator(_ c: @escaping SQFrameCalculator) -> Self {
        defaultSizingFrameCalculator = c
        return self
    }

    @discardableResult
    public func containingDefaultSizingFrame(_ frame: CGRect) -> Self {
        defaultSizingFrameCalculator = {_ in frame }
        return self
    }

    @discardableResult
    public func containingDefaultSpacingCalculator(_ c: @escaping SQSpacingCalculator) -> Self {
        defaultSpacingCalculator = c
        return self
    }

    @discardableResult
    public func containingDefaultSpacing(_ spacing: UIEdgeInsets) -> Self {
        defaultSpacingCalculator = {_ in spacing }
        return self
    }

    @discardableResult
    public func containingDefaultPaddingCalculator(_ c: @escaping SQPaddingCalculator) -> Self {
        defaultPaddingCalculator = c
        return self
    }

    @discardableResult
    public func containingDefaultPadding(_ padding: UIEdgeInsets) -> Self {
        defaultPaddingCalculator = {_ in padding }
        return self
    }

    @discardableResult
    public func containingDefaultLayoutOptionsCalculator(_ c: @escaping SQLayoutOptionsCalculator) -> Self {
        defaultLayoutOptionsCalculator = c
        return self
    }

    @discardableResult
    public func containingDefaultLayoutOptions(_ options: SQLayoutOptions) -> Self {
        defaultLayoutOptionsCalculator = {_ in options }
        return self
    }

    @discardableResult
    public func containingDefaultLayoutObserver(_ observer: @escaping SQLayoutObserver) -> Self {
        defaultLayoutObserver = observer
        return self
    }

    @discardableResult
    public func containingDidLayoutSubviewsCallback(_ callback: @escaping SQLayoutViewCallback) -> Self {
        didLayoutSubviewsCallback = callback
        return self
    }

    // MARK: - UIView
    public override func layoutSubviews() {
        // Update insets
        let layoutInsets = layoutInsets

        // Call container to layout subviews
        container.layoutItems(in: self.bounds, with: layoutInsets, forSizingOnly: false)

        didLayoutSubviewsCallback?(self)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        // Update insets
        let layoutInsets = layoutInsets

        // Call container to get rectangle occupied by items during layout pass
        let layoutBounds = CGRectMake(0, 0, size.width, size.height)
        let occupiedBounds = container.layoutItems(in: layoutBounds, with: layoutInsets, forSizingOnly: true)

        // Return smallest size that will contain all the laid out items within the layout insets
        return CGSizeMake(layoutInsets.left + CGRectGetWidth(occupiedBounds) + layoutInsets.right, layoutInsets.top + CGRectGetHeight(occupiedBounds) + layoutInsets.bottom)
    }

    public override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSizeMake(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude))
    }

    public override func setNeedsLayout() {
        super.setNeedsLayout()

        // Recurse down setNeedsLayout() calls to nested views
        // to ensure everything gets recalculated even if
        // frames don't change since content may have changed.
        for item in self.container.arrangedItems {
            if let layoutView = item.sq_rootItem as? SQLayoutView {
                layoutView.setNeedsLayout()
            }
        }
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return isPointNeverInside ? false : super.point(inside: point, with: event)
    }
}

///
/// Override layoutItem support in UIView with reasonable default behavior
/// where appropriate and fallback to default calculators in enclosing layout view
///
@objc
extension UIView {

    // MARK: - SQLayoutItem
    override public var sq_sizeCalculator: SQSizeCalculator? {
        return (self.superview as? SQLayoutView)?.defaultSizeCalculator ?? SQLayoutCalculators.viewSizeCalculator()
    }

    override public var sq_frameCalculator: SQFrameCalculator? {
        return (self.superview as? SQLayoutView)?.defaultFrameCalculator
    }

    override public var sq_sizingFrameCalculator: SQFrameCalculator? {
        return (self.superview as? SQLayoutView)?.defaultSizingFrameCalculator
    }

    override public var sq_spacingCalculator: SQSpacingCalculator? {
        return (self.superview as? SQLayoutView)?.defaultSpacingCalculator
    }

    override public var sq_paddingCalculator: SQPaddingCalculator? {
        return (self.superview as? SQLayoutView)?.defaultPaddingCalculator
    }

    override public var sq_layoutOptionsCalculator: SQLayoutOptionsCalculator? {
        return (self.superview as? SQLayoutView)?.defaultLayoutOptionsCalculator
    }

    override public var sq_layoutObserver: SQLayoutObserver? {
        return (self.superview as? SQLayoutView)?.defaultLayoutObserver ?? { [weak self] args in
            // Override to set frame upon layout
            if !args.forSizingOnly {
                self?.frame = args.frame
            }
        }
    }
}
