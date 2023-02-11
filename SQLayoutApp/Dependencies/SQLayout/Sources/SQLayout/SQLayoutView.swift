//
//  SQLayoutView.swift
//  SQLayout
//
//  Created by Vince Lee on 2/6/23.
//  (c)2023 All Rights Reserved
//

import UIKit

public typealias SQLayoutViewInsetsCalculator = (SQLayoutView) -> UIEdgeInsets

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
    var layoutInsetsCalculator: SQLayoutViewInsetsCalculator? = nil
    var layoutInsets: UIEdgeInsets { get { layoutInsetsCalculator?(self) ?? .zero } set { layoutInsetsCalculator = {_ in newValue } } }
    
    /// Default calculators for arranged items (if not specifically set by item decorator)
    var defaultSizeCalculator: SQSizeCalculator?
    var defaultFrameCalculator: SQFrameCalculator?
    var defaultSizingFrameCalculator: SQFrameCalculator?
    var defaultSpacingCalculator: SQSpacingCalculator?
    var defaultPaddingCalculator: SQPaddingCalculator?
    var defaultLayoutOptionsCalculator: SQLayoutOptionsCalculator?
    var defaultLayoutObserver: SQLayoutObserver?

    // MARK: - Private properties
    let container = SQLayoutContainer()
    
    // MARK: - Initializers
    public init(layoutInsetsCalculator: @escaping SQLayoutViewInsetsCalculator) {
        self.layoutInsetsCalculator = layoutInsetsCalculator
        super.init(frame: .zero)
    }
    
    public convenience init(layoutInsets: UIEdgeInsets = .zero) {
        self.init(layoutInsetsCalculator: { _ in layoutInsets })
    }
    
    public convenience init() {
        self.init(layoutInsets: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    ///
    /// Convenience factory method for creating an auto-sizing layoutView added as a subview to a parent view
    ///
    @discardableResult
    public static func autosizedView(addedTo view: UIView, layoutGuide: UILayoutGuide? = nil, layoutInsets: UIEdgeInsets = .zero) -> SQLayoutView {
        let contentView = SQLayoutView(layoutInsets: layoutInsets)
        
        // Add content view as subview
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Set constraints
        if let layoutGuide = layoutGuide {
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
                contentView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: view.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        return contentView
    }
    
    ///
    /// Add an item (typically a raw or decorated UIView), as an arranged item.
    /// If the item represents a view then add it as a subview as well.
    /// Returns self to support chaining.
    ///
    public func addArrangedItem(_ item: SQLayoutItem) {
        
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
    public func removeArrangedItem(_ item: SQLayoutItem) {

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

    public func containingArrangedItem(_ item: SQLayoutItem) -> SQLayoutView {
        addArrangedItem(item)
        return self
    }

    public func containingLayoutInsetsCalculator(_ c: @escaping SQLayoutViewInsetsCalculator) -> SQLayoutView {
        layoutInsetsCalculator = c
        return self
    }

    public func containingLayoutInsets(_ insets: UIEdgeInsets) -> SQLayoutView {
        return containingLayoutInsetsCalculator({ _ in insets })
    }

    // MARK: - Public (Decorator Defaults)

    ///
    /// These functions are equivalent to the withSQxxxx() decorator functions applied to individual items,
    /// but allow one to specify a default value for any arranged item that doesn't have a custom value.
    /// These return self to allow convenient chaining of options.  Note that if the layout view is itself a
    /// layout item in another layout view, the "containing" functions must precede any "withSQxxx" functions.
    ///

    public func containingDefaultSizeCalculator(_ c: @escaping SQSizeCalculator) -> SQLayoutView {
        defaultSizeCalculator = c
        return self
    }

    public func containingDefaultSize(_ size: CGSize) -> SQLayoutView {
        defaultSizeCalculator = {_ in size }
        return self
    }

    public func containingDefaultFrameCalculator(_ c: @escaping SQFrameCalculator) -> SQLayoutView {
        defaultFrameCalculator = c
        return self
    }

    public func containingDefaultFrame(_ frame: CGRect) -> SQLayoutView {
        defaultFrameCalculator = {_ in frame }
        return self
    }

    public func containingDefaultSizingFrameCalculator(_ c: @escaping SQFrameCalculator) -> SQLayoutView {
        defaultSizingFrameCalculator = c
        return self
    }

    public func containingDefaultSizingFrame(_ frame: CGRect) -> SQLayoutView {
        defaultSizingFrameCalculator = {_ in frame }
        return self
    }

    public func containingDefaultSpacingCalculator(_ c: @escaping SQSpacingCalculator) -> SQLayoutView {
        defaultSpacingCalculator = c
        return self
    }

    public func containingDefaultSpacing(_ spacing: UIEdgeInsets) -> SQLayoutView {
        defaultSpacingCalculator = {_ in spacing }
        return self
    }

    public func containingDefaultPaddingCalculator(_ c: @escaping SQPaddingCalculator) -> SQLayoutView {
        defaultPaddingCalculator = c
        return self
    }

    public func containingDefaultPadding(_ padding: UIEdgeInsets) -> SQLayoutView {
        defaultPaddingCalculator = {_ in padding }
        return self
    }

    public func containingDefaultLayoutOptionsCalculator(_ c: @escaping SQLayoutOptionsCalculator) -> SQLayoutView {
        defaultLayoutOptionsCalculator = c
        return self
    }

    public func containingDefaultLayoutOptions(_ options: SQLayoutOptions) -> SQLayoutView {
        defaultLayoutOptionsCalculator = {_ in options }
        return self
    }

    public func containingDefaultLayoutObserver(_ observer: @escaping SQLayoutObserver) -> SQLayoutView {
        defaultLayoutObserver = observer
        return self
    }

    // MARK: - UIView
    public override func layoutSubviews() {
        // Update insets
        let layoutInsets = layoutInsets
        
        // Call container to layout subviews
        container.layoutItems(in: self.bounds, with: layoutInsets, forSizingOnly: false)
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
}

///
/// Override layoutItem support in UIView with reasonable default behavior
/// where appropriate and fallback to default calculators in enclosing layout view
///
@objc
extension UIView {
    
    // MARK: - SQLayoutItem

    override public var sq_sizeCalculator: SQSizeCalculator? {
        return (self.superview as? SQLayoutView)?.defaultSizeCalculator ?? { [weak self] args in
            // Override to default to sizeThatFits for size calculation
            return self?.sizeThatFits(args.fittingSize) ?? .zero
        }
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
