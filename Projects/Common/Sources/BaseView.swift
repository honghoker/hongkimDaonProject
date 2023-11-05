import UIKit

open class BaseView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addView()
        setLayout()
        setupView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func addView() {
        fatalError("Subclasses need to implement the `addView` method.")
    }
    open func setLayout() {
        fatalError("Subclasses need to implement the `setLayout` method.")
    }
    open func setupView() {
        fatalError("Subclasses need to implement the `setupView` method.")
    }
}
