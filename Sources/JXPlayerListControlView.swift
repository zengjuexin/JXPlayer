

import UIKit

open class JXPlayerListControlView: UIView, JXPlayerControlView {
    
    public var isCurrent: Bool = false
    
    weak public var viewModel: JXPlayerListViewModel?
    
    public var durationTime: TimeInterval = 0
    public var currentTime: TimeInterval = 0
    ///加载中状态
    public var isLoading = false
    
    public func singleTapEvent() {
        
    }
}
