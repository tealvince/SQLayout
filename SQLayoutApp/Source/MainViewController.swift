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
        // matching
        "1 matchContainer" : SQLayoutCalculators.matchContainer,
        "2 matchContainerFullBleed" : SQLayoutCalculators.matchContainerFullBleed,
        "3 matchPrevious" : SQLayoutCalculators.matchPrevious,

        // in-container
        "4 containerCenterAligned" : SQLayoutCalculators.containerCenterAligned,
        "5 containerTopLeftAligned" : SQLayoutCalculators.containerTopLeftAligned,
        "6 containerTopRightAligned" : SQLayoutCalculators.containerTopRightAligned,
        "7 containerBottomLeftAligned" : SQLayoutCalculators.containerBottomLeftAligned,
        "8 containerBottomRightAligned" : SQLayoutCalculators.containerBottomRightAligned,
        "9 containerWidthTopAligned" : SQLayoutCalculators.containerWidthTopAligned,
        "10 containerWidthBottomAligned" : SQLayoutCalculators.containerWidthBottomAligned,
        "11 containerWidthCenterAligned" : SQLayoutCalculators.containerWidthCenterAligned,
        "12 containerHeightLeftAligned" : SQLayoutCalculators.containerHeightLeftAligned,
        "13 containerHeightRightAligned" : SQLayoutCalculators.containerHeightRightAligned,
        "14 containerHeightCenterAligned" : SQLayoutCalculators.containerHeightCenterAligned,

        // in-previous
        "15 centerAligned" : SQLayoutCalculators.centerAligned,
        "16 topLeftAligned" : SQLayoutCalculators.topLeftAligned,
        "17 topRightAligned" : SQLayoutCalculators.topRightAligned,
        "18 bottomLeftAligned" : SQLayoutCalculators.bottomLeftAligned,
        "19 bottomRightAligned" : SQLayoutCalculators.bottomRightAligned,
        "20 widthTopAligned" : SQLayoutCalculators.widthTopAligned,
        "21 widthBottomAligned" : SQLayoutCalculators.widthBottomAligned,
        "22 widthCenterAligned" : SQLayoutCalculators.widthCenterAligned,
        "23 heightLeftAligned" : SQLayoutCalculators.heightLeftAligned,
        "24 heightRightAligned" : SQLayoutCalculators.heightRightAligned,
        "25 heightCenterAligned" : SQLayoutCalculators.heightCenterAligned,

        // vstack (container)
        "26 containerLeftAlignedVStack" : SQLayoutCalculators.containerLeftAlignedVStack,
        "27 containerLeftAlignedVStackUp" : SQLayoutCalculators.containerLeftAlignedVStackUp,
        "28 containerRightAlignedVStack" : SQLayoutCalculators.containerRightAlignedVStack,
        "29 containerRightAlignedVStackUp" : SQLayoutCalculators.containerRightAlignedVStackUp,
        "30 containerCenterAlignedVStack" : SQLayoutCalculators.containerCenterAlignedVStack,
        "31 containerCenterAlignedVStackUp" : SQLayoutCalculators.containerCenterAlignedVStackUp,
        "32 containerWidthVStack" : SQLayoutCalculators.containerWidthVStack,
        "33 containerWidthVStackUp" : SQLayoutCalculators.containerWidthVStackUp,

        // vstack (previous)
        "34 leftAlignedVStack" : SQLayoutCalculators.leftAlignedVStack,
        "35 leftAlignedVStackUp" : SQLayoutCalculators.leftAlignedVStackUp,
        "36 rightAlignedVStack" : SQLayoutCalculators.rightAlignedVStack,
        "37 rightAlignedVStackUp" : SQLayoutCalculators.rightAlignedVStackUp,
        "38 centerAlignedVStack" : SQLayoutCalculators.centerAlignedVStack,
        "39 centerAlignedVStackUp" : SQLayoutCalculators.centerAlignedVStackUp,
        "40 widthAlignedVStack" : SQLayoutCalculators.widthAlignedVStack,
        "41 widthAlignedVStackUp" : SQLayoutCalculators.widthAlignedVStackUp,

        // hstack (container)
        "42 containerTopAlignedHStack" : SQLayoutCalculators.containerTopAlignedHStack,
        "43 containerTopAlignedHStackLeft" : SQLayoutCalculators.containerTopAlignedHStackLeft,
        "44 containerBottomAlignedHStack" : SQLayoutCalculators.containerBottomAlignedHStack,
        "45 containerBottomAlignedHStackLeft" : SQLayoutCalculators.containerBottomAlignedHStackLeft,
        "46 containerCenterAlignedHStack" : SQLayoutCalculators.containerCenterAlignedHStack,
        "47 containerCenterAlignedHStackLeft" : SQLayoutCalculators.containerCenterAlignedHStackLeft,
        "48 containerHeightHStack" : SQLayoutCalculators.containerHeightHStack,
        "49 containerHeightHStackLeft" : SQLayoutCalculators.containerHeightHStackLeft,

        // hstack (previous)
        "50 topAlignedHStack" : SQLayoutCalculators.topAlignedHStack,
        "51 topAlignedHStackLeft" : SQLayoutCalculators.topAlignedHStackLeft,
        "52 bottomAlignedHStack" : SQLayoutCalculators.bottomAlignedHStack,
        "53 bottomAlignedHStackLeft" : SQLayoutCalculators.bottomAlignedHStackLeft,
        "54 centerAlignedHStack" : SQLayoutCalculators.centerAlignedHStack,
        "55 centerAlignedHStackLeft" : SQLayoutCalculators.centerAlignedHStackLeft,
        "56 heightAlignedHStack" : SQLayoutCalculators.heightAlignedHStack,
        "57 heightAlignedHStackLeft" : SQLayoutCalculators.heightAlignedHStackLeft,

        // fill
        "58 topAlignedFillToRight" : SQLayoutCalculators.topAlignedFillToRight,
        "59 topAlignedFillToLeft" : SQLayoutCalculators.topAlignedFillToLeft,
        "60 bottomAlignedFillToRight" : SQLayoutCalculators.bottomAlignedFillToRight,
        "61 bottomAlignedFillToLeft" : SQLayoutCalculators.bottomAlignedFillToLeft,
        "62 centerAlignedFillToRight" : SQLayoutCalculators.centerAlignedFillToRight,
        "63 centerAlignedFillToLeft" : SQLayoutCalculators.centerAlignedFillToLeft,
        "64 heightAlignedFillToRight" : SQLayoutCalculators.heightAlignedFillToRight,
        "65 heightAlignedFillToLeft" : SQLayoutCalculators.heightAlignedFillToLeft,

        // flow
        "66 topAlignedFlow" : SQLayoutCalculators.topAlignedFlow,
        "67 bottomAlignedFlow" : SQLayoutCalculators.bottomAlignedFlow,
        "68 centerAlignedFlow" : SQLayoutCalculators.centerAlignedFlow,
        "69 heightAlignedFlow" : SQLayoutCalculators.heightAlignedFlow,

        // between container/previous
        "70 containerLeftOfPrevious" : SQLayoutCalculators.containerLeftOfPrevious,
        "71 containerRightOfPrevious" : SQLayoutCalculators.containerRightOfPrevious,
        "72 containerAbovePrevious" : SQLayoutCalculators.containerAbovePrevious,
        "73 containerBelowPrevious" : SQLayoutCalculators.containerBelowPrevious,
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
        let nextLabel = createTestView("", blue.withAlphaComponent(0.85))
        var nextCalculator = allCalculators[calculatorKeys.first!]!

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
                    .withSQSpacing(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
                )
                // Dynamic "next" object
                .containingArrangedItem(nextLabel
                    .withSQFrameCalculator({ args in
                        return nextCalculator(args)
                    })
                    // cap width to it doesn't overflow off screen (we can always read the name)
                    .withSQSizeCalculator({ args in
                        return SQLayoutCalculators.viewSizeCalculator(maxSize: CGSizeMake(args.container.layoutBounds.width/2-10, CGFloat.greatestFiniteMagnitude))(args)
                    })
                )
                .withSQFrameCalculator(SQLayoutCalculators.containerBelowPrevious)
                .withSQSpacing(UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
            )

        //
        // Set a timer that increments the calculator used by the "next" item every two seconds
        //
        var nextCounter = 0
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            nextCounter += 1
            let key = self.calculatorKeys[nextCounter % self.calculatorKeys.count]
            nextLabel.text = key.components(separatedBy: " ")[1]
            nextCalculator = self.allCalculators[key]!
            bottomWrapper.setNeedsLayout()
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
