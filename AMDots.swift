//
//  AMDots.swift
//  AMDots
//
//  Created by abedalkareem omreyh on 5/1/18.
//  Copyright © 2018 abedalkareem omreyh. All rights reserved.
//

import UIKit

@IBDesignable
class AMDots: UIView {

    private var dotsViews = [UIView]()
    private var defaultsColors = [#colorLiteral(red: 0.2352941176, green: 0.7294117647, blue: 0.3294117647, alpha: 1),#colorLiteral(red: 0.9568627451, green: 0.7607843137, blue: 0.05098039216, alpha: 1),#colorLiteral(red: 0.8588235294, green: 0.1960784314, blue: 0.2117647059, alpha: 1),#colorLiteral(red: 0.2823529412, green: 0.5215686275, blue: 0.9294117647, alpha: 1)]
    private var currentViewIndex = 0
    private var isStoped = false
    
    /// Size of the dot, the default is calculated from the view `width`,
    /// E.g: if you have `4` dots and the view width is `400`, each one will be `100` `(400/4)`
    @IBInspectable var dotSize: CGFloat = 0
    /// Space between each dot, the default is `10`
    @IBInspectable var spacing: CGFloat = 10
    /// Animation duration for each dot it should be more than `0.1`, the default is `0.7`
    @IBInspectable var animationDuration: CGFloat = 0.4
    
    /// The negative time you need the animation to run before the prevuse animation finish
    /// (If you set it for 0.2, the next animation will run before 0.2 second before the current animation finish).
    /// the default value is `0.2`.
    @IBInspectable var aheadTime: CGFloat = 0.2
    /// Animation type, do you want the dot to `jump`, `scale` or `shake`
    var animationType: AnimationType = .scale
    /// A Boolean value that controls whether the must be hidden when the animation is stopped.
    @IBInspectable var hidesWhenStopped: Bool = true

    /// The circles `color`, the number of dots will be the same as the number of colors,
    /// so if you have 3 colors, you will have 3 dots.
    ///
    /// Note: you should set the colors before add the view to super view.
    var colors = [UIColor]()

    
    // MARK: - init
    init(frame: CGRect, colors: [UIColor]? = nil) {
        super.init(frame: frame)
        self.colors = colors ?? defaultsColors
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        colors = defaultsColors
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        colors = defaultsColors
    }
    
    // MARK: - draw
    override func draw(_ rect: CGRect) {
        
        drawTheDots()
        
        #if !TARGET_INTERFACE_BUILDER
        startAnimation()
        #endif
    }
    
    func drawTheDots() {
        
        if dotSize == 0 {
            let width = frame.size.width - (CGFloat(colors.count-1)*spacing)
            dotSize = (width / CGFloat(colors.count))
        }

        for (index,color) in colors.enumerated() {
            let view = UIView(frame: CGRect(x: ((spacing + dotSize) * CGFloat(index)), y: (frame.height/2) - (dotSize/2) , width: dotSize, height: dotSize))
            view.backgroundColor = color
            view.layer.cornerRadius = dotSize/2
            addSubview(view)
        }
    }
    
    
    // MARK: - Animation
    private func startAnimation() {
        
        guard !isStoped else {
            return
        }
        
        if currentViewIndex >= subviews.count {
            currentViewIndex = 0
        }
        
        switch animationType {
        case .scale:
            scaleAnimation()
        case .jump:
            moveAnimation()
        case .shake:
            moveAnimation()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(animationDuration-aheadTime)) { [weak self] in
            self?.currentViewIndex+=1
            self?.startAnimation()
        }
    }
    
    private func scaleAnimation() {
        let view = subviews[currentViewIndex]
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, options: [.autoreverse], animations: { [weak view] in
            view?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { [weak view] (finished) in
            view?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    private func moveAnimation() {
        let view = subviews[currentViewIndex]
        let orginalFrame = view.frame
        var newFrame = orginalFrame
        if animationType == .jump {
            newFrame.origin.y += dotSize/2
        } else {
            newFrame.origin.x -= dotSize/2
        }
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, options: [.autoreverse], animations: { [weak view,newFrame] in
            view?.frame = newFrame
        }) { [weak view,orginalFrame] (finished) in
            view?.frame = orginalFrame
        }
    }
 
    
    // MARK: - Public Functions (Stop/Start)
    /// Use it to start the animation for the AMDots
    func start() {
        
        guard isStoped else {
            return
        }
        
        guard colors.count != 0 else {
            fatalError("There is a problem, Is the AMDot view already start? or maybe you are trying to start it before you add the AMDot view to the view controller!")
        }
        isHidden = false
        isStoped = false
        startAnimation()
    }
    
    /// Use it to stop the animation for the AMDots
    func stop() {
        isStoped = true
        if hidesWhenStopped {
            isHidden = true
        }
    }

}

enum AnimationType {
    case jump
    case scale
    case shake
}

