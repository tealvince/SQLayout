//
//  MainViewController.swift
//  SQLayout
//
//  Created by Vince Lee on 2/5/23.
//

import SQLayout
import UIKit

class MainViewController: UIViewController {
    var timer: Timer?

    // Create a label as a test view
    private func testView(_ s: String, _ col: UIColor) -> UILabel {
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
        self.view.backgroundColor = UIColor.white

        // Create and add content view
        let contentView = SQLayoutView.autosizedView(addedTo: view, layoutGuide: view.safeAreaLayoutGuide, layoutInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))

        // Create title label
        let titleLabel = UILabel()
        titleLabel.text = "SQLayout Test"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)

        // Add as sequential layout item (defaults to left-aligned vstack layout)
        contentView.addArrangedItem(titleLabel)

        // Create wrapper
        let wrapper = SQLayoutView(layoutInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        wrapper.layer.cornerRadius = 10
        wrapper.backgroundColor = UIColor.lightGray
        
        // Add as auto-sized nested layout wrapper view
        // Fill it with a bunch of arranged views to test various layout calculators
        // Each line simply adds a test view, decorating it with any calculators to
        // define/customize its layout
        contentView.addArrangedItem(wrapper
            // Define arranged views here, chaining them for syntactic sugar (could also just add them individually)
            .containingArrangedItem(testView("container-center", UIColor.orange)
                .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
            )
            .containingArrangedItem(testView("right-aligned", UIColor.cyan)
                .withSQFrameCalculator(SQLayoutCalculators.rightAlignedVStack)
            )
            .containingArrangedItem(testView("left-aligned", UIColor.cyan)
                .withSQFrameCalculator(SQLayoutCalculators.leftAlignedVStack)
            )
            .containingArrangedItem(testView("center", UIColor.cyan)
                .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStack)
            )
            .containingArrangedItem(testView("container-right-aligned", UIColor.orange)
                .withSQFrameCalculator(SQLayoutCalculators.containerRightAlignedVStack)
            )
            .containingArrangedItem(testView("container-left-aligned", UIColor.orange)
                .withSQFrameCalculator(SQLayoutCalculators.containerLeftAlignedVStack)
            )
            .containingArrangedItem(testView("container-center", UIColor.orange)
                .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
            )
            .containingArrangedItem(testView("container full width", UIColor.orange)
                .withSQFrameCalculator(SQLayoutCalculators.containerWidthVStack)
            )
            .containingArrangedItem(testView("flow short", UIColor.green)
                .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
            )
            .containingArrangedItem(testView("flow longer", UIColor.green)
                .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
            )
            .containingArrangedItem(testView("flow longest", UIColor.green)
                .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
            )

            // Content spacing examples
            .containingArrangedItem(testView("flow middle", UIColor.green)
                .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
                .withSQSpacing(UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0))
            )
            .containingArrangedItem(testView("hub", UIColor.yellow)
                .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
                .withSQSpacing(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
            )

            // NoPrevious option examples
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStackUp)
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStack)
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator(SQLayoutCalculators.centerAlignedHStack)
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator(SQLayoutCalculators.centerAlignedHStackLeft)
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )

            // Frame calculator composition examples
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStackUp(args), -40, 10) }
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStackUp(args), 40, 10) }
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStack(args), -40, -10) }
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStack(args), 40, -10) }
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
                .containingArrangedItem(testView("bottom-left", UIColor.cyan)
                .withSQFrameCalculator(SQLayoutCalculators.containerBottomLeftAligned)
                .withSQLayoutOptions(SQLayoutOptions(shouldIgnoreWhenCalculatingSize: true))
            )
            .containingArrangedItem(testView("bottom-right", UIColor.cyan)
                .withSQFrameCalculator(SQLayoutCalculators.containerBottomRightAligned)
                .withSQLayoutOptions(SQLayoutOptions(shouldIgnoreWhenCalculatingSize: true))
            )
            // Add decorators for our wrapper view (must come after
            // addArrangedItem calls because it doesn't return a layoutView
            .withSQFrameCalculator(SQLayoutCalculators.containerWidthVStack)
        )

        let allCalculators = [
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
        let calculatorKeys = allCalculators.keys.sorted { Int($0.components(separatedBy: " ")[0])! < Int($1.components(separatedBy: " ")[0])! }

        // Add a slideshow cycling through calculators
        let slideshow = SQLayoutView(layoutInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        slideshow.layer.cornerRadius = 10
        slideshow.backgroundColor = UIColor.lightGray

        let nextLabel = testView(calculatorKeys[0], UIColor.green)
        var nextCalculator = allCalculators[calculatorKeys[0]]!
        var nextCounter = 0

        let border = UIView()
        border.backgroundColor = UIColor.clear
        border.layer.borderWidth = 1
        border.layer.borderColor = UIColor.darkGray.cgColor

        contentView.addArrangedItem(slideshow
            .containingArrangedItem(border
                .withSQFrameCalculator(SQLayoutCalculators.matchContainer(_:))
            )
            .containingArrangedItem(testView("prev", UIColor.white)
                .withSQFrameCalculator(SQLayoutCalculators.containerCenterAligned)
                .withSQSize(CGSizeMake(50, 50))
                .withSQSpacing(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
            )
            .containingArrangedItem(nextLabel
                .withSQFrameCalculator({ args in
                    return nextCalculator(args)
                })
                .withSQSizeCalculator({ args in
                    // cap width so we can always read name
                    guard let view = args.item.sq_rootItem as? UIView else { return .zero }
                    return view.sizeThatFits(CGSizeMake(min(args.container.layoutBounds.width/2-10,args.fittingSize.width), args.fittingSize.height))
                })
            )
            .withSQFrameCalculator(SQLayoutCalculators.containerBelowPrevious)
            .withSQSpacing(UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
        )

        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            nextCounter += 1
            let key = calculatorKeys[nextCounter % calculatorKeys.count]
            nextLabel.text = key.components(separatedBy: " ")[1]
            nextCalculator = allCalculators[key]!
            slideshow.setNeedsLayout()
        }
        timer?.fire()

    }

}

