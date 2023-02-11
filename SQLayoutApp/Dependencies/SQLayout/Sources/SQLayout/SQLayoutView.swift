//
//  SQLayoutView.swift
//  SQLayout
//
//  Created by Vince Lee on 2/6/23.
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
    var layoutInsets: UIEdgeInsets = .zero
    var layoutInsetsCalculator: SQLayoutViewInsetsCalculator? = nil
    var contentSpacing: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var contentSpacingCalculator: SQLayoutViewInsetsCalculator? = nil

    // MARK: - Private properties
    let container = SQLayoutContainer()

    // MARK: - Factory methods
    
    /// Convenience factory method for creating a layoutView mapped to a parent view
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

    // MARK: - Initializers
    public init(layoutInsetsCalculator: @escaping SQLayoutViewInsetsCalculator) {
        self.layoutInsetsCalculator = layoutInsetsCalculator
        super.init(frame: .zero)
    }
    
    public init(layoutInsets: UIEdgeInsets = .zero) {
        self.layoutInsets = layoutInsets
        super.init(frame: .zero)
    }
    
    convenience init() {
        self.init(layoutInsets: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    // Set a layout insets calculator and return self for chaining
    @discardableResult
    public func useLayoutInsetsCalculator(_ c: @escaping SQLayoutViewInsetsCalculator) -> SQLayoutView {
        layoutInsetsCalculator = c
        layoutInsets = c(self)
        return self
    }
    
    @discardableResult
    public func useLayoutInsets(_ insets: UIEdgeInsets) -> SQLayoutView {
        return useLayoutInsetsCalculator({ _ in insets })
    }

    // Set a content spacing calculator and return self for chaining
    @discardableResult
    public func useContentSpacingCalculator(_ c: @escaping SQLayoutViewInsetsCalculator) -> SQLayoutView {
        contentSpacingCalculator = c
        contentSpacing = c(self)
        return self
    }

    @discardableResult
    public func useContentSpacing(_ insets: UIEdgeInsets) -> SQLayoutView {
        return useContentSpacingCalculator({ _ in insets })
    }

    ///
    /// Add an item (typically a raw or decorated UIView), as an arranged item.
    /// If the item represents a view then add it as a subview as well.
    /// Returns self to support chaining.
    @discardableResult
    public func addArrangedItem(_ item: SQLayoutItem) -> SQLayoutView {
        
        // Add item to container
        container.arrangedItems.append(item)

        // Add as subview if item represents a view
        if let subview = item.sq_rootItem as? UIView {
            self.addSubview(subview)
        }
        setNeedsLayout()
        return self
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

    // MARK: - UIView
    public override func layoutSubviews() {
        // Update insets
        if let layoutInsetsCalculator = layoutInsetsCalculator {
            layoutInsets = layoutInsetsCalculator(self)
        }
        if let contentSpacingCalculator = contentSpacingCalculator {
            contentSpacing = contentSpacingCalculator(self)
        }
        // Call container to layout subviews
        container.layoutItems(in: self.bounds, with: layoutInsets, forSizingOnly: false)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        // Update insets
        if let layoutInsetsCalculator = layoutInsetsCalculator {
            layoutInsets = layoutInsetsCalculator(self)
        }
        if let contentSpacingCalculator = contentSpacingCalculator {
            contentSpacing = contentSpacingCalculator(self)
        }
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
