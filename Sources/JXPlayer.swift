
import UIKit
import SJVideoPlayer
import SJMediaCacheServer


public protocol JXPlayerControlView: NSObjectProtocol {
    var isCurrent: Bool { get set }
    func singleTapEvent()
}

@objc public protocol JXPlayerDelegate: NSObjectProtocol {
    
    @objc optional func jx_playerReadyToPlay(_ player: JXPlayer)
    ///更新当前总进度
    @objc optional func jx_playerDurationDidChange(_ player: JXPlayer, duration: TimeInterval)
    ///更新当前进度
    @objc optional func jx_playerCurrentTimeDidChange(_ player: JXPlayer, time: TimeInterval)
    
    ///播放完成
    @objc optional func jx_playerDidPlayFinish(_ player: JXPlayer)
    
    ///调用了播放但是在缓冲中导致没有正常播放
    @objc optional func jx_playerInBufferToPlay(_ player: JXPlayer)
    
    ///调用了播放，缓冲完成正常播放
    @objc optional func jx_playerBufferingCompleted(_ player: JXPlayer)
}

open class JXPlayer: NSObject {
    
    private(set) var isPlaying = false
    
    public lazy var player: SJBaseVideoPlayer = {
        let player = SJBaseVideoPlayer()
        player.delayInSecondsForHiddenPlaceholderImageView = 0
        player.autoplayWhenSetNewAsset = false
        player.resumePlaybackWhenAppDidEnterForeground = false
        player.accurateSeeking = true
        player.videoGravity = .resizeAspectFill
        player.rotationManager?.isDisabledAutorotation = true
        player.controlLayerDataSource = self
        player.resumePlaybackWhenPlayerHasFinishedSeeking = false
        player.pausedToKeepAppearState = true
        return player
    }()
    
    public weak var delegate: JXPlayerDelegate?
    
    public weak var playerView: UIView? {
        didSet {
            playerView?.addSubview(player.view)
            player.view.frame = playerView?.bounds ?? .zero
            player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }

    private(set) weak var jx_controlView: JXPlayerControlView?
    ///控制层自动隐藏
    public var controlAutomaticallyDisappear = true
    
    public var coverImageView: UIImageView? {
        return self.player.presentView.placeholderImageView
    }
    
    public var isLoop = false
    
    ///精确到秒
    public var duration: TimeInterval {
        return self.player.duration
    }
    
    public var currentTime: TimeInterval {
        return self.player.currentTime
    }
    
    public var rate: Float {
        get {
            return self.player.rate
        }
        set {
            self.player.rate = newValue
        }
    }
    
    public init(controlView: JXPlayerControlView?) {
        super.init()
        self.jx_controlView = controlView
        self.controlLayerNeedAppear()
        
        setupPlayer()
    }
    
    public func setPlayUrl(url: String) {
        self.stop()
        guard let url = URL(string: url) else { return }
        guard let proxyUrl = SJMediaCacheServer.shared().proxyURL(from: url) else { return }
        
        let asset = SJVideoPlayerURLAsset(url: proxyUrl)
        self.player.urlAsset = asset
    }
    
    public func start() {
        self.isPlaying = true
        self.player.play()
    }
    
    public func pause() {
        self.isPlaying = false
        self.player.pause()
    }
    
    public func stop() {
        self.isPlaying = false
        self.player.stop()
    }
    
    public func replay() {
        player.replay()
    }
    
    public func seek(toTime: TimeInterval) {
        self.player.seek(toTime: toTime)
    }
    ///显示控制层
    public func controlLayerNeedAppear() {
        self.player.controlLayerNeedAppear()
    }
    ///隐藏控制层
    public func controlLayerNeedDisappear() {
        self.player.controlLayerNeedDisappear()
    }
}

extension JXPlayer {
    
    private func setupPlayer() {
        //设置支持的手势
        self.player.gestureController.supportedGestureTypes = .singleTap
        self.player.gestureController.singleTapHandler = { [weak self] _, _ in
            guard let self = self else { return }
            if self.controlView()?.isHidden == true {
                self.controlLayerNeedAppear()
            } else {
                self.jx_controlView?.singleTapEvent()
            }
        }
        
        player.canAutomaticallyDisappear = { [weak self] player in
            return self?.controlAutomaticallyDisappear ?? false
        }
        
        //控制层显示状态改变
        player.controlLayerAppearObserver.onAppearChanged = { [weak self] manager in
            guard let self = self else { return }
            self.controlView()?.isHidden = !self.player.isControlLayerAppeared
        }
        
        //播放完成回调
        self.player.playbackObserver.playbackDidFinishExeBlock = { [weak self] player in
            guard let self = self else { return }
            if self.isLoop {
                self.replay()
            } else {
                self.delegate?.jx_playerDidPlayFinish?(self)
            }
        }
        //播放状态改变
//        self.player.playbackObserver.playbackStatusDidChangeExeBlock = { [weak self] player in
//            guard let self = self else { return }
//
//        }
        //播放控制改变的回调
        self.player.playbackObserver.timeControlStatusDidChangeExeBlock = { [weak self] player in
            guard let self = self else { return }
            if player.timeControlStatus == .waitingToPlay {//缓冲中
                self.delegate?.jx_playerInBufferToPlay?(self)
            } else if player.timeControlStatus == .playing {
                self.delegate?.jx_playerBufferingCompleted?(self)
            }
        }
        
        self.player.playbackObserver.assetStatusDidChangeExeBlock = { [weak self] player in
            guard let self = self else { return }
            if player.assetStatus == .readyToPlay {
                self.delegate?.jx_playerReadyToPlay?(self)
            }
        }
        
        //播放时长改变
        self.player.playbackObserver.durationDidChangeExeBlock = { [weak self] player in
            guard let self = self else { return }
            self.delegate?.jx_playerDurationDidChange?(self, duration: player.duration)
        }
        //播放进度改变
        self.player.playbackObserver.currentTimeDidChangeExeBlock = { [weak self] player in
            guard let self = self else { return }
            self.delegate?.jx_playerCurrentTimeDidChange?(self, time: player.currentTime)
        }
    }
    
}


//MARK: --------------   SJVideoPlayerControlLayerDataSource  --------------
extension JXPlayer: SJVideoPlayerControlLayerDataSource {
    public func controlView() -> UIView? {
        return self.jx_controlView as? UIView
    }
}


