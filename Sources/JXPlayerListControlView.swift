

import UIKit
import SJVideoPlayer

@objc public protocol JXPlayerListControlViewDelegate {
    
    @objc optional func jx_playerListControlViewDidAppear(_ controlView: JXPlayerListControlView)
    
    @objc optional func jx_playerListControlViewDidDisappear(_ controlView: JXPlayerListControlView)
}

open class JXPlayerListControlView: UIView, JXPlayerControlViewProtocol {
    
    weak open var viewModel: JXPlayerListViewModel?
    
    weak var delegate: JXPlayerListControlViewDelegate?
    
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
        self.jx_controlLayerNeedAppear(self)
    }
    
    public func controlLayerNeedDisappear(_ videoPlayer: SJBaseVideoPlayer!) {
        self.jx_controlLayerNeedDisappear(self)
    }
    
    open func jx_controlLayerNeedAppear(_ controlView: JXPlayerListControlView) {
        self.isHidden = false
        self.delegate?.jx_playerListControlViewDidAppear?(self)
    }
    
    open func jx_controlLayerNeedDisappear(_ controlView: JXPlayerListControlView) {
        self.isHidden = true
        self.delegate?.jx_playerListControlViewDidDisappear?(self)
    }
}


