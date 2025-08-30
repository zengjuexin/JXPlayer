//
//  JXPlayerListControlView.swift
//  JXPlayer
//
//  Created by 长沙鸿瑶 on 2025/8/30.
//

import UIKit

class JXPlayerListControlView: UIView, JXPlayerControlView {
    
    var isCurrent: Bool = false
    
    weak var viewModel: JXPlayerListViewModel?
    
    var durationTime: TimeInterval = 0
    var currentTime: TimeInterval = 0
    ///加载中状态
    var isLoading = false
    
    func singleTapEvent() {
        
    }
}
