//
//  Graph.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let verticalPercentGap: CGFloat = 0.1
}


public final class Graph: NSObject {
    
    // ******************************* MARK: - Public Properties
    
    public private(set) var plots: [Plot] = []
    
    public private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.isScrollEnabled = false
        
        return scrollView
    }()
    
    // ******************************* MARK: - Private Properties
    
    private var observer: NSKeyValueObservation!
    
    private var transformables: [Transformable] {
        return plots
    }
    
    // ******************************* MARK: - Initialization and Setup
    
    public override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        observer = scrollView.observe(\UIScrollView.bounds, options: [.old, .new]) { [weak self] scrollView, change in
            guard change.newValue != change.oldValue else { return }
            self?.configure()
        }
    }
    
    // ******************************* MARK: - Public Methods
    
    public func addPlot(_ plot: Plot) {
        plots.append(plot)
        scrollView.layer.addSublayer(plot.shapeLayer)
        configure()
    }
    
    public func removePlot(_ plot: Plot) {
        plot.shapeLayer.removeFromSuperlayer()
        plots.remove(plot)
        configure()
    }
    
    public func removeAllPlots() {
        plots.forEach(removePlot)
    }
    
    // ******************************* MARK: - Private Methods
    
    private func configure() {
        // Update content size
        scrollView.contentSize = scrollView.bounds.size
        
        // Scale X
        let maxCount = plots
            .map { $0.valuesCount }
            .max() ?? 1
        
        let scaleX: CGFloat = scrollView.bounds.width / CGFloat(maxCount)
        
        // Scale Y
        let minValue = plots
            .compactMap { $0.minValue }
            .min()?
            .asCGFloat ?? 0
        
        let maxValue = plots
            .compactMap { $0.maxValue }
            .max()?
            .asCGFloat ?? 1
        
        let range = maxValue - minValue
        let gap = scrollView.bounds.height * c.verticalPercentGap
        let availableHeight = scrollView.bounds.height - 2 * gap
        
        // Scale to show range with top and bottom paddings
        // and mirror graph so Y axis goes from bottom
        let scaleY: CGFloat = -(availableHeight / range)
        
        let transform = CGAffineTransform.identity
            .scaledBy(x: scaleX, y: scaleY)
            .translatedBy(x: 0, y: -minValue + (scrollView.bounds.height - gap) / scaleY)
        
        let animated = UIView.isInAnimationClosure

        transformables.forEach { $0.setTransform(transform, animated: animated) }
    }
}
