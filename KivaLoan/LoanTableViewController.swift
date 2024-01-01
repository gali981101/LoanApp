
import UIKit

class LoanTableViewController: UITableViewController {
    
    private let kivaLoanURL = "https://api.kivaws.org/v1/loans/newest.json"
    private var loans: [Loan] = []
    
    lazy var dataSource = configureDataSource()
    
    enum Section {
        case all
    }
    
}

// MARK: - Life Cycle

extension LoanTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 92.0
        tableView.rowHeight = UITableView.automaticDimension
        
        getLoans()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - DiffableDataSource

extension LoanTableViewController {
    
    private func configureDataSource() -> UITableViewDiffableDataSource<Section, Loan> {
        
        let cellIdentifier = "Cell"
        
        let dataSource = UITableViewDiffableDataSource<Section, Loan>(
            tableView: tableView) { tableView, indexPath, loan in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LoanTableViewCell
                
                cell.nameLabel.text = loan.name
                cell.countryLabel.text = loan.country
                cell.useLabel.text = loan.use
                cell.amountLabel.text = "$\(loan.amount)"
                
                return cell
            }
        
        return dataSource
    }
    
    private func updateSnapshot(animatingChange: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Loan>() 
        
        snapshot.appendSections([.all])
        snapshot.appendItems(loans, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: animatingChange)
    }
    
}

// MARK: - UITableViewDelegate

extension LoanTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

// MARK: - Networking

extension LoanTableViewController {
    
    private func getLoans() {
        guard let url = URL(string: kivaLoanURL) else { return }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request, completionHandler: resultHandle(data:res:err:))
        
        task.resume()
    }
    
    private func resultHandle(data: Data?, res: URLResponse?, err: Error?) {
        guard err == nil else { fatalError("請求回應結果失敗 \(String(describing: err?.localizedDescription))") }
        guard let data = data else { return }
        
        loans = parseJsonData(data)
        
        OperationQueue.main.addOperation {
            self.updateSnapshot()
        }
    }
    
}

// MARK: - Helper Method

extension LoanTableViewController {
    
    private func parseJsonData(_ data: Data) -> [Loan] {
        var loans = [Loan]()
        
        let decoder = JSONDecoder()
        
        do {
            let LoanDataStore = try decoder.decode(LoanDataStore.self, from: data)
            loans = LoanDataStore.loans
        } catch {
            print(error)
        }
        
        return loans
    }
    
}
