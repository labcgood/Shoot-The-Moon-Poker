//
//  ViewController.swift
//  Shoot The Moon Poker
//
//  Created by Labe on 2024/2/16.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    //startView
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var playerCountLabel: UILabel!
    @IBOutlet var playerNameLabel: [UILabel]!
    @IBOutlet var playerNameTextField: [UITextField]!
    
    
    //gameView
    @IBOutlet var gameView: UIView!
    @IBOutlet weak var currentPlayerLabel: UILabel!
    @IBOutlet weak var currentCumulativeLabel: UILabel!
    @IBOutlet weak var betAmountLabel: UILabel!
    @IBOutlet weak var drawCardButton: UIButton!
    @IBOutlet var resultCards: [UIImageView]!
    @IBOutlet weak var remainingCardsLabel: UILabel!
    @IBOutlet weak var showResultLabel: UILabel!
    @IBOutlet weak var potAmountLabel: UILabel!
    @IBOutlet weak var plusTenButton: UIButton!
    @IBOutlet weak var plusHundredButton: UIButton!
    @IBOutlet weak var plusPotAmountButton: UIButton!
    @IBOutlet weak var reBetButton: UIButton!
    @IBOutlet weak var foldButton: UIButton!
    @IBOutlet weak var suffleButton: UIButton!
    @IBOutlet weak var nextPlayerButton: UIButton!
    @IBOutlet weak var chooseUpOrDown: UISegmentedControl!
    @IBOutlet weak var againButton: UIButton!
    
    //撲克牌用變數
    let suits:[String] = ["club", "diamond", "heart", "spade"]
    let ranks:[String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"]
    var cards = [Card]()
    
    //玩家相關變數
    var playerCount = 2
    var players = [Player]()
    
    //遊戲相關變數
    //下注金額
    var betAmount = 0
    //池底金額
    var potAmount = 0
    //剩餘牌數
    var remainingCards = 52
    //抽牌數(單局)
    var drawCardCount = 0
    //總抽牌數
    var totalDrawCardCount = 0
    //玩家陣列位置
    var playerIndex = 0
    
    //自訂function
    //建立玩家
    func createPlayer() {
        for i in 0...playerCount-1 {
            if playerNameTextField[i].text == nil || playerNameTextField[i].text == "" {
                playerNameTextField[i].text = playerNameTextField[i].placeholder
            }
            let cumulative = -10
            let player = Player(name: playerNameTextField[i].text!, totalJackpot: cumulative)
            players.append(player)
        }
    }
    
    //是否可以抽牌
    func canDrawCard() {
        if resultCards[1].isHidden == false && betAmount == 0 {
            drawCardButton.isEnabled = false
        } else if resultCards[2].isHidden == false {
            drawCardButton.isEnabled = false
        } else if remainingCards <= 2 && resultCards[0].isHidden == true {
            drawCardButton.isEnabled = false
        } else {
            drawCardButton.isEnabled = true
        }
    }
    
    //是否開放使用Button
    func canUseButton(canUse: Bool) {
        plusTenButton.isEnabled = canUse
        plusHundredButton.isEnabled = canUse
        plusPotAmountButton.isEnabled = canUse
        reBetButton.isEnabled = canUse
        foldButton.isEnabled = canUse
    }
    
    //更新玩家的累積金額
    func updateCurrentCumulativeAndPot() {
        currentCumulativeLabel.text = "\(players[playerIndex].totalJackpot)"
        potAmountLabel.text = "\(potAmount)"
        drawCardCount = 0
    }

    //玩家贏得遊戲
    func win() {
        players[playerIndex].totalJackpot += betAmount
        potAmount -= betAmount
        updateCurrentCumulativeAndPot()
        showResultLabel.text = "你贏了！"
        if potAmount == 0 {
            againButton.isHidden = false
        }
    }
    
    func clearResultCards() {
        for i in 0...2 {
            resultCards[i].isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //製作1組撲克牌加進cards陣列
        for suit in suits {
            for rank in ranks {
                let card = Card(suit: suit, rank: rank)
                cards.append(card)
            }
        }
        cards.shuffle()
        
        //startView
        playerNameLabel[2].isHidden = true
        playerNameLabel[3].isHidden = true
        playerNameTextField[2].isHidden = true
        playerNameTextField[3].isHidden = true
        
        //TextField收起鍵盤用
        for i in 0...3 {
            playerNameTextField[i].delegate = self
        }
        
        //SegmetedControl字體設定
        let font = UIFont(name: "NaikaiFont-ExtraLight", size: 20)
            if let font = font {
                let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
                chooseUpOrDown.setTitleTextAttributes(textAttributes, for: .normal)
                chooseUpOrDown.setTitleTextAttributes(textAttributes, for: .normal)
                }
    }
    
    //收起鍵盤
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
            }

    //startView的元件功能
    //減少遊玩人數(最低2人)，並將未用到的輸入框隱藏
    @IBAction func reduceButton(_ sender: Any) {
        if playerCount >= 3 {
            playerCount -= 1
        }
        if playerCount == 3 {
            playerNameLabel[3].isHidden = true
            playerNameTextField[3].isHidden = true
        } else if playerCount == 2 {
            playerNameLabel[2].isHidden = true
            playerNameTextField[2].isHidden = true
        }
        playerCountLabel.text = "\(playerCount)"
    }
    
    //增加遊玩人數(最多4人)，並將未用到的輸入框隱藏
    @IBAction func plusButton(_ sender: Any) {
        if playerCount <= 3 {
            playerCount += 1
        }
        if playerCount == 3 {
            playerNameLabel[2].isHidden = false
            playerNameTextField[2].isHidden = false
            
        } else if playerCount == 4 {
            playerNameLabel[3].isHidden = false
            playerNameTextField[3].isHidden = false
        }
        playerCountLabel.text = "\(playerCount)"
    }
    
    //開始遊戲，顯示出原本隱藏的遊戲畫面，因為還未學會撰寫連接Navigation Controller的程式內容，先用這個方法替代，不知道有沒有更好的方式？
    @IBAction func startGameButton(_ sender: Any) {
        //隱藏遊戲設定的View，顯示出遊戲畫面的View
        startView.isHidden = true
        createPlayer()
        //顯示出玩家1的名稱、累積金額、池底獎金
        currentPlayerLabel.text = players[playerIndex].name
        currentCumulativeLabel.text = "\(players[playerIndex].totalJackpot)"
        potAmount = playerCount * 10
        potAmountLabel.text = "\(potAmount)"
    }
    
    
    
    //gameView的元件功能
    //[Button]下注10元(如果金額超過池底，則無法再下注(+0))
    @IBAction func plusTenButton(_ sender: Any) {
        if potAmount < betAmount + 10 {
            betAmount += 0
        } else {
            betAmount += 10
        }
        betAmountLabel.text = "\(betAmount)"
        canDrawCard()
    }
    
    //[Button]下注100元(如果金額超過池底，則無法再下注(+0))
    @IBAction func plusHundredButton(_ sender: Any) {
        if potAmount < betAmount + 100 {
            betAmount += 0
        } else {
            betAmount += 100
        }
        betAmountLabel.text = "\(betAmount)"
        canDrawCard()
    }
    
    //[Button]全抓(下注與池底相同金額)
    @IBAction func plusPotAmountButton(_ sender: Any) {
        betAmount = potAmount
        betAmountLabel.text = "\(betAmount)"
        canDrawCard()
    }
    
    //[Button]重新下注(下注金額歸零)
    @IBAction func reBetButton(_ sender: Any) {
        betAmount = 0
        betAmountLabel.text = "\(betAmount)"
        canDrawCard()
    }
    
    //[Button]本局不跟(直接輸掉基本下注金額(10元))
    @IBAction func foldButton(_ sender: Any) {
        canDrawCard()
        players[playerIndex].totalJackpot -= 10
        potAmount += 10
        updateCurrentCumulativeAndPot()
        chooseUpOrDown.isHidden = true
        showResultLabel.text = "不跟☹"
    }
    
    //[Button]抽卡
    @IBAction func drawCardButton(_ sender: Any) {
        //用抽牌數量來將卡片圖片顯示出來
        resultCards[drawCardCount % 3].image = UIImage(named: self.cards[totalDrawCardCount].suit + self.cards[totalDrawCardCount].rank)
        resultCards[drawCardCount % 3].isHidden = false
        canDrawCard()
        
        //剩餘牌數-1，並顯示出來
        remainingCards -= 1
        remainingCardsLabel.text = "\(remainingCards)"
        
        //如果第1、2張牌數字一樣，就讓玩家選擇往上或往下抓
        if resultCards[1].isHidden == false {
            let firstCard = Int(cards[totalDrawCardCount % 52 - 1].rank)
            let secondCard = Int(cards[totalDrawCardCount % 52].rank)
            if firstCard == secondCard {
                chooseUpOrDown.isHidden = false
            }
        }
        
        //判斷輸贏
        if resultCards[2].isHidden == false {
            print("下注\(betAmount)")
            canDrawCard()
            chooseUpOrDown.isHidden = true
            let firstCard = Int(cards[totalDrawCardCount % 52 - 2].rank)
            let secondCard = Int(cards[totalDrawCardCount % 52 - 1].rank)
            let thirdCard = Int(cards[totalDrawCardCount % 52].rank)
            let downCard = min(firstCard!, secondCard!)
            let upCard = max(firstCard!, secondCard!)
            if firstCard == secondCard && firstCard == thirdCard {
                players[playerIndex].totalJackpot -= (betAmount * 3)
                potAmount += (betAmount * 3)
                updateCurrentCumulativeAndPot()
                showResultLabel.text = "☠☠☠☠☠\n太慘啦！"
            } else if thirdCard == firstCard || thirdCard == secondCard {
                players[playerIndex].totalJackpot -= (betAmount * 2)
                potAmount += (betAmount * 2)
                updateCurrentCumulativeAndPot()
                showResultLabel.text = "撞柱☠\n你輸了！"
            } else if firstCard == secondCard && thirdCard! < firstCard! && chooseUpOrDown.selectedSegmentIndex == 0 {
                win()
            } else if firstCard == secondCard && thirdCard! > firstCard! && chooseUpOrDown.selectedSegmentIndex == 1 {
                win()
            } else if (downCard ... upCard).contains(thirdCard!) {
                win()
            } else {
                players[playerIndex].totalJackpot -= betAmount
                potAmount += betAmount
                updateCurrentCumulativeAndPot()
                showResultLabel.text = "你輸了！"
            }
        }
        //抽牌數+1
        drawCardCount += 1
        totalDrawCardCount += 1
        //單局抽牌數達2才能下注或不跟
        if drawCardCount == 2 {
            canUseButton(canUse: true)
        }
    }
    
    //[Button]重新洗牌(牌數不夠一局或玩家想洗牌用)
    @IBAction func shuffleButton(_ sender: Any) {
        cards.shuffle()
        remainingCards = 52
        remainingCardsLabel.text = "\(remainingCards)"
        totalDrawCardCount = 0
        drawCardCount = 0
        clearResultCards()
        canDrawCard()
        canUseButton(canUse: false)
    }
    
    //[Button]下一位玩家
    @IBAction func nextPlayerButton(_ sender: Any) {
        playerIndex += 1
        if playerIndex > playerCount-1 {
            playerIndex = 0
        }
        currentPlayerLabel.text = players[playerIndex].name
        currentCumulativeLabel.text = "\(players[playerIndex].totalJackpot)"
        betAmount = 0
        betAmountLabel.text = "\(betAmount)"
        showResultLabel.text = ""
        drawCardCount = 0
        clearResultCards()
        canDrawCard()
        canUseButton(canUse: false)
        print(players)
        print("池底\(potAmount)")
    }
    
    //[Button]當有玩家贏得全部獎金，大家可以選擇繼續再下基本注
    @IBAction func againButton(_ sender: Any) {
        for i in 0...playerCount-1 {
            players[i].totalJackpot -= 10
            potAmount = 10 * playerCount
        }
        againButton.isHidden = true
        updateCurrentCumulativeAndPot()
    }
    
    //[Button]結算遊戲金額(負值玩家拿錢出來，正值玩家自己分錢🤣)，池底金額太失控的時候玩家也可以自行決定要結算，不然要脫褲子啦～
    @IBAction func gameSettlementButton(_ sender: Any) {
        showResultLabel.font = UIFont(name: "NaikaiFont-ExtraLight", size: 30)
        var text = "遊戲結果\n"
        for i in 0...playerCount-1 {
            text += "\n" + players[i].name + "：" + "\(players[i].totalJackpot)"
        }
        clearResultCards()
        showResultLabel.textAlignment = .left
        showResultLabel.text = text
        canUseButton(canUse: false)
        drawCardButton.isEnabled = false
        suffleButton.isEnabled = false
        nextPlayerButton.isEnabled = false
        currentPlayerLabel.text = ""
        currentCumulativeLabel.text = ""
        betAmountLabel.text = ""
        remainingCardsLabel.text = "0"
    }
    
}

