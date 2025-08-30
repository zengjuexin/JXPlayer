

import UIKit

class JXPlayerListViewModel: NSObject {
    
    weak var playerListVC: JXPlayerListViewController?
    
    var currentCell: JXPlayerCell? {
        didSet {
            oldValue?.isCurrent = false
            oldValue?.pause()
            
            self.currentCell?.isCurrent = true
        }
    }
    
    @objc dynamic var isPlaying: Bool = true
    
    var currentIndexPath = IndexPath(row: 0, section: 0)
    
    
}

extension JXPlayerListViewModel {
    
    ///播放进度变化
    @objc func playProgressDidChange(player: JXPlayerCell, time: TimeInterval) { }
    
    ///播放完成
    @objc func playFinish(player: JXPlayerCell) { }
    
}
