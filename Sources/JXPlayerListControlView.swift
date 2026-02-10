

import UIKit
import SJVideoPlayer

open class JXPlayerListControlView: UIView, JXPlayerControlViewProtocol {
    
    weak open var viewModel: JXPlayerListViewModel?
    
    open var model: Any?
    
    open var isCurrent: Bool = false
    
    open var durationTime: TimeInterval = 0
    open var currentTime: TimeInterval = 0
    ///加载中状态
    open var isLoading = false
    
    open func singleTapEvent() {
        
    }
    
    public func controlView() -> UIView! {
        return self
    }
    
    
    public func installedControlView(to videoPlayer: SJBaseVideoPlayer!) {
        
    }
    
    public func controlLayerNeedAppear(_ videoPlayer: SJBaseVideoPlayer!) {
        self.isHidden = false
    }
    
    public func controlLayerNeedDisappear(_ videoPlayer: SJBaseVideoPlayer!) {
        self.isHidden = true
    }
}


