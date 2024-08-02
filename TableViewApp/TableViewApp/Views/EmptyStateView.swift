//
//  EmptyStateView.swift
//  ScorpSSListApp
//
//  Created by Dogukan Berk Ozer on 27.04.2024.
//

import UIKit

class EmptyStateView: UIView {
    
    let emptyMessageLabel = UILabel()
    let refreshButton = UIButton(type: .system)
    
    // to obstruct retrying aggressively BE service
    var countdownTimer: Timer?
    var countdownSeconds = 3
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Do not use storyboard or xib!")
    }
    
    // MARK: - UI
    
    private func setupViews() {
        backgroundColor = .clear
        
        emptyMessageLabel.text = "No one here :)"
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.textColor = .black
        addSubview(emptyMessageLabel)
        
        refreshButton.setTitle("Wait \(self.countdownSeconds) seconds to retry", for: .normal)
        refreshButton.setTitleColor(.systemGray, for: .normal)
        refreshButton.backgroundColor = .systemGreen
        refreshButton.layer.cornerRadius = 8
        refreshButton.isEnabled = false
        addSubview(refreshButton)
        
        // button will be enable in 3 seconds
        startButtonTimer()
    }
    
    // MARK: - Logic
    
    private func startButtonTimer() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            // to show countdown on button
            self.countdownSeconds -= 1
            refreshButton.setTitle("Wait \(self.countdownSeconds) seconds to retry", for: .normal)
            
            if self.countdownSeconds == 0 {
                timer.invalidate()
                refreshButton.isEnabled = true
                refreshButton.setTitle("REFRESH", for: .normal)
                refreshButton.setTitleColor(.white, for: .normal)
                self.countdownSeconds = 3
            }
        }
    }
    
    // MARK: - Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelWidth = bounds.width - 40
        let labelHeight = CGFloat(40)
        emptyMessageLabel.frame = CGRect(x: (bounds.width - labelWidth) / 2, y: (bounds.height - labelHeight) / 2, width: labelWidth, height: labelHeight)
        
        let buttonWidth = bounds.width - 40
        refreshButton.frame = CGRect(x: (bounds.width - buttonWidth) / 2, y: emptyMessageLabel.frame.maxY + 20, width: buttonWidth, height: 40)
    }
}
