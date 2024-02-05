//
//  MainViewController.swift
//  SQLayout
//
//  Created by Vince Lee on 2/5/23.
//

import SQLayout
import UIKit

class MainViewController: UIViewController {
    private var timer: Timer?

    // Nice looking colors
    private let red = UIColor(red: 1.0, green: 0.42, blue: 0.44, alpha: 1)
    private let orange = UIColor(red: 1.0, green: 0.66, blue: 0.30, alpha: 1)
    private let yellow = UIColor(red: 0.95, green: 1.0, blue: 0.63, alpha: 1)
    private let green = UIColor(red: 0.51, green: 1.0, blue: 0.69, alpha: 1)
    private let blue = UIColor(red: 0.45, green: 0.72, blue: 1, alpha: 1)
    private let purple = UIColor(red: 0.75, green: 0.50, blue: 1.0, alpha: 1)

    private var nextCounter = 0
    // Make some view that we'll need to reference directly
    private let topWrapper = SQLayoutView(layoutInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        .makeBorderless(color: UIColor.white)
    private let bottomWrapper = SQLayoutView(layoutInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)).makeBorderless(color: UIColor.white)
    private lazy var nextLabel = { createTestView("", green.withAlphaComponent(0.85)) }()
    private lazy var nextLabel2 = { createTestView("", blue.withAlphaComponent(0.85)) }()
    private var nextCalculator = SQLayoutCalculators.widthAlignedVStack

