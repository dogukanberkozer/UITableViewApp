//
//  ViewController.swift
//  ScorpSSListApp
//
//  Created by Dogukan Berk Ozer on 26.04.2024.
//

import UIKit

class ListPeopleViewController: UIViewController {
    
    // MARK: - Privates
    
    private var tableView: UITableView!
    private var emptyStateView: EmptyStateView!
    
    private var people: [Person] = []
    private var uniqueIDs = Set<Int>()
    private var nextPageToken: String?
    private var isWaitingServiceResponse: Bool = false
    
    // scroll could continue where it left off after new data is added to people list
    private var lastContentOffset: CGFloat = 0
    private var oldContentOffset: CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    // shows user indicator while waiting for service response
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureIndicator()
        // preparing data
        fetchPeople(nextPageToken: nextPageToken)
    }
    
    // MARK: - Data
    
    func fetchPeople(nextPageToken: String?) {
        activityIndicator.startAnimating()
        isWaitingServiceResponse = true
        DataSource.fetch(next: nextPageToken) { [self] (response, error) in
            if let error = error {
                isWaitingServiceResponse = false
                activityIndicator.stopAnimating()
                // error handling
                presentErrorPopup(errorDescription: error.errorDescription)
            }
            else if let response = response {
                print("Fetched \(response.people.count) people with nextPageToken \(nextPageToken ?? "nil")")
                addNewPeople(newPeople: response.people)
                if let next = response.next {
                    self.nextPageToken = next
                }
                else {
                    self.nextPageToken = nil
                }
                isWaitingServiceResponse = false
                activityIndicator.stopAnimating()
                prepareUI()
            }
            else {
                fatalError("Response and error can't be both nil at a time!")
            }
        }
    }
    
    // MARK: - UI
    
    func prepareUI() {
        configurePeopleList()
        people.isEmpty ? configureEmptyStateView() : nil
    }
    
    func configurePeopleList() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        // table view delegates
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FullNameIDCell")
        tableView.rowHeight = 50
        view.addSubview(tableView)
        
        // Refresh Control
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        restoreScrollPosition()
    }
    
    func configureIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = .systemRed
        view.addSubview(activityIndicator)
    }
    
    // in case people list is empty
    func configureEmptyStateView() {
        emptyStateView = EmptyStateView()
        emptyStateView.refreshButton.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
        
        tableView.backgroundView = emptyStateView
        tableView.backgroundView?.isHidden = !self.people.isEmpty
    }
    
    // MARK: - Logic Methods
    
    func addNewPeople(newPeople: [Person]) {
        for person in newPeople {
            if !uniqueIDs.contains(person.id) { // to block persons who have same ID's
                people.append(person)
                uniqueIDs.insert(person.id)
            }
        }
    }
    
    // default values and initial processes
    func reloadPage() {
        people = []
        uniqueIDs = Set<Int>()
        nextPageToken = nil
        lastContentOffset = CGFloat(0)
        oldContentOffset = CGPoint(x: 0, y: 0)
        fetchPeople(nextPageToken: nextPageToken)
    }
    
    // scroll view memory
    func restoreScrollPosition() {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(oldContentOffset, animated: false)
    }
    
    // MARK: - Actions
    
    @objc func refreshButtonTapped(_ sender: UIButton) {
        emptyStateView.refreshButton.isEnabled = false
        emptyStateView.refreshButton.setTitle("UPDATING...", for: .normal)
        emptyStateView.refreshButton.setTitleColor(.systemGray, for: .normal)
        reloadPage()
    }
    
    @objc func didPullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.refreshControl?.endRefreshing()
            self.reloadPage()
        }
    }
}

// MARK: - Extensions

extension ListPeopleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isWaitingServiceResponse || indexPath.row >= people.count {
            return UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FullNameIDCell", for: indexPath)
            cell.textLabel?.text = "\(people[indexPath.row].fullName) (\(people[indexPath.row].id))"
            return cell
        }
    }
    
    // pagination: call service when user reaches the bottom of scroll && service isn't calling && nextPageToken is not empty
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == people.count - 1, !isWaitingServiceResponse, nextPageToken != nil {
            oldContentOffset = tableView.contentOffset
            fetchPeople(nextPageToken: nextPageToken)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }
}
