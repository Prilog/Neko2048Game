//
//  ViewController.swift
//  Neko2048Game
//
//  Created by Семен Трапезников on 17/05/2019.
//  Copyright © 2019 Prilog. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tableCollection: UICollectionView!
    @IBOutlet weak var retryButton: UIButton!
    
    let gameEngine = GameEngine()
    var currentState = [Int]()
    let restartAlert = UIAlertController(title: "Конец игры", message: "Невозможно сделать ход. Начать новую игру?", preferredStyle: UIAlertController.Style.actionSheet)
    let winAlert = UIAlertController(title: "2048!", message: "Вы получили число 2048. Начать новую игру?", preferredStyle: UIAlertController.Style.actionSheet)
    let colors = [0:[185, 194, 205], 2:[255, 255, 255], 4:[226, 228, 231], 8:[154, 222, 255],
                  16:[92, 180, 255], 32:[21, 139, 236], 64:[0, 100, 215], 128:[0, 71, 185],
                  256:[20, 60, 134], 512:[3, 39, 134], 1024:[0, 17, 185], 2048:[9, 1, 113]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableCollection.dataSource = self
        tableCollection.delegate = self
        
        retryButton.layer.cornerRadius = 15
        retryButton.layer.shadowRadius = 10
        retryButton.layer.shadowOpacity = 0.3
        retryButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let yesAction = UIAlertAction(title: "Да", style: .default, handler: { UIAlertAction in
            self.doAction(name: .start)
        })
        let noAction = UIAlertAction(title: "Нет", style: .default, handler: { UIAlertAction in
            self.gameEngine.lock()
        })
        
        restartAlert.addAction(yesAction)
        restartAlert.addAction(noAction)
        
        winAlert.addAction(yesAction)
        winAlert.addAction(noAction)
        
        startGame()
        
    }
    
    func startGame() {
        if UserDefaults.standard.object(forKey: "2048GameData") != nil {
            currentState = UserDefaults.standard.object(forKey: "2048GameData") as! [Int]
            gameEngine.setState(array: currentState)
        } else {
            currentState = gameEngine.action(name: .start)
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            doAction(name: .right)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            doAction(name: .left)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            doAction(name: .up)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            doAction(name: .down)
        }
    }
    
    func createColor(red:Int, green:Int, blue:Int)->UIColor {
        return UIColor(displayP3Red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }

    func setTable(table:Array<Int>) {
        tableCollection.visibleCells.forEach { (cell) in
            guard let cur = cell as? CollectionViewCell else { return }
            cur.numberLabel.text = table[cur.number] == 0 ? "" : String(table[cur.number])
            currentState[cur.number] = table[cur.number]
            let curColor = colors[table[cur.number]]
            cur.numberLabel.backgroundColor = createColor(red: curColor![0], green: curColor![1], blue: curColor![2])
        }
        UserDefaults.standard.set(currentState, forKey: "2048GameData")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 4, height: collectionView.bounds.height / 4)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = tableCollection.dequeueReusableCell(withReuseIdentifier: "NumberCell", for: indexPath) as! CollectionViewCell
        cell.numberLabel.text = currentState[indexPath.row] == 0 ? "" : String(currentState[indexPath.row])
        cell.numberLabel.font = cell.numberLabel.font.withSize(self.view.frame.width * 0.06)
        //I tried to make good auto adjust, but all options failed(((( idnk what to do
        cell.numberLabel.layer.cornerRadius = 15
        cell.numberLabel.layer.masksToBounds = true
        let curColor = colors[currentState[indexPath.row]]
        cell.numberLabel.backgroundColor = createColor(red: curColor![0], green: curColor![1], blue: curColor![2])
        cell.number = indexPath.row
        return cell
    }
    
    func doAction(name: GameEngine.actions) {
        if name != .start && gameEngine.locked() {
            return
        }
        currentState = gameEngine.action(name: name)
        setTable(table: currentState)
        let currentStatus = gameEngine.gameStatus()
        if currentStatus == -1 {
            self.present(restartAlert, animated: true, completion: nil)
        }
        if currentStatus == 1 {
            
        }
    }
    
    @IBAction func retryButtonPressed(_ sender: UIButton) {
        doAction(name: .start)
    }
    
}
