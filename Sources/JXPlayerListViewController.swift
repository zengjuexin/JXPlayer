

import UIKit
import SJMediaCacheServer


@objc public protocol JXPlayerListViewControllerDelegate {
    
    @objc optional func jx_playerViewControllerShouldLoadMoreData(playerViewController: JXPlayerListViewController) -> Bool
    
    @objc optional func jx_playerViewControllerLoadMoreData(playerViewController: JXPlayerListViewController)
    
    @objc optional func jx_playerListViewController(_ viewController: JXPlayerListViewController, didChangeIndexPathForVisible indexPath: IndexPath)
    
    @objc optional func jx_shouldAutoScrollNextEpisode(_ viewController: JXPlayerListViewController) -> Bool
    
}

@objc public protocol JXPlayerListViewControllerDataSource {
    
    
    func jx_playerListViewController(_ viewController: JXPlayerListViewController, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    func jx_playerListViewController(_ viewController: JXPlayerListViewController, numberOfItemsInSection section: Int) -> Int
    
    @objc optional func jx_numberOfSections(in viewController: JXPlayerListViewController) -> Int
    
}

open class JXPlayerListViewController: UIViewController {
    
    open var contentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    open var ViewModelClass: JXPlayerListViewModel.Type {
        return JXPlayerListViewModel.self
    }
    
    
    open weak var delegate: JXPlayerListViewControllerDelegate?
    open weak var dataSource: JXPlayerListViewControllerDataSource?
    
    public lazy var viewModel: JXPlayerListViewModel = {
        let viewModel = ViewModelClass.init()
        viewModel.playerListVC = self
        return viewModel
    }()
    
    ///预加载
    private var prePrefetchTask: MCSPrefetchTask?
    private var nextPrefetchTask: MCSPrefetchTask?
    
    public var jx_isDidAppear = false
    
    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = contentSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }()
    
    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .init(x: 0, y: 0, width: contentSize.width, height: contentSize.height), collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        return collectionView
    }()
    
    deinit {
        self.prePrefetchTask?.cancel()
        self.nextPrefetchTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        self.register(JXPlayerListCell.self, forCellWithReuseIdentifier: "JXPlayerListCell")
        
        self.view.addSubview(self.collectionView)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        jx_isDidAppear = true
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        jx_isDidAppear = false
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        jx_isDidAppear = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.scrollDidEnd()
        }
    }
    
    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    ///返回上个视频路径  需要子类重写  预加载用
    open var previousVideoUrl: String? { return nil }
    ///返回下个视频路径 需要子类重写  预加载用
    open var nextVideoUrl: String? { return nil }
    
    open func play() {
        if self.jx_isDidAppear {
            self.viewModel.currentCell?.start()
        }
        
        self.viewModel.isPlaying = true
        
        if (self.collectionView.contentSize.height - self.collectionView.contentOffset.y) / self.contentSize.height <= 3 {
            self.loadMoreData()
        }
    }
    
    open func pause() {
        self.viewModel.currentCell?.pause()
        self.viewModel.isPlaying = false
    }
    
    open func clearData() {
        self.viewModel.currentCell = nil
        self.viewModel.currentIndexPath = .init(row: 0, section: 0)
        self.collectionView.contentOffset = .init(x: 0, y: 0)
        self.collectionView.reloadData()
    }
    
    public func reloadData(completion: (() -> Void)? = nil) {
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
        self.collectionView.performBatchUpdates(nil) { [weak self] finish in
            guard let self = self else { return }
            let cell = self.collectionView.cellForItem(at: viewModel.currentIndexPath) as? JXPlayerCell
            self.viewModel.currentCell = cell
            completion?()
        }
    }
    
    public func scrollToItem(indexPath: IndexPath, animated: Bool = true, completer: (() -> Void)? = nil) {
        UIView.performWithoutAnimation {
            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: animated);
        }
        self.collectionView.performBatchUpdates(nil) { [weak self] _ in
            guard let self = self else { return }
            if !animated {
                if viewModel.currentIndexPath != indexPath {
                    self.skip(indexPath: indexPath)
                } else {
                    self.play()
                }
            }
            completer?()
        }
    }
    
    ///滑动至下一级
    open func scrollToNextEpisode() {
        var contentOffset = self.collectionView.contentOffset
        
        if hasNextEpisode() {
            contentOffset.y = floor(contentOffset.y + self.contentSize.height)
            self.collectionView.setContentOffset(contentOffset, animated: true)
        } else {
            self.viewModel.currentCell?.replay()
        }
    }
    
    
    ///是否还有下一级
    open func hasNextEpisode() -> Bool {
        let contentOffset = self.collectionView.contentOffset
        let contentSize = self.collectionView.contentSize
        if contentOffset.y >= contentSize.height - self.contentSize.height {
            return false
        }
        return true
    }
    
    public func allowAutoScrollNextEpisode() -> Bool? {
        return self.delegate?.jx_shouldAutoScrollNextEpisode?(self)
    }

}