    // Table of all calculators for cycling slideshow demo
    private let allCalculators = [
        // vstack (previous)
        "1 widthAlignedVStack" : SQLayoutCalculators.widthAlignedVStack,
        "2 leftAlignedVStack" : SQLayoutCalculators.leftAlignedVStack,
        "3 rightAlignedVStack" : SQLayoutCalculators.rightAlignedVStack,
        "4 centerAlignedVStack" : SQLayoutCalculators.centerAlignedVStack,
        "5 widthAlignedVStackUp" : SQLayoutCalculators.widthAlignedVStackUp,
        "6 leftAlignedVStackUp" : SQLayoutCalculators.leftAlignedVStackUp,
        "7 rightAlignedVStackUp" : SQLayoutCalculators.rightAlignedVStackUp,
        "8 centerAlignedVStackUp" : SQLayoutCalculators.centerAlignedVStackUp,

        // hstack (previous)
        "9 heightAlignedHStack" : SQLayoutCalculators.heightAlignedHStack,
        "10 topAlignedHStack" : SQLayoutCalculators.topAlignedHStack,
        "11 bottomAlignedHStack" : SQLayoutCalculators.bottomAlignedHStack,
        "12 centerAlignedHStack" : SQLayoutCalculators.centerAlignedHStack,
        "13 heightAlignedHStackLeft" : SQLayoutCalculators.heightAlignedHStackLeft,
        "14 topAlignedHStackLeft" : SQLayoutCalculators.topAlignedHStackLeft,
        "15 bottomAlignedHStackLeft" : SQLayoutCalculators.bottomAlignedHStackLeft,
        "16 centerAlignedHStackLeft" : SQLayoutCalculators.centerAlignedHStackLeft,

        // hstack (previous, cropped)
        "17 topAlignedHStackCropped" : SQLayoutCalculators.topAlignedHStackCropped,
        "18 bottomAlignedHStackCropped" : SQLayoutCalculators.bottomAlignedHStackCropped,
        "19 centerAlignedHStackCropped" : SQLayoutCalculators.centerAlignedHStackCropped,
        "20 topAlignedHStackLeftCropped" : SQLayoutCalculators.topAlignedHStackLeftCropped,
        "21 bottomAlignedHStackLeftCropped" : SQLayoutCalculators.bottomAlignedHStackLeftCropped,
        "22 centerAlignedHStackLeftCropped" : SQLayoutCalculators.centerAlignedHStackLeftCropped,

        // vstack (container)
        "23 containerWidthVStack" : SQLayoutCalculators.containerWidthVStack,
        "24 containerLeftAlignedVStack" : SQLayoutCalculators.containerLeftAlignedVStack,
        "25 containerRightAlignedVStack" : SQLayoutCalculators.containerRightAlignedVStack,
        "26 containerCenterAlignedVStack" : SQLayoutCalculators.containerCenterAlignedVStack,
        "27 containerWidthVStackUp" : SQLayoutCalculators.containerWidthVStackUp,
        "28 containerLeftAlignedVStackUp" : SQLayoutCalculators.containerLeftAlignedVStackUp,
        "29 containerRightAlignedVStackUp" : SQLayoutCalculators.containerRightAlignedVStackUp,
        "30 containerCenterAlignedVStackUp" : SQLayoutCalculators.containerCenterAlignedVStackUp,


        // hstack (container)
        "31 containerHeightHStack" : SQLayoutCalculators.containerHeightHStack,
        "32 containerTopAlignedHStack" : SQLayoutCalculators.containerTopAlignedHStack,
        "33 containerBottomAlignedHStack" : SQLayoutCalculators.containerBottomAlignedHStack,
        "34 containerCenterAlignedHStack" : SQLayoutCalculators.containerCenterAlignedHStack,
        "35 containerHeightHStackLeft" : SQLayoutCalculators.containerHeightHStackLeft,
        "36 containerTopAlignedHStackLeft" : SQLayoutCalculators.containerTopAlignedHStackLeft,
        "37 containerBottomAlignedHStackLeft" : SQLayoutCalculators.containerBottomAlignedHStackLeft,
        "38 containerCenterAlignedHStackLeft" : SQLayoutCalculators.containerCenterAlignedHStackLeft,

        // hstack (container, cropped)
        "39 containerTopAlignedHStackCropped" : SQLayoutCalculators.containerTopAlignedHStackCropped,
        "40 containerBottomAlignedHStackCropped" : SQLayoutCalculators.containerBottomAlignedHStackCropped,
        "41 containerCenterAlignedHStackCropped" : SQLayoutCalculators.containerCenterAlignedHStackCropped,
        "42 containerTopAlignedHStackLeftCropped" : SQLayoutCalculators.containerTopAlignedHStackLeftCropped,
        "43 containerBottomAlignedHStackLeftCropped" : SQLayoutCalculators.containerBottomAlignedHStackLeftCropped,
        "44 containerCenterAlignedHStackLeftCropped" : SQLayoutCalculators.containerCenterAlignedHStackLeftCropped,

        // flow
        "45 heightAlignedFlow" : SQLayoutCalculators.heightAlignedFlow,
        "46 topAlignedFlow" : SQLayoutCalculators.topAlignedFlow,
        "47 bottomAlignedFlow" : SQLayoutCalculators.bottomAlignedFlow,
        "48 centerAlignedFlow" : SQLayoutCalculators.centerAlignedFlow,
        "49 heightAlignedFlowLeft" : SQLayoutCalculators.heightAlignedFlowLeft,
        "50 topAlignedFlowLeft" : SQLayoutCalculators.topAlignedFlowLeft,
        "51 bottomAlignedFlowLeft" : SQLayoutCalculators.bottomAlignedFlowLeft,
        "52 centerAlignedFlowLeft" : SQLayoutCalculators.centerAlignedFlowLeft,

        // fill
        "53 heightAlignedFillToRight" : SQLayoutCalculators.heightAlignedFillToRight,
        "54 topAlignedFillToRight" : SQLayoutCalculators.topAlignedFillToRight,
        "55 bottomAlignedFillToRight" : SQLayoutCalculators.bottomAlignedFillToRight,
        "56 centerAlignedFillToRight" : SQLayoutCalculators.centerAlignedFillToRight,
        "57 heightAlignedFillToLeft" : SQLayoutCalculators.heightAlignedFillToLeft,
        "58 topAlignedFillToLeft" : SQLayoutCalculators.topAlignedFillToLeft,
        "59 bottomAlignedFillToLeft" : SQLayoutCalculators.bottomAlignedFillToLeft,
        "60 centerAlignedFillToLeft" : SQLayoutCalculators.centerAlignedFillToLeft,
        "61 leftAlignedFillToTop" : SQLayoutCalculators.leftAlignedFillToTop,
        "62 rightAlignedFillToTop" : SQLayoutCalculators.rightAlignedFillToTop,
        "63 centerAlignedFillToTop" : SQLayoutCalculators.centerAlignedFillToTop,
        "64 leftAlignedFillToBottom" : SQLayoutCalculators.leftAlignedFillToBottom,
        "65 rightAlignedFillToBottom" : SQLayoutCalculators.rightAlignedFillToBottom,
        "66 centerAlignedFillToBottom" : SQLayoutCalculators.centerAlignedFillToBottom,
        "67 widthAlignedFillToTop" : SQLayoutCalculators.widthAlignedFillToTop,
        "68 widthAlignedFillToBottom" : SQLayoutCalculators.widthAlignedFillToBottom,

        // in-previous
        "69 centerAligned" : SQLayoutCalculators.centerAligned,
        "70 topLeftAligned" : SQLayoutCalculators.topLeftAligned,
        "71 centerTopAligned" : SQLayoutCalculators.centerTopAligned,
        "72 topRightAligned" : SQLayoutCalculators.topRightAligned,
        "73 centerRightAligned" : SQLayoutCalculators.centerRightAligned,
        "74 bottomRightAligned" : SQLayoutCalculators.bottomRightAligned,
        "75 centerBottomAligned" : SQLayoutCalculators.centerBottomAligned,
        "76 bottomLeftAligned" : SQLayoutCalculators.bottomLeftAligned,
        "77 centerLeftAligned" : SQLayoutCalculators.centerLeftAligned,
        "78 widthTopAligned" : SQLayoutCalculators.widthTopAligned,
        "79 widthBottomAligned" : SQLayoutCalculators.widthBottomAligned,
        "80 widthCenterAligned" : SQLayoutCalculators.widthCenterAligned,
        "81 heightLeftAligned" : SQLayoutCalculators.heightLeftAligned,
        "82 heightRightAligned" : SQLayoutCalculators.heightRightAligned,
        "83 heightCenterAligned" : SQLayoutCalculators.heightCenterAligned,

        // between container/previous
        "84 containerLeftOfPrevious" : SQLayoutCalculators.containerLeftOfPrevious,
        "85 containerRightOfPrevious" : SQLayoutCalculators.containerRightOfPrevious,
        "86 containerAbovePrevious" : SQLayoutCalculators.containerAbovePrevious,
        "87 containerBelowPrevious" : SQLayoutCalculators.containerBelowPrevious,

        // in-container
        "88 containerCenterAligned" : SQLayoutCalculators.containerCenterAligned,
        "89 containerTopLeftAligned" : SQLayoutCalculators.containerTopLeftAligned,
        "90 containerCenterTopAligned" : SQLayoutCalculators.containerCenterTopAligned,
        "91 containerTopRightAligned" : SQLayoutCalculators.containerTopRightAligned,
        "92 containerCenterRightAligned" : SQLayoutCalculators.containerCenterRightAligned,
        "93 containerBottomRightAligned" : SQLayoutCalculators.containerBottomRightAligned,
        "94 containerCenterBottomAligned" : SQLayoutCalculators.containerCenterBottomAligned,
        "95 containerBottomLeftAligned" : SQLayoutCalculators.containerBottomLeftAligned,
        "96 containerCenterLeftAligned" : SQLayoutCalculators.containerCenterLeftAligned,
        "97 containerWidthTopAligned" : SQLayoutCalculators.containerWidthTopAligned,
        "98 containerWidthBottomAligned" : SQLayoutCalculators.containerWidthBottomAligned,
        "99 containerWidthCenterAligned" : SQLayoutCalculators.containerWidthCenterAligned,
        "100 containerHeightLeftAligned" : SQLayoutCalculators.containerHeightLeftAligned,
        "101 containerHeightRightAligned" : SQLayoutCalculators.containerHeightRightAligned,
        "102 containerHeightCenterAligned" : SQLayoutCalculators.containerHeightCenterAligned,

        // matching
        "103 matchPrevious" : SQLayoutCalculators.matchPrevious,
        "104 matchContainer" : SQLayoutCalculators.matchContainer,
        "105 matchContainerFullBleed" : SQLayoutCalculators.matchContainerFullBleed,
    ]

