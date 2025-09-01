
import UIKit


@objc public protocol JXPlayerCell: NSObjectProtocol {
    
    var model: Any? { get set }
    
    var isCurrent: Bool { get set }
    
    
    var durationTime: TimeInterval { get }
    var currentTime: TimeInterval { get }
    
    var rate: Float { get set }
    
    
    ///开始播放
    func start()
    
    ///暂停播放
    func pause()
    
    ///停止播放
    func stop()
    
    ///从头播放
    func replay()
    
    ///设置进度
    func seekTo(progress: Float)
    
    
}
