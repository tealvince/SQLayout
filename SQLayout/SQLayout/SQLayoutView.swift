//
//  SQLayoutView.swift
//  SLKit
//
//  Created by Vince Lee on 2/6/23.
//

import UIKit

public typealias SQLayoutViewInsetsCalculator = (SQLayoutView) -> UIEdgeInsets

///
/// A container view that supports sequential layout on subviews
///
@objcMembers
public class SQLayoutView: UIView {
    // MARK: - Public properties
    var layoutInsets: UIEdgeInsets = .zero
    var layoutInsetsCalculator: SQLayoutViewInsetsCalculator? = nil

    // MARK: - Private properties
    let container = SQLayoutContainer()
    let maxAutosizingOffsetX: CGFloat = 100
    let maxAutosizingOffsetY: CGFloat = 100

    // MARK: - Factory methods
    
    /// Convenience factory method for creating a layoutView mapped to a parent view
    public static func contentView(addedTo view: UIView, layoutGuide: UILayoutGuide?, layoutInsets: UIEdgeInsets = .zero) -> SQLayoutView {
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
    
    public init(layoutInsets: UIEdgeInsets) {
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
    
    ///
    /// Add an item (typically a raw or decorated UIView), as an arranged item.
    /// If the item represents a view then add it as a subview as well.
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
        // Call container to layout subviews
        container.layoutItems(in: self.bounds, with: layoutInsets, forSizingOnly: false)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        // Call container to get rectangle occupied by items during layout pass
        let layoutBounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, size.width, size.height)
        var occupiedBounds = container.layoutItems(in: layoutBounds, with: layoutInsets, forSizingOnly: true)
        
        // Sizing is typically called with a large height or width (e.g. CGFloat.max)
        // to get the ideal size that a view wants to be.  If our items are center, right,
        // or bottom-aligned, however, the origin of the occupied bounds is meaninglessly
        // large and we should align the content to the top/left content insets instead.
        if occupiedBounds.origin.x > maxAutosizingOffsetX {
            occupiedBounds.origin.x = layoutInsets.left
        }
        if occupiedBounds.origin.y > maxAutosizingOffsetY {
            occupiedBounds.origin.y = layoutInsets.top
        }
        
        return CGSizeMake(CGRectGetMaxX(occupiedBounds) + layoutInsets.right, CGRectGetMaxY(occupiedBounds) + layoutInsets.bottom)
    }
}
