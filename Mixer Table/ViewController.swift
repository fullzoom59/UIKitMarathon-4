//
//  ViewController.swift
//  Mixer Table
//
//  Created by fullzoom on 12.07.2023.
//


import UIKit

class ViewController: UIViewController {

    private var data = (0...30).map(String.init)
    
    private var dataSource: UITableViewDiffableDataSource<Section, String>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, String>!
    private var selectedItems: Set<String> = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 10
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = "Task 4"
        
        tableView.delegate = self
        configurationTableView()
        configureDataSource()
        
        let resetButton = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(resetButtonMethod))
        navigationItem.rightBarButtonItem = resetButton
    }
    
    
    private func configurationTableView(){
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor , constant: 15),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15)
        ])
    }
    
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
            cell.textLabel?.text = item
            
            // Set the accessory type based on the selected state of the item
            cell.accessoryType = self.selectedItems.contains(item) ? .checkmark : .none
            return cell
        }
        
        snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Shuffle Data Animated
    @objc private func resetButtonMethod(){
        data.shuffle()
        
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, String>()
        newSnapshot.appendSections([.main])
        newSnapshot.appendItems(data)
        
        dataSource.apply(newSnapshot, animatingDifferences: true)
        
        snapshot = newSnapshot
    }
}

    
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if selectedItems.contains(selectedItem) {
            selectedItems.remove(selectedItem)
            cell.accessoryType = .none
        } else {
            selectedItems.insert(selectedItem)
            cell.accessoryType = .checkmark
            
//             Remove the selected item from its current position
            if snapshot.indexOfItem(selectedItem) != nil {
                snapshot.deleteItems([selectedItem])
                
                // Find the first item in the snapshot and insert the selected item before it
                let firstItem = snapshot.itemIdentifiers.first
                if let firstItem = firstItem {
                    snapshot.insertItems([selectedItem], beforeItem: firstItem)
                } else {
                    snapshot.appendItems([selectedItem])
                }
            }
            
            dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class TableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum Section: String {
    case main
}
