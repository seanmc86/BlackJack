//
//  ViewController.swift
//  BlackJack
//
//  Created by Sean McCalgan on 2018/05/28.
//  Copyright © 2018 Sean McCalgan. All rights reserved.
//

import UIKit

struct Player {
    var playerNumber: Int
    var card1Value: Int
    var card2Value: Int
    var card3Value: Int
    var card4Value: Int
    var card5Value: Int
}

class ViewController: UIViewController {

    let suits = ["Spades", "Hearts", "Diamonds", "Clubs"]
    let values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace"]
    
    var deck = [String: Any]()
    var existingCards = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startGame()
        
    }
    
    /**
        Takes the Suit and Value of a card and returns a String name to track progress of the game descriptively
     */
    func CardDetails(Suit: Int, Value: Int) -> (String) {
        
        var returnSuit = ""
        var returnName = ""
        
        switch(Suit) {
        case 1:
            returnSuit = "Spades"
        case 2:
            returnSuit = "Hearts"
        case 3:
            returnSuit = "Diamonds"
        case 4:
            returnSuit = "Clubs"
        default:
            returnSuit = "#"
        }
        
        switch(Value) {
        case 10:
            returnName = "Jack"
        case 11:
            returnName = "Queen"
        case 12:
            returnName = "King"
        case 13:
            returnName = "Ace"
        default:
            returnName = String(Value)
        }
        
        returnName = "\(returnName) of \(returnSuit)"
        
        return (returnName)
    }
    
    /**
        Takes an initial Card Value and returns its true value to the game
     
        Card Values are initially designated as 2-13 to distinguish face card names as well as Aces
        These values are then transformed into the value that the game requires to make comparisons
     */
    func CardValue(Value: Int) -> (Int) {
        
        var returnValue = Value
        
        if returnValue > 9 {
            if returnValue == 13 {
                returnValue = 11
            } else {
                returnValue = 10
            }
        }
        
        return (returnValue)
    }
    
    /**
        Returns a random number of players between 1 and 5 for the game to use
     */
    func Players() -> (Int) {
        let p = arc4random_uniform(_:5) + 1
        return (Int)(p)
    }
    
    /**
        Deals a player or dealer a new card, by returning the initial 2-13 Value which is then later transformed
     
        New cards cannot overlap in terms of their Suit/Value combination with cards already in the game
        This check is seen in the containsCard var
     */
    func DealCard() -> (Int) {
        var suitChosen = arc4random_uniform(_:4) + 1
        var numberChosen = arc4random_uniform(_:13) + 1
        
        var card: Int
        
        var containsCard = existingCards.contains("\(suitChosen),\(numberChosen)")
        while containsCard {
            let newSuitChosen = arc4random_uniform(_:4) + 1
            let newNumberChosen = arc4random_uniform(_:13) + 1
            
            suitChosen = newSuitChosen
            numberChosen = newNumberChosen
            
            containsCard = existingCards.contains("\(newSuitChosen),\(newNumberChosen)")
        }
        
        let printCard = CardDetails(Suit: Int(suitChosen), Value: Int(numberChosen))
        print(printCard)
        
        card = Int(numberChosen)
        
        return card
    }
    
    /**
        Simply used to keep the Player instance up to date for reporting at the end of a game
     
        The update takes an existing row from the Player instance and updates the card value depending on the number of cards the player now has
     */
    func updateList(List: Player, CardNum: Int, CardVal: Int) -> Player {
        var newList = List
        
        switch(CardNum) {
        case 3:
            newList.card3Value = CardVal
        case 4:
            newList.card4Value = CardVal
        case 5:
            newList.card5Value = CardVal
        default:
            newList = List
        }
        
        return (newList)
    }
    
    /**
        Performs the initial 2 card layouts for both the players and dealer
     
        A new Player instance is first set up, cards are dealt into each player's records, and then once appended this Player instance is given back for the game to begin
     */
    func setupGame() -> [Player] {
        let players = Players()
        var playerList = [Player]()
        
        print("Setting up initial hands for a \(players) player game...")
        
        // Deal 2 cards for every non-dealer player in the game
        for player in 1...players {

            print("Player \(player) receives:")
            
            let card1 = DealCard()
            let card2 = DealCard()
            
            playerList.append(Player(playerNumber: player, card1Value: card1, card2Value: card2, card3Value: 0, card4Value: 0, card5Value: 0))
        
        }
        
        // Now deal 2 cards for the dealer
        print("Dealer receives:")
        
        let card1 = DealCard()
        let card2 = DealCard()
        
        playerList.append(Player(playerNumber: 0, card1Value: card1, card2Value: card2, card3Value: 0, card4Value: 0, card5Value: 0))
        
        return playerList
        
    }
    
    /**
        Runs the game by first establishing the game setup through setupGame() and then looping through each player's hand
     
        The dealer already has their 2 cards from setupGame(), so all that's left is the players
        Players are given new cards via DealCard() if they are yet to win or bust
     */
    func startGame() {
        var playerList = setupGame()
        
        let dealerTotal = playerList[0].card1Value + playerList[0].card2Value
        
        for player in 1...(playerList.count - 1) {
            
            let playerIndex = player - 1
            let card1Value = CardValue(Value:playerList[playerIndex].card1Value)
            let card2Value = CardValue(Value:playerList[playerIndex].card2Value)

            var playerTotal = card1Value + card2Value
            
            var handOver = 0
            var cardsReceived = 2
            var acesHeld = 0
            
            if card1Value == 11 {
                acesHeld += 1
            }
            if card2Value == 11 {
                acesHeld += 1
            }
            
            print("Player \(player) has a starting total of \(playerTotal) and \(acesHeld) aces")
            
            while handOver == 0 {

                if playerTotal <= 21 {
                    if cardsReceived == 5 {
                        print("Player \(player) beats the dealer with 5 cards!")
                        handOver = 1
                    } else if playerTotal >= dealerTotal {
                        print("Player \(player) beats the dealer! - \(playerTotal) >= \(dealerTotal)")
                        handOver = 1
                    } else {
                        print("Player \(player) receives:")
                        let newCard = DealCard()
                        playerTotal += CardValue(Value:newCard)
                        cardsReceived += 1
                        playerList[player] = updateList(List: playerList[player], CardNum: cardsReceived, CardVal: CardValue(Value:newCard))
                    }
                } else {
                    if acesHeld > 0 {
                        playerTotal -= 10
                        acesHeld -= 1
                        
                        print("Player \(player) receives:")
                        let newCard = DealCard()
                        playerTotal += CardValue(Value:newCard)
                        cardsReceived += 1
                    } else {
                    print("Player \(player) bust!")
                        handOver = 1
                    }
                }
            }
            
        }
        
        print("Card layout post match:")
        print(playerList)
        
    }

}

