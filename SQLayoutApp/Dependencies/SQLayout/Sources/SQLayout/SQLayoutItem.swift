//
//  SQLayoutItem.swift
//  SQLayout
//
//  Created by Vince Lee on 2/5/23.
//

import UIKit

///
/// Represents an object that can perform sequential layout.
///
@objc
public protocol SQLayoutItem {
    // The real item if the current item is a proxy
    var sq_rootItem: NSObject? { get }
    
    // Closure decorations
    var sq_sizeCalculator: SQSizeCalculator? { get }
    var sq_frameCalculator: SQFrameCalculator? { get }
    var sq_contentSpacingCalculator: SQContentSpacingCalculator? { get }
    var sq_contentPaddingCalculator: SQContentPaddingCalculator? { get }
    var sq_layoutOptionsCalculator: SQLayoutOptionsCalculator? { get }
    var sq_layoutObserver: SQLayoutObserver? { get }
}

@objc
public protocol SQMutableLayoutItem: SQLayoutItem {
    // Mutable variables stored separately to avoid conflict with immutable property
    var mutable_sq_rootItem: NSObject? { get set }
    var mutable_sq_sizeCalculator: SQSizeCalculator? { get set }
    var mutable_sq_frameCalculator: SQFrameCalculator? { get set }
    var mutable_sq_contentSpacingCalculator: SQContentSpacingCalculator? { get set }
    var mutable_sq_contentPaddingCalculator: SQContentPaddingCalculator? { get set }
    var mutable_sq_layoutOptionsCalculator: SQLayoutOptionsCalculator? { get set }
    var mutable_sq_layoutObserver: SQLayoutObserver? { get set }
}

///
/// A wrapper object used to add sequential layout support and mutability to wrapped objects.
///
@objcMembers
public class SQMutableProxyLayoutItem: NSObject, SQMutableLayoutItem {
    
    // MARK: - Initializer
    init(rootItem: NSObject) {
        self.mutable_sq_rootItem = rootItem.sq_rootItem ?? rootItem
        self.mutable_sq_sizeCalculator = rootItem.sq_sizeCalculator
        self.mutable_sq_frameCalculator = rootItem.sq_frameCalculator
        self.mutable_sq_contentSpacingCalculator = rootItem.sq_contentSpacingCalculator
        self.mutable_sq_contentPaddingCalculator = rootItem.sq_contentPaddingCalculator
        self.mutable_sq_layoutOptionsCalculator = rootItem.sq_layoutOptionsCalculator
        self.mutable_sq_layoutObserver = rootItem.sq_layoutObserver
    }
    
    // MARK: - SQMutableLayoutItem
    public var mutable_sq_rootItem: NSObject?
    public var mutable_sq_sizeCalculator: SQSizeCalculator?
    public var mutable_sq_frameCalculator: SQFrameCalculator?
    public var mutable_sq_contentSpacingCalculator: SQContentSpacingCalculator?
    public var mutable_sq_contentPaddingCalculator: SQContentPaddingCalculator?
    public var mutable_sq_layoutOptionsCalculator: SQLayoutOptionsCalculator?
    public var mutable_sq_layoutObserver: SQLayoutObserver?
        
    // MARK: - SQMutableLayoutItem
    override public var sq_rootItem: NSObject? { mutable_sq_rootItem }
    override public var sq_sizeCalculator: SQSizeCalculator? { mutable_sq_sizeCalculator }
    override public var sq_frameCalculator: SQFrameCalculator? { mutable_sq_frameCalculator }
    override public var sq_contentSpacingCalculator: SQContentSpacingCalculator? { mutable_sq_contentSpacingCalculator }
    override public var sq_contentPaddingCalculator: SQContentPaddingCalculator? { mutable_sq_contentPaddingCalculator }
    override public var sq_layoutOptionsCalculator: SQLayoutOptionsCalculator? { mutable_sq_layoutOptionsCalculator }
    override public var sq_layoutObserver: SQLayoutObserver? { mutable_sq_layoutObserver }
}

