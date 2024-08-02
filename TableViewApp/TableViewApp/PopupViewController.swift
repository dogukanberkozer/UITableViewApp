//
//  PopupViewController.swift
//  ScorpSSListApp
//
//  Created by Dogukan Berk Ozer on 28.04.2024.
//

import UIKit

class PopupViewController: UIViewController {
    
    let errorDescriptionLabel = UILabel()
    let exitButton = UIButton()
    let retryButton = UIButton()
    
    let popupWidth: CGFloat = 300
    let popupHeight: CGFloat = 150
    
    // to obstruct retrying aggressively BE service
    var countdownTimer: Timer?
    var countdownSeconds = 5
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    // MARK: - UI
    
    private func prepareUI() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        let popupView = UIView(frame: CGRect(x: (view.frame.width - popupWidth) / 2, y: (view.frame.height - popupHeight) / 2, width: popupWidth, height: popupHeight))
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 8
        view.addSubview(popupView)
        
        // error description of popup
        errorDescriptionLabel.frame = CGRect(x: 20, y: 20, width: popupWidth - 40, height: 40)
        errorDescriptionLabel.textAlignment = .center
        popupView.addSubview(errorDescriptionLabel)
        
        // closes the app after error
        exitButton.frame = CGRect(x: 20, y: popupHeight - 60, width: (popupWidth - 50) / 2, height: 40)
        exitButton.setTitle("Give Up", for: .normal)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.backgroundColor = .systemRed
        exitButton.layer.cornerRadius = 8
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        popupView.addSubview(exitButton)
        
        // button to call service again
        retryButton.frame = CGRect(x: exitButton.frame.maxX + 10, y: popupHeight - 60, width: (popupWidth - 50) / 2, height: 40)
        retryButton.setTitle("RETRY (\(self.countdownSeconds))", for: .normal)
        retryButton.setTitleColor(.systemGray, for: .normal)
        retryButton.backgroundColor = .systemGreen
        retryButton.layer.cornerRadius = 8
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryButton.isEnabled = false
        popupView.addSubview(retryButton)
        
        // retry button will be enable in 5 seconds
        startRetryButtonTimer()
    }
    
    // MARK: - Logic
    
    private func startRetryButtonTimer() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            // to show countdown on button
            self.countdownSeconds -= 1
            retryButton.setTitle("RETRY (\(self.countdownSeconds))", for: .normal)
            
            if self.countdownSeconds == 0 {
                timer.invalidate()
                retryButton.isEnabled = true
                retryButton.setTitle("RETRY", for: .normal)
                retryButton.setTitleColor(.white, for: .normal)
                self.countdownSeconds = 5
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func exitButtonTapped() {
        exit(0)
    }
    
    @objc func retryButtonTapped() {
        dismiss(animated: true, completion: { [weak self] in
            guard self != nil else { return }
            // let topMostViewController = UIApplication.topMostViewController() as? ListPeopleViewController
            /*
             keyWindow was deprecated, I have been tried UIApplication.topMostViewController() but not worked 100% effectively
             */
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let topViewController = windowScene.windows
                .first(where: { $0.isKeyWindow })?.rootViewController as? ListPeopleViewController {
                topViewController.reloadPage()
            }
        })
    }
}

// MARK: - Extensions

extension UIViewController {
    
    func presentErrorPopup(errorDescription: String) {
        let popupVC = PopupViewController()
        popupVC.errorDescriptionLabel.text = errorDescription
        popupVC.modalPresentationStyle = .overCurrentContext
        self.present(popupVC, animated: true, completion: nil)
    }
}