extension JXPlayerListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if let newCell = self.dataSource?.jx_playerListViewController(self, cellForItemAt: indexPath) {
            cell = newCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "JXPlayerListCell", for: indexPath)
        }
        if let cell = cell as? JXPlayerListCell, cell.viewModel == nil {
            cell.viewModel = viewModel
        }
        
        if self.viewModel.currentCell == nil, indexPath == viewModel.currentIndexPath, let cell = cell as? JXPlayerCell {
            self.viewModel.currentCell = cell
            self.didChangeIndexPathForVisible()
        }
        
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.prePrefetchTask?.cancel()
        self.nextPrefetchTask?.cancel()
        
        self.prePrefetchTask = self.prefetchTask(url: self.previousVideoUrl)
        self.nextPrefetchTask = self.prefetchTask(url: self.nextVideoUrl)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.jx_playerListViewController(self, numberOfItemsInSection: section) ?? 0
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.dataSource?.jx_numberOfSections?(in: self) ?? 1
    }
    
    //滑动停止
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDidEnd()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDidEnd()
    }
    
    private func scrollDidEnd() {
        let offsetY = self.collectionView.contentOffset.y
        let indexPaths = self.collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            guard let cell = self.collectionView.cellForItem(at: indexPath)  else { continue }
            if floor(offsetY) == floor(cell.frame.origin.y) {
                if viewModel.currentIndexPath != indexPath {
                    self.skip(indexPath: indexPath)
                }
            }
        }
    }
    
    private func skip(indexPath: IndexPath) {
        guard let currentPlayer = self.collectionView.cellForItem(at: indexPath) as? JXPlayerCell else { return }
        viewModel.currentIndexPath = indexPath
        self.viewModel.currentCell = currentPlayer
        didChangeIndexPathForVisible()
        self.play()
    }
    
}

extension JXPlayerListViewController {
    
    private func loadMoreData() {
        let isLoad = self.delegate?.jx_playerViewControllerShouldLoadMoreData?(playerViewController: self)
        if isLoad != false {
            self.delegate?.jx_playerViewControllerLoadMoreData?(playerViewController: self)
        }
    }
    
    private func didChangeIndexPathForVisible() {
        self.delegate?.jx_playerListViewController?(self, didChangeIndexPathForVisible: viewModel.currentIndexPath)
    }
}

//MARK: --------------   预加载  --------------
extension JXPlayerListViewController {
    private func prefetchTask(url: String?) -> MCSPrefetchTask? {
        guard let str = url else { return nil }
        guard let url = URL(string: str) else { return nil }
        return SJMediaCacheServer.shared().prefetch(with: url, prefetchSize: 1 * 1024 * 1024)
    }
}

//MARK: --------------   系统回调  --------------
extension JXPlayerListViewController {
    
    @objc open func didBecomeActiveNotification() {
        if self.viewModel.isPlaying && jx_isDidAppear {
            self.viewModel.currentCell?.start()
        }
    }
    
    @objc open func willResignActiveNotification() {
        self.viewModel.currentCell?.pause()
    }
}