    // Keys sorted in order above
    lazy var calculatorKeys = {
        allCalculators.keys.sorted { Int($0.components(separatedBy: " ")[0])! < Int($1.components(separatedBy: " ")[0])! }
    } ()

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "SQLayout Demo"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.textColor = UIColor.white
        return titleLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black

        let nextSizeCalculator: SQSizeCalculator = { [weak self] args in
            // cap width to it doesn't overflow off screen (we can always read the name)
            return SQLayoutCalculators.viewSizeCalculator(maxSize: CGSizeMake(args.container.layoutBounds.width/2 - (args.item.sq_rootItem == self?.nextLabel ? 70 : 50), CGFloat.greatestFiniteMagnitude))(args)
        }

        //
        // Create an autosizing content view automatically added to view.
        // We don't need a reference to it, so ignore the return value.
        //
        SQLayoutView.addAutosizedView(to: view, layoutGuide: view.safeAreaLayoutGuide, layoutInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))

            // Add title to top (defaults to left-aligned vstack layout)
            .containingArrangedItem(titleLabel)

            //-----------------------------------------------------------------------------
            // Add an auto-sized nested layout top wrapper view with gobs of subviews
            //
            // Fill it with a bunch of arranged views to test various layout calculators
            // Each line simply adds a test view, decorating it with any calculators to
            // define/customize its layout
            //-----------------------------------------------------------------------------
            .containingArrangedItem(topWrapper

                // Define arranged views here, chaining them for syntactic sugar (could also just add them individually)
                .containingArrangedItem(createTestView("container full width", red)
                    .withSQFrameCalculator(SQLayoutCalculators.containerWidthVStack)
                )
                .containingArrangedItem(createTestView("container-left-aligned", red)
                    .withSQFrameCalculator(SQLayoutCalculators.containerLeftAlignedVStack)
                )
                .containingArrangedItem(createTestView("container-right-aligned", red)
                    .withSQFrameCalculator(SQLayoutCalculators.containerRightAlignedVStack)
                )
                .containingArrangedItem(createTestView("container-center", red)
                    .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
                )
                .containingArrangedItem(createTestView("right-aligned", orange)
                    .withSQFrameCalculator(SQLayoutCalculators.rightAlignedVStack)
                )
                .containingArrangedItem(createTestView("left-aligned", orange)
                    .withSQFrameCalculator(SQLayoutCalculators.leftAlignedVStack)
                )
                .containingArrangedItem(createTestView("center", orange)
                    .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStack)
                )
                .containingArrangedItem(createTestView("flow short", yellow)
                    .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
                )
                .containingArrangedItem(createTestView("flow longer", yellow)
                    .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
                )
                .containingArrangedItem(createTestView("flow longest", yellow)
                    .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
                )

                // Content spacing examples
                .containingArrangedItem(createTestView("flow middle", yellow)
                    .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
                    .withSQSpacing(UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0))
                )
                .containingArrangedItem(createTestView("hub", blue)
                    .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
                    .withSQSpacing(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
                )

                // NoPrevious option examples
                .containingArrangedItem(createTestView("leaf", green)
                    .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStackUp)
                    .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
                )
                .containingArrangedItem(createTestView("leaf", green)
                    .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStack)
                    .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
                )
                .containingArrangedItem(createTestView("leaf", green)
                    .withSQFrameCalculator(SQLayoutCalculators.centerAlignedHStack)
                    .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
                )
                .containingArrangedItem(createTestView("leaf", green)
                    .withSQFrameCalculator(SQLayoutCalculators.centerAlignedHStackLeft)
                    .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
                )

                // Frame calculator composition examples
                .containingArrangedItem(createTestView("leaf", green)
                    .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStackUp(args), -40, 10) }
                    .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
                )
                .containingArrangedItem(createTestView("leaf", green)
                    .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStackUp(args), 40, 10) }
                    .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
                )
                .containingArrangedItem(createTestView("leaf", green)
                    .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStack(args), -40, -10) }
                    .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
                )
                .containingArrangedItem(createTestView("leaf", green)
                    .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStack(args), 40, -10) }
                    .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
                )
                .containingArrangedItem(createTestView("bottom-left", purple)
                    .withSQFrameCalculator(SQLayoutCalculators.containerBottomLeftAligned)
                    .withSQLayoutOptions(SQLayoutOptions(shouldIgnoreWhenCalculatingSize: true))
                )
                .containingArrangedItem(createTestView("bottom-right", purple)
                    .withSQFrameCalculator(SQLayoutCalculators.containerBottomRightAligned)
                    .withSQLayoutOptions(SQLayoutOptions(shouldIgnoreWhenCalculatingSize: true))
                )

                // Set default spacing/sizing for all contained subview items
                .containingDefaultSpacing(UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5))
                .containingDefaultSizeCalculator(SQLayoutCalculators.viewSizeCalculator(addWidth: 6, addHeight: 4))

                // Add decorators for our wrapper view (must come after
                // containing... calls because it doesn't return a layoutView
                .withSQFrameCalculator(SQLayoutCalculators.containerWidthVStack)
            )

            //-----------------------------------------------------------------------------
            // Add bottom wrapper showing view cycling through frame calculators
            //-----------------------------------------------------------------------------
            .containingArrangedItem(bottomWrapper
                // Add a border object to show layout bounds
                .containingArrangedItem(UIView().makeBorderless(color: UIColor.darkGray)
                    .withSQFrameCalculator(SQLayoutCalculators.matchContainer(_:))
                )
                // Center "previous" object
                .containingArrangedItem(createTestView("prev", yellow)
                    .withSQFrameCalculator(SQLayoutCalculators.containerCenterAligned)
                    .withSQSize(CGSizeMake(50, 50))
                )
                // Dynamic "next" object
                .containingArrangedItem(nextLabel
                    .withSQFrameCalculator({ [weak self] args in return self?.nextCalculator(args) ?? .zero })
                    .withSQSizeCalculator(nextSizeCalculator)
                )
                .containingArrangedItem(nextLabel2
                    .withSQFrameCalculator({ [weak self] args in
                        let rect = self?.nextCalculator(args) ?? .zero
                        if !args.forSizingOnly {
                            // Hide if small since doubling up some calculators (like fill ones) doesn't make sense
                            (args.item.sq_rootItem as? UILabel)?.alpha = (rect.width <= 5 || rect.height <= 5) ? 0:1
                        }
                        return rect
                    })
                    .withSQSizeCalculator(nextSizeCalculator)
                )
                .containingDefaultSpacing(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
                .withSQFrameCalculator(SQLayoutCalculators.containerBelowPrevious)
                .withSQSpacing(UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
            )

        //
        // Set a timer that increments the calculator used by the "next" item every two seconds
        //
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.advanceNextCalculator()
        }
        timer?.fire()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(slideshowTapped))
        bottomWrapper.addGestureRecognizer(tapRecognizer)
    }

    // MARK: - Private
    @objc
    private func slideshowTapped() {
        timer?.fire()
    }

    private func advanceNextCalculator() {
        let key = self.calculatorKeys[nextCounter % self.calculatorKeys.count]
        nextLabel.text = key.components(separatedBy: " ")[1]
        nextLabel2.text = key.components(separatedBy: " ")[1]
        nextCalculator = self.allCalculators[key]!
        bottomWrapper.setNeedsLayout()
        nextCounter += 1
    }

    // Create a label as a test view
    private func createTestView(_ s: String, _ col: UIColor) -> UILabel {
        let view = UILabel()
        view.text = s
        view.backgroundColor = col
        view.textAlignment = .center
        view.numberOfLines = 0
        view.lineBreakMode = .byCharWrapping
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }
}

fileprivate extension SQLayoutView {
    @discardableResult
    @objc
    override func makeBorderless(color: UIColor) -> SQLayoutView {
        return super.makeBorderless(color: color) as! SQLayoutView
    }
}

fileprivate extension UIView {
    @discardableResult
    @objc
    func makeBorderless(color: UIColor) -> UIView {
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.clear
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
        return self
    }
}
