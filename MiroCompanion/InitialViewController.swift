//
//  InitialViewController.swift
//  MiroCompanion
//
//  Created by Jese on 20.11.2021.
//

import UIKit

let ip = "10.100.14.15:6969"

class InitialViewController: UITableViewController{
    
    let colours = [UIColor(red: 0.98, green: 0.82, blue: 0.76, alpha: 1.00), UIColor(red: 0.77, green: 0.87, blue: 0.96, alpha: 1.00), UIColor(red: 0.76, green: 0.88, blue: 0.77, alpha: 1.00), UIColor(red: 0.83, green: 0.77, blue: 0.98, alpha: 1.00), UIColor(red: 0.92, green: 0.59, blue: 0.58, alpha: 1.00)]
    
    let gradients = [[UIColor(red: 0.29, green: 0.28, blue: 0.98, alpha: 1.00).cgColor, UIColor(red: 1.00, green: 0.67, blue: 0.41, alpha: 1.00).cgColor], [UIColor(red: 0.50, green: 1.00, blue: 0.41, alpha: 1.00).cgColor, UIColor(red: 0.51, green: 0.51, blue: 0.95, alpha: 1.00).cgColor]]
    

    @IBOutlet weak var titleLabel: UINavigationItem!
    var boards = [BoardInfo]()
    var newLocation: String = ""
    var destinationInt = 0
    var lastColor: Int?
    var url: URL?
    var urlNew: URL?
    var colourIndex = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.boards.removeAll()
        titleLabel.title = "Miro Boards"
        tableView.delegate = self
        url = URL(string: "http://" + ip + "/boards" )!
        urlNew = URL(string: "http://" + ip + "/newboard" )!
        if self.traitCollection.userInterfaceStyle == .light{
            self.tableView.backgroundColor = UIColor.white
            self.view.backgroundColor = UIColor.white
        } else {
            self.tableView.backgroundColor = UIColor.black
            self.view.backgroundColor = UIColor.black
        }
        let cells = tableView.visibleCells
        for cell in cells {
            cell.layer.cornerRadius = 10.0
            cell.layer.masksToBounds = true
        }
        fetchData(url: url!, cells: tableView.visibleCells)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boards.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            boards.remove(at: ((boards.count - 1) - indexPath.row))
            let urlString = url!.absoluteString + "/" + boards[(boards.count - 1) - indexPath.row].id
            print(urlString)
            let reqUrl = URL(string: urlString)
            var request = URLRequest(url: reqUrl!)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) {( _, response, _) in
                    if let httpResponse = response as? HTTPURLResponse {
                        print(httpResponse.statusCode)
                        if httpResponse.statusCode != 200{return}
                        DispatchQueue.main.async{
                            UIView.transition(with: self.tableView,
                                              duration: 0.35,
                                              options: .transitionCrossDissolve,
                                              animations: { self.tableView.reloadData() })
                            
                        }
                    } else{
                        print("Sad :(")
                    }
                    
                
            }
            task.resume()
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Cunt function called")
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardCell", for: indexPath) as! BoardCell
        let boardsR = boards.reversed() as Array
        cell.boardLabel.text = boardsR[indexPath.row].name
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.backgroundColor = UIColor.white
        cell.contentView.backgroundColor = colours[boardsR[indexPath.row].colorIndex]
        cell.contentView.clipsToBounds = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.destinationInt = indexPath.row
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      // Do sonthing
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            if self.traitCollection.userInterfaceStyle == .light{
                self.tableView.backgroundColor = UIColor.white
            } else {
                self.tableView.backgroundColor = UIColor.black
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails"{
            let destVC = segue.destination as! ViewController
            print(boards.reversed()[destinationInt])
            destVC.boardName = boards[destinationInt].name
            destVC.boardId = boards[destinationInt].id
            destVC.boardInfo = boards[destinationInt]
        }
    }
    @IBAction func cancel(_ unwindSegue: UIStoryboardSegue){
        
    }
    
    @IBAction func addBoard(_ sender: Any) {
        
        var request = URLRequest(url: urlNew!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                guard let data = data else {
                        print("Ah shit here we go again")
                        return
                }
                guard let board = try? JSONDecoder().decode(BoardElement.self, from: data) else {
                        print("fail")
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style{
                                    case .default:
                                    print("default")
                                    
                                    case .cancel:
                                    print("cancel")
                                    
                                    case .destructive:
                                    print("destructive")
                                    
                                @unknown default:
                                    fatalError("How even?")
                                }
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    let boardInfo = BoardInfo(name: board.name, id: board.id, colorIndex: self.colourIndex)
                    self.boards.append(boardInfo)
                    print(self.boards)
                    if self.colourIndex >= 4 {
                        self.colourIndex = 0;
                    } else {
                        self.colourIndex += 1
                    }
                    DispatchQueue.main.async{
                        // Update your data source here
                        //self.tableView.reloadSections([0], with: UITableView.RowAnimation.fade)
                        //self.tableView.reloadData()
                        UIView.transition(with: self.tableView,
                                          duration: 0.35,
                                          options: .transitionCrossDissolve,
                                          animations: { self.tableView.reloadData() })
                        
                    }
            
        }
        task.resume()
    }
    
    func fetchData(url: URL, cells: [UITableViewCell]) {
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                    print("meme")
                    return
            }
            guard let boards = try? JSONDecoder().decode(Board.self, from: data) else {
            print("äää")
            return
            }
            self.boards.removeAll()
            for board in boards {
                let boardInfo = BoardInfo(name: board.name, id: board.id, colorIndex: self.colourIndex)
                self.boards.append(boardInfo)
                print(self.boards)
                if self.colourIndex >= 4 {
                    self.colourIndex = 0;
                } else {
                    self.colourIndex += 1
                }
                DispatchQueue.main.async{
                    // Update your data source here
                    //self.tableView.reloadSections([0], with: UITableView.RowAnimation.fade)
                    //self.tableView.reloadData()
                    UIView.transition(with: self.tableView,
                                      duration: 0.35,
                                      options: .transitionCrossDissolve,
                                      animations: { self.tableView.reloadData() })
                    
                }
            }
        }
        task.resume()
    }
    
}

// MARK: - BoardElement
struct BoardElement: Codable {
    let id, name, boardDescription: String
    let viewLink: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case boardDescription = "description"
        case viewLink
    }
}
struct BoardInfo : Codable {
    let name, id: String
    var speech: String?
    let colorIndex: Int
}

typealias Board = [BoardElement]
