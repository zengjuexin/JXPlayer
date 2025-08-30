
import UIKit



class JXPlayerListCell: UICollectionViewCell, JXPlayerCell {
    
    var ControlViewClass: JXPlayerListControlView.Type {
        return JXPlayerListControlView.self
    }
    
    var model: Any?
    
    weak var viewModel: JXPlayerListViewModel? {
        didSet {
            self.controlView.viewModel = viewModel
        }
    }
    
    var isCurrent: Bool = false {
        didSet {
            self.controlView.isCurrent = isCurrent
        }
    }
    
    var durationTime: TimeInterval {
        return player.duration
    }
    
    var currentTime: TimeInterval {
        return player.currentTime
    }
    
    var rate: Float = 1 {
        didSet {
            self.player.rate = rate
        }
    }
    
    
    private lazy var controlView: JXPlayerListControlView = {
        let view = ControlViewClass.init()
        return view
    }()
    
    private(set) lazy var player: JXPlayer = {
        let player = JXPlayer(controlView: self.controlView)
        player.playerView = self.playerView
        player.delegate = self
        
        return player
    }()
    
    private(set) lazy var playerView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(playerView)
        playerView.frame = contentView.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func start() {
        player.start()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.stop()
    }
    
    func replay() {
        player.replay()
    }
    
    func seekTo(progress: Float) {
        let duration = self.durationTime
        let time = duration * TimeInterval(progress)
        self.player.seek(toTime: time)
    }
}

extension JXPlayerListCell: JXPlayerDelegate {
    
    func jx_playerReadyToPlay(_ player: JXPlayer) {
        
    }
    ///更新当前总进度
    func jx_playerDurationDidChange(_ player: JXPlayer, duration: TimeInterval) {
        self.controlView.durationTime = duration
    }
    ///更新当前进度
    func jx_playerCurrentTimeDidChange(_ player: JXPlayer, time: TimeInterval) {
        self.controlView.currentTime = time
        self.viewModel?.playProgressDidChange(player: self, time: time)
    }
    
    ///播放完成
    func jx_playerDidPlayFinish(_ player: JXPlayer) {
        self.viewModel?.playFinish(player: self)
    }
    
    ///调用了播放但是在缓冲中导致没有正常播放
    func jx_playerInBufferToPlay(_ player: JXPlayer) {
        self.controlView.isLoading = true
    }
    
    ///调用了播放，缓冲完成正常播放
    func jx_playerBufferingCompleted(_ player: JXPlayer) {
        self.controlView.isLoading = false
    }
    
}
