

import UIKit

open class JXPlayerListControlView: UIView, JXPlayerControlView {
    
    weak open var viewModel: JXPlayerListViewModel?
    
    open var model: Any?
    
    open var isCurrent: Bool = false
    
    open var durationTime: TimeInterval = 0
    open var currentTime: TimeInterval = 0
    ///加载中状态
    open var isLoading = false
    
    open func singleTapEvent() {
        
    }
}