///
/// Extension that supports declaring custom calculators with handy .withXYZ chaining decorator
/// syntax, to customize functionality to an object when used as an arranged item e.g:
///
/// item = view
///     .withSQSizeCalculator({...})
///     .withSQContentSpacingCalculator({...})
///
@objc
public extension NSObject {

    // MARK: - Public Decorators (closures)
    func withSQSizeCalculator(_ c: @escaping SQSizeCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_sizeCalculator = c }
    }
    func withSQFrameCalculator(_ c: @escaping SQFrameCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_frameCalculator = c }
    }
    func withSQContentSpacingCalculator(_ c: @escaping SQContentSpacingCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_contentSpacingCalculator = c }
    }
    func withSQContentPaddingCalculator(_ c: @escaping SQContentPaddingCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_contentPaddingCalculator = c }
    }
    func withSQLayoutOptionsCalculator(_ c: @escaping SQLayoutOptionsCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_layoutOptionsCalculator = c }
    }
    func withSQLayoutObserver(_ c: @escaping SQLayoutObserver) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_layoutObserver = c }
    }

    // MARK: - Public Decorator (conveniences for constant return values)
    func withSQSize(_ size: CGSize) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_sizeCalculator = {_ in size} }
    }
    func withSQFrame(_ frame: CGRect) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_frameCalculator = {_ in frame} }
    }
    func withSQContentSpacing(_ spacing: UIEdgeInsets) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_contentSpacingCalculator = {_ in spacing} }
    }
    func withSQContentPadding(_ padding: UIEdgeInsets) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_contentPaddingCalculator = {_ in padding} }
    }
    func withSQLayoutOptions(_ options: SQLayoutOptions) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_layoutOptionsCalculator = {_ in options} }
    }
    
    // MARK: - Private
    private func mutableLayoutItem(_ initialization: @escaping (SQMutableLayoutItem) -> Void) -> NSObject & SQLayoutItem {
        // Return self if already a mutable proxy, else wrap it in one
        let item = self as? NSObject & SQMutableLayoutItem ?? SQMutableProxyLayoutItem(rootItem: self)
        initialization(item)
        return item
    }
}


///
/// Add default properties for layout items
///
@objc
extension NSObject: SQLayoutItem {

    // MARK: - SQLayoutItem
    public var sq_rootItem: NSObject? { return self }
    public var sq_sizeCalculator: SQSizeCalculator? { nil }
    public var sq_frameCalculator: SQFrameCalculator? { nil }
    public var sq_contentSpacingCalculator: SQContentSpacingCalculator? { nil }
    public var sq_contentPaddingCalculator: SQContentPaddingCalculator? { nil }
    public var sq_layoutOptionsCalculator: SQLayoutOptionsCalculator? { nil }
    public var sq_layoutObserver: SQLayoutObserver? { nil }
}

///
/// Add layoutItem support to UIView with reasonable default behavior so that
/// users only need to define calculators when the default behavior needs
/// to be customized.
///
@objc
extension UIView {
    
    // MARK: - SQLayoutItem
    
    /// Override to support sizeThatFits
    override public var sq_sizeCalculator: SQSizeCalculator { { args in
        guard let view = args.item.sq_rootItem as? UIView else { return .zero }
        return view.sizeThatFits(args.fittingSize)
    } }
    
    /// Override to default to contentSpacing in containing layoutView
    override public var sq_contentSpacingCalculator: SQContentSpacingCalculator { { args in
        guard let view = args.item.sq_rootItem as? UIView, let layoutView = view.superview as? SQLayoutView else { return .zero }
        return layoutView.contentSpacing
    } }

    /// Override to update frame upon layout
    override public var sq_layoutObserver: SQLayoutObserver { { args in
        guard let view = args.item.sq_rootItem as? UIView, !args.forSizingOnly else { return }
        view.frame = args.frame
    } }
}
