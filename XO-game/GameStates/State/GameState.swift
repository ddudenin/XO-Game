//
//  GameState.swift
//  XO-game
//
//  Created by Дмитрий Дуденин on 28.06.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import Foundation

protocol GameState: AnyObject {
    var isCompleted: Bool { get }
    func begin()
    func addMark(at position: GameboardPosition)
}

class PlayerInputGameState: GameState {
    
    let player: Player
    
    private let gameboard: Gameboard
    private let gameView: GameboardView
    private unowned let gameViewController: GameViewController
    
    private(set) var isCompleted: Bool = false
    
    init(player: Player, gameboard: Gameboard, gameView: GameboardView, gameViewController: GameViewController) {
        self.player = player
        self.gameboard = gameboard
        self.gameView = gameView
        self.gameViewController = gameViewController
    }
    
    func begin() {
        switch self.player {
        case .first:
            self.gameViewController.firstPlayerTurnLabel.isHidden = false
            self.gameViewController.secondPlayerTurnLabel.isHidden = true
        case .second:
            self.gameViewController.firstPlayerTurnLabel.isHidden = true
            self.gameViewController.secondPlayerTurnLabel.isHidden = false
        }
        
        self.gameViewController.winnerLabel.isHidden = true
    }
    
    func addMark(at position: GameboardPosition) {
        guard self.gameView.canPlaceMarkView(at: position) else { return }
        
        let markView: MarkView
        
        switch self.player {
        case .first:
            markView = XView()
        case .second:
            markView = OView()
            
        }
        
        self.gameView.placeMarkView(markView, at: position)
        self.gameboard.setPlayer(self.player, at: position)
        
        self.isCompleted = true
    }
}

class ComputerInputGameState: GameState {
    
    private let gameboard: Gameboard
    private let gameView: GameboardView
    private unowned let gameViewController: GameViewController
    
    private(set) var isCompleted: Bool = false
    
    init(gameboard: Gameboard, gameView: GameboardView, gameViewController: GameViewController) {
        self.gameboard = gameboard
        self.gameView = gameView
        self.gameViewController = gameViewController
    }
    
    var position = GameboardPosition(column: 0, row: 0)
    
    func begin() {
        self.gameViewController.firstPlayerTurnLabel.isHidden = true
        self.gameViewController.secondPlayerTurnLabel.isHidden = false
        
        let markView = OView()
        
        _ = minimax(gameboard: self.gameboard, player: .second)
        
        self.gameView.placeMarkView(markView, at: position)
        self.gameboard.setPlayer(.second, at: position)
        
        self.isCompleted = true
        
        self.gameViewController.goToNextState()
    }
    
    func addMark(at position: GameboardPosition) { }
    
    private func minimax(gameboard: Gameboard, player: Player) -> Int {
        let referee = Referee(gameboard: gameboard)
        let emptyCells = gameboard.getEmptyPositions()
        
        if let winner = referee.determineWinner() {
            switch winner {
            case .first: return 10
            case .second: return -10
            }
        } else if emptyCells.isEmpty {
            return 0
        }
        
        var moves = [GameboardPosition : Int]()
        
        for cell in emptyCells {
            gameboard.setPlayer(player, at: cell)
            moves[cell] = minimax(gameboard: gameboard, player: player.next)
            gameboard.setEmpty(at: cell)
        }
        
        var bestScore = 0
        switch player {
        case .first:
            bestScore = -10000;
            for move in moves where move.value > bestScore {
                self.position = move.key
                bestScore = move.value
            }
        case .second:
            bestScore = 10000;
            for move in moves where move.value < bestScore {
                self.position = move.key
                bestScore = move.value
            }
        }
        
        return bestScore
    }
}

class EndGameState: GameState {
    
    let winner: Player?
    
    private unowned let gameViewController: GameViewController
    
    private(set) var isCompleted: Bool = false
    
    init(winner: Player?, gameViewController: GameViewController) {
        self.winner = winner
        self.gameViewController = gameViewController
    }
    
    func begin() {
        self.gameViewController.firstPlayerTurnLabel.isHidden = true
        self.gameViewController.secondPlayerTurnLabel.isHidden = true
        
        self.gameViewController.winnerLabel.isHidden = false
        self.gameViewController.winnerLabel.text = self.getWinnerName()
    }
    
    func addMark(at position: GameboardPosition) { }
    
    private func getWinnerName() -> String {
        if let player = self.winner {
            var name = ""
            switch player {
            case .first: name = "1st player"
            case .second: name = self.gameViewController.vsAI ?  "computer" : "2nd player"
            }
            
            return "Winner \(name)"
        } else {
            return "Draw"
        }

    }
}

