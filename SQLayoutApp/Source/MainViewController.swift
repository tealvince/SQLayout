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

        // vstack (container)
        "17 containerWidthVStack" : SQLayoutCalculators.containerWidthVStack,
        "18 containerLeftAlignedVStack" : SQLayoutCalculators.containerLeftAlignedVStack,
        "19 containerRightAlignedVStack" : SQLayoutCalculators.containerRightAlignedVStack,
        "20 containerCenterAlignedVStack" : SQLayoutCalculators.containerCenterAlignedVStack,
        "21 containerWidthVStackUp" : SQLayoutCalculators.containerWidthVStackUp,
        "22 containerLeftAlignedVStackUp" : SQLayoutCalculators.containerLeftAlignedVStackUp,
        "23 containerRightAlignedVStackUp" : SQLayoutCalculators.containerRightAlignedVStackUp,
        "24 containerCenterAlignedVStackUp" : SQLayoutCalculators.containerCenterAlignedVStackUp,

        // hstack (container)
        "25 containerHeightHStack" : SQLayoutCalculators.containerHeightHStack,
        "26 containerTopAlignedHStack" : SQLayoutCalculators.containerTopAlignedHStack,
        "27 containerBottomAlignedHStack" : SQLayoutCalculators.containerBottomAlignedHStack,
        "28 containerCenterAlignedHStack" : SQLayoutCalculators.containerCenterAlignedHStack,
        "29 containerHeightHStackLeft" : SQLayoutCalculators.containerHeightHStackLeft,
        "30 containerTopAlignedHStackLeft" : SQLayoutCalculators.containerTopAlignedHStackLeft,
        "31 containerBottomAlignedHStackLeft" : SQLayoutCalculators.containerBottomAlignedHStackLeft,
        "32 containerCenterAlignedHStackLeft" : SQLayoutCalculators.containerCenterAlignedHStackLeft,

        // flow
        "33 heightAlignedFlow" : SQLayoutCalculators.heightAlignedFlow,
        "34 topAlignedFlow" : SQLayoutCalculators.topAlignedFlow,
        "35 bottomAlignedFlow" : SQLayoutCalculators.bottomAlignedFlow,
        "36 centerAlignedFlow" : SQLayoutCalculators.centerAlignedFlow,
        "37 heightAlignedFlowLeft" : SQLayoutCalculators.heightAlignedFlowLeft,
        "38 topAlignedFlowLeft" : SQLayoutCalculators.topAlignedFlowLeft,
        "39 bottomAlignedFlowLeft" : SQLayoutCalculators.bottomAlignedFlowLeft,
        "40 centerAlignedFlowLeft" : SQLayoutCalculators.centerAlignedFlowLeft,

        // fill
        "41 heightAlignedFillToRight" : SQLayoutCalculators.heightAlignedFillToRight,
        "42 topAlignedFillToRight" : SQLayoutCalculators.topAlignedFillToRight,
        "43 bottomAlignedFillToRight" : SQLayoutCalculators.bottomAlignedFillToRight,
        "44 centerAlignedFillToRight" : SQLayoutCalculators.centerAlignedFillToRight,
        "45 heightAlignedFillToLeft" : SQLayoutCalculators.heightAlignedFillToLeft,
        "46 topAlignedFillToLeft" : SQLayoutCalculators.topAlignedFillToLeft,
        "47 bottomAlignedFillToLeft" : SQLayoutCalculators.bottomAlignedFillToLeft,
        "48 centerAlignedFillToLeft" : SQLayoutCalculators.centerAlignedFillToLeft,

        // in-previous
        "49 centerAligned" : SQLayoutCalculators.centerAligned,
        "50 topLeftAligned" : SQLayoutCalculators.topLeftAligned,
        "51 topRightAligned" : SQLayoutCalculators.topRightAligned,
        "52 bottomLeftAligned" : SQLayoutCalculators.bottomLeftAligned,
        "53 bottomRightAligned" : SQLayoutCalculators.bottomRightAligned,
        "54 widthTopAligned" : SQLayoutCalculators.widthTopAligned,
        "55 widthBottomAligned" : SQLayoutCalculators.widthBottomAligned,
        "56 widthCenterAligned" : SQLayoutCalculators.widthCenterAligned,
        "57 heightLeftAligned" : SQLayoutCalculators.heightLeftAligned,
        "58 heightRightAligned" : SQLayoutCalculators.heightRightAligned,
        "59 heightCenterAligned" : SQLayoutCalculators.heightCenterAligned,

        // between container/previous
        "60 containerLeftOfPrevious" : SQLayoutCalculators.containerLeftOfPrevious,
        "61 containerRightOfPrevious" : SQLayoutCalculators.containerRightOfPrevious,
        "62 containerAbovePrevious" : SQLayoutCalculators.containerAbovePrevious,
        "63 containerBelowPrevious" : SQLayoutCalculators.containerBelowPrevious,

        // in-container
        "64 containerCenterAligned" : SQLayoutCalculators.containerCenterAligned,
        "65 containerTopLeftAligned" : SQLayoutCalculators.containerTopLeftAligned,
        "66 containerTopRightAligned" : SQLayoutCalculators.containerTopRightAligned,
        "67 containerBottomLeftAligned" : SQLayoutCalculators.containerBottomLeftAligned,
        "68 containerBottomRightAligned" : SQLayoutCalculators.containerBottomRightAligned,
        "69 containerWidthTopAligned" : SQLayoutCalculators.containerWidthTopAligned,
        "70 containerWidthBottomAligned" : SQLayoutCalculators.containerWidthBottomAligned,
        "71 containerWidthCenterAligned" : SQLayoutCalculators.containerWidthCenterAligned,
        "72 containerHeightLeftAligned" : SQLayoutCalculators.containerHeightLeftAligned,
        "73 containerHeightRightAligned" : SQLayoutCalculators.containerHeightRightAligned,
        "74 containerHeightCenterAligned" : SQLayoutCalculators.containerHeightCenterAligned,

        // matching
        "75 matchPrevious" : SQLayoutCalculators.matchPrevious,
        "76 matchContainer" : SQLayoutCalculators.matchContainer,
        "77 matchContainerFullBleed" : SQLayoutCalculators.matchContainerFullBleed,
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black

        // Make some view that we'll need to reference directly
        let topWrapper = SQLayoutView(layoutInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            .makeBorderless(color: UIColor.white)
        let bottomWrapper = SQLayoutView(layoutInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)).makeBorderless(color: UIColor.white)
        let nextLabel = createTestView("", green.withAlphaComponent(0.85))
        let nextLabel2 = createTestView("", blue.withAlphaComponent(0.85))
        var nextCalculator = allCalculators[calculatorKeys.first!]!
        let nextSizeCalculator: SQSizeCalculator = { args in
            // cap width to it doesn't overflow off screen (we can always read the name)
            return SQLayoutCalculators.viewSizeCalculator(maxSize: CGSizeMake(args.container.layoutBounds.width/2 - (args.item.sq_rootItem == nextLabel ? 70 : 50), CGFloat.greatestFiniteMagnitude))(args)
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
                    .withSQFrameCalculator({ args in return nextCalculator(args)})
                    .withSQSizeCalculator(nextSizeCalculator)
                )
                .containingArrangedItem(nextLabel2
                    .withSQFrameCalculator({ args in
                        var rect = nextCalculator(args)
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
        var nextCounter = 0
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let key = self.calculatorKeys[nextCounter % self.calculatorKeys.count]
            nextLabel.text = key.components(separatedBy: " ")[1]
            nextLabel2.text = key.components(separatedBy: " ")[1]
            nextCalculator = self.allCalculators[key]!
            bottomWrapper.setNeedsLayout()
            nextCounter += 1
        }
        timer?.fire()
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
