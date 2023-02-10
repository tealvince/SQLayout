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
    var sq_sizeCalculator: SQSizeCalculator { get }
    var sq_frameCalculator: SQFrameCalculator { get }
    var sq_contentSpacingCalculator: SQContentSpacingCalculator { get }
    var sq_contentPaddingCalculator: SQContentPaddingCalculator { get }
    var sq_layoutOptionsCalculator: SQLayoutOptionsCalculator { get }
    var sq_layoutObserver: SQLayoutObserver { get }
}

///
/// A wrapper object used to add sequential layout support and mutability to wrapped objects.
///
@objcMembers
public class SQMutableProxyLayoutItem: NSObject, SQLayoutItem {
    
    // MARK: - SQLayoutItem
    public var sq_rootItem: NSObject?
    
    public var sq_sizeCalculator: SQSizeCalculator = { _ in .zero }
    public var sq_frameCalculator: SQFrameCalculator = SQLayoutCalculators.containerLeftAlignedVStack
    public var sq_contentSpacingCalculator: SQContentSpacingCalculator = { _ in .zero }
    public var sq_contentPaddingCalculator: SQContentPaddingCalculator = { _ in .zero }
    public var sq_layoutOptionsCalculator: SQLayoutOptionsCalculator = { _ in SQLayoutOptions() }
    public var sq_layoutObserver: SQLayoutObserver = { _ in }
    
    init(rootItem: NSObject) {
        if let sourceItem = rootItem as? SQLayoutItem {
            self.sq_rootItem = sourceItem.sq_rootItem ?? rootItem
            self.sq_sizeCalculator = sourceItem.sq_sizeCalculator
            self.sq_frameCalculator = sourceItem.sq_frameCalculator
            self.sq_contentSpacingCalculator = sourceItem.sq_contentSpacingCalculator
            self.sq_contentPaddingCalculator = sourceItem.sq_contentPaddingCalculator
            self.sq_layoutOptionsCalculator = sourceItem.sq_layoutOptionsCalculator
            self.sq_layoutObserver = sourceItem.sq_layoutObserver
        } else {
            self.sq_rootItem = rootItem
        }
    }
}

///
/// Extension that supports declaring custom calculators with handy .withXYZ chaining decorator syntax, e.g:
///
/// item = view
///     .withSQSizeCalculator({...})
///     .withSQContentSpacingCalculator({...})
///
@objc
public extension NSObject {

    // MARK: - Public Decorators (closures)
    func withSQSizeCalculator(_ c: @escaping SQSizeCalculator) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_sizeCalculator = c }
    }
    func withSQFrameCalculator(_ c: @escaping SQFrameCalculator) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_frameCalculator = c }
    }
    func withSQContentSpacingCalculator(_ c: @escaping SQContentSpacingCalculator) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_contentSpacingCalculator = c }
    }
    func withSQContentPaddingCalculator(_ c: @escaping SQContentPaddingCalculator) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_contentPaddingCalculator = c }
    }
    func withSQLayoutOptionsCalculator(_ c: @escaping SQLayoutOptionsCalculator) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_layoutOptionsCalculator = c }
    }
    func withSQLayoutObserver(_ c: @escaping SQLayoutObserver) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_layoutObserver = c }
    }

    // MARK: - Public Decorator (conveniences for constant return values)
    func withSQSize(_ size: CGSize) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_sizeCalculator = {_ in size} }
    }
    func withSQFrame(_ frame: CGRect) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_frameCalculator = {_ in frame} }
    }
    func withSQContentSpacing(_ spacing: UIEdgeInsets) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_contentSpacingCalculator = {_ in spacing} }
    }
    func withSQContentPadding(_ padding: UIEdgeInsets) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_contentPaddingCalculator = {_ in padding} }
    }
    func withSQLayoutOptions(_ options: SQLayoutOptions) -> SQMutableProxyLayoutItem {
        return mutableLayoutItem() { $0.sq_layoutOptionsCalculator = {_ in options} }
    }

    // MARK: - Private
    private func mutableLayoutItem(_ initialization: @escaping (SQMutableProxyLayoutItem) -> Void) -> SQMutableProxyLayoutItem {
        // Return self if already a mutable proxy, else wrap it in one
        let item = self as? SQMutableProxyLayoutItem ?? SQMutableProxyLayoutItem(rootItem: self)
        initialization(item)
        return item
    }
}

///
/// Add layoutItem support to UIView with reasonable default behavior so that
/// users only need to define calculators when the default behavior needs
/// to be customized.
///
extension UIView: SQLayoutItem {
    
    // MARK: - SQLayoutItem
    public var sq_rootItem: NSObject? { return self }

    public var sq_sizeCalculator: SQSizeCalculator { { [weak self] args in return self?.sizeThatFits(args.fittingSize) ?? .zero } }
    public var sq_frameCalculator: SQFrameCalculator { SQLayoutCalculators.containerLeftAlignedVStack }
    public var sq_contentSpacingCalculator: SQContentSpacingCalculator { { _ in UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) } }
    public var sq_contentPaddingCalculator: SQContentPaddingCalculator { { _ in .zero } }
    public var sq_layoutOptionsCalculator: SQLayoutOptionsCalculator { { _ in return SQLayoutOptions() } }

    // Update frame upon layout
    public var sq_layoutObserver: SQLayoutObserver {
        { [weak self] args in
            if !args.forSizingOnly {
                self?.frame = args.frame
            }
        }
    }
}
