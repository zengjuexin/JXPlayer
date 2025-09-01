

import UIKit

open class JXPlayerListControlView: UIView, JXPlayerControlView {
    
    open var isCurrent: Bool = false
    
    weak open var viewModel: JXPlayerListViewModel?
    
    open var durationTime: TimeInterval = 0
    open var currentTime: TimeInterval = 0
    ///加载中状态
    open var isLoading = false
    
    open func singleTapEvent() {
        
    }
}
