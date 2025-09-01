

import UIKit

open class JXPlayerListViewModel: NSObject {
    
    weak public var playerListVC: JXPlayerListViewController?
    
    public var currentCell: JXPlayerCell? {
        didSet {
            oldValue?.isCurrent = false
            oldValue?.pause()
            
            self.currentCell?.isCurrent = true
        }
    }
    
    @objc public dynamic var isPlaying: Bool = true
    
    public var currentIndexPath = IndexPath(row: 0, section: 0)
    
    
}

extension JXPlayerListViewModel {
    
    ///播放进度变化
    @objc public func playProgressDidChange(player: JXPlayerCell, time: TimeInterval) { }
    
    ///播放完成
    @objc public func playFinish(player: JXPlayerCell) { }
    
}
