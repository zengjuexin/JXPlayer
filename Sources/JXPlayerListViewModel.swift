

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
    
    
}

extension JXPlayerListViewModel {
    
    ///播放进度变化
    @objc open func playProgressDidChange(player: JXPlayerCell, time: TimeInterval) { }
    
    ///播放完成
    @objc open func playFinish(player: JXPlayerCell) { }
    
}
