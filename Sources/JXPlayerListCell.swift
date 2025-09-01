
import UIKit



open class JXPlayerListCell: UICollectionViewCell, JXPlayerCell {
    
    open var ControlViewClass: JXPlayerListControlView.Type {
        return JXPlayerListControlView.self
    }
    
    open var model: Any?
    
    weak open var viewModel: JXPlayerListViewModel? {
        didSet {
            self.controlView.viewModel = viewModel
        }
    }
    
    open var isCurrent: Bool = false {
        didSet {
            self.controlView.isCurrent = isCurrent
        }
    }
    
    open var durationTime: TimeInterval {
        return player.duration
    }
    
    open var currentTime: TimeInterval {
        return player.currentTime
    }
    
    open var rate: Float = 1 {
        didSet {
            self.player.rate = rate
        }
    }
    
    
    public lazy var controlView: JXPlayerListControlView = {
        let view = ControlViewClass.init()
        return view
    }()
    
    public lazy var player: JXPlayer = {
        let player = JXPlayer(controlView: self.controlView)
        player.playerView = self.playerView
        player.delegate = self
        
        return player
    }()
    
    public lazy var playerView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(playerView)
        playerView.frame = contentView.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open func start() {
        player.start()
    }
    
    open func pause() {
        player.pause()
    }
    
    open func stop() {
        player.stop()
    }
    
    open func replay() {
        player.replay()
    }
    
    open func seekTo(progress: Float) {
        let duration = self.durationTime
        let time = duration * TimeInterval(progress)
        self.player.seek(toTime: time)
    }
}

extension JXPlayerListCell: JXPlayerDelegate {
    
    open func jx_playerReadyToPlay(_ player: JXPlayer) {
        
    }
    ///更新当前总进度
    open func jx_playerDurationDidChange(_ player: JXPlayer, duration: TimeInterval) {
        self.controlView.durationTime = duration
    }
    ///更新当前进度
    open func jx_playerCurrentTimeDidChange(_ player: JXPlayer, time: TimeInterval) {
        self.controlView.currentTime = time
        self.viewModel?.playProgressDidChange(player: self, time: time)
    }
    
    ///播放完成
    open func jx_playerDidPlayFinish(_ player: JXPlayer) {
        self.viewModel?.playFinish(player: self)
    }
    
    ///调用了播放但是在缓冲中导致没有正常播放
    open func jx_playerInBufferToPlay(_ player: JXPlayer) {
        self.controlView.isLoading = true
    }
    
    ///调用了播放，缓冲完成正常播放
    open func jx_playerBufferingCompleted(_ player: JXPlayer) {
        self.controlView.isLoading = false
    }
    
}
