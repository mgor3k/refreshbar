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
            animateToRight()
        default:
            if case .loading = oldState {
                UIView.animate(withDuration: duration, animations: updateFrames)
            } else {
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
    
    func animateToRight() {
        UIView.animate(withDuration: duration, animations: {
            self.progressView.frame = CGRect(
                x: self.frame.width - self.loadingWidth,
                y: 0,
                width: self.loadingWidth,
                height: self.frame.height
            )
        }, completion: { [weak self] _ in
            guard case .loading = self?.state else { return }
            self?.animateToLeft()
        })
    }
    
    func animateToLeft() {
        UIView.animate(withDuration: duration, animations: {
            self.progressView.frame = CGRect(
                x: 0,
                y: 0,
                width: self.loadingWidth,
                height: self.frame.height
            )
        }, completion: { [weak self] _ in
            guard case .loading = self?.state else { return }
            self?.animateToRight()
        })
    }
}

private func lerp<T: FloatingPoint>(start: T, end: T, progress: T) -> T {
    return (1 - progress) * start + progress * end
}

#endif
