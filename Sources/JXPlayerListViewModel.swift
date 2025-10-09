

import UIKit

open class JXPlayerListViewModel: NSObject {
    
    weak public var playerListVC: JXPlayerListViewController?
    
    open var currentCell: JXPlayerCell? {
        didSet {
            oldValue?.isCurrent = false
            oldValue?.pause()
            
            self.currentCell?.isCurrent = true
        }
    }
    
    @objc open dynamic var isPlaying: Bool = true
    
    open var currentIndexPath = IndexPath(row: 0, section: 0)
    
    required public override init() {
        
    }
    
    @objc open func seekTo(_ progress: Float) {
        self.currentCell?.seekTo(progress: progress)
    }
    
    ///切换播放暂停
    open func userSwitchPlayAndPause() {
        if self.isPlaying {
            self.playerListVC?.pause()
        } else {
            self.playerListVC?.play()
        }
    }
    
}

extension JXPlayerListViewModel {
    
    ///播放进度变化
    @objc open func playProgressDidChange(player: JXPlayerCell, time: TimeInterval) { }
    
    ///播放完成
    @objc open func playFinish(player: JXPlayerCell) {
        var isScroll = true
        
        if let result = self.playerListVC?.allowAutoScrollNextEpisode() {
            isScroll = result
        }
        if isScroll {
            self.playerListVC?.scrollToNextEpisode()
        } else {
            self.currentCell?.replay()
        }
    }
    
}
