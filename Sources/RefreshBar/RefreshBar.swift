#if canImport(UIKit)

import UIKit

public class RefreshBar: UIView {
    public enum State: Equatable {
        case progress(CGFloat)
        case loading
    }
    
    public var state = State.progress(1) {
        didSet {
            guard state != oldValue else { return }
            updateState(from: oldValue)
        }
    }
    
    private let progressView = UIView()
    
    public var loadingWidth: CGFloat = 15
    public var duration: TimeInterval = 0.5
    
    private var loadingAnimator: UIViewPropertyAnimator?
    private var stateChangeAnimator: UIViewPropertyAnimator?
    
    public init() {
        super.init(frame: .zero)
        addSubview(progressView)
        backgroundColor = #colorLiteral(red: 0.8, green: 0.7960784314, blue: 0.7960784314, alpha: 1)
        tintColor = #colorLiteral(red: 0.2705882353, green: 0.5607843137, blue: 0.8980392157, alpha: 1)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        progressView.layer.cornerRadius = frame.height / 2
        updateFrames()
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        progressView.backgroundColor = tintColor
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: 100, height: 6)
    }
    
}

private extension RefreshBar {
    func updateState(from oldState: State) {
        switch state {
        case .loading:
            animate()
        default:
            if case .loading = oldState {
                loadingAnimator?.stopAnimation(true)
                stateChangeAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
                    self.updateFrames()
                }
                stateChangeAnimator?.startAnimation()
            } else {
                if stateChangeAnimator?.isRunning == true {
                    stateChangeAnimator?.addCompletion { [weak self] _ in
                        self?.updateFrames()
                    }
                    return
                }
                updateFrames()
            }
        }
    }
    
    func updateFrames() {
        guard case .progress(let progress) = state else { return }
        let size = CGSize(
            width: lerp(start: frame.height, end: frame.width, progress: progress),
            height: frame.height
        )
        progressView.frame = CGRect(origin: .zero, size: size)
    }
    
    func animate(reversed: Bool = false) {
        loadingAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            self.progressView.frame = CGRect(
                x: reversed ? 0 : self.frame.width - self.loadingWidth,
                y: 0,
                width: self.loadingWidth,
                height: self.frame.height
            )
        }
        
        loadingAnimator?.addCompletion { [weak self] _ in
            self?.animate(reversed: !reversed)
        }
        
        loadingAnimator?.startAnimation()
    }
}

private func lerp<T: FloatingPoint>(start: T, end: T, progress: T) -> T {
    return (1 - progress) * start + progress * end
}

#endif
