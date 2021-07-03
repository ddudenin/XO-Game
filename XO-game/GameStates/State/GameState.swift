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
    
    func begin() {
        self.gameViewController.firstPlayerTurnLabel.isHidden = true
        self.gameViewController.secondPlayerTurnLabel.isHidden = false
        
        guard let position = findBestMove(gameboard: self.gameboard, player: .second) else { return }
        
        addMark(at: position)
        
        self.gameViewController.goToNextStateAI()
    }
    
    func addMark(at position: GameboardPosition) {
        self.gameView.placeMarkView(OView(), at: position)
        self.gameboard.setPlayer(.second, at: position)
        
        self.isCompleted = true
    }
    
    private func minimax(gameboard: Gameboard, maximizing: Bool, player: Player) -> Int {
        let referee = Referee(gameboard: gameboard)
        let emptyCells = gameboard.getEmptyPositions()
        
        if let winner = referee.determineWinner() {
            switch winner {
            case .first: return -1
            case .second: return 1
            }
        } else if emptyCells.isEmpty {
            return 0
        }
        
        if maximizing {
            var bestEval = Int.min
            
            for cell in emptyCells {
                gameboard.setPlayer(player, at: cell)
                
                let result = minimax(gameboard: gameboard, maximizing: false, player: player.next)
                bestEval = max(result, bestEval)
                
                gameboard.setEmpty(at: cell)
            }
            
            return bestEval
        } else {
            var worstEval = Int.max
            
            for cell in emptyCells {
                gameboard.setPlayer(player, at: cell)
                
                let result = minimax(gameboard: gameboard, maximizing: true, player: player.next)
                worstEval = min(result, worstEval)
                
                gameboard.setEmpty(at: cell)
            }
            
            return worstEval
        }
        
        
    }
    
    private func findBestMove(gameboard: Gameboard, player: Player) -> GameboardPosition? {
        var bestEval = Int.min
        var bestMove: GameboardPosition? = nil
        
        let emptyCells = gameboard.getEmptyPositions()
        
        for cell in emptyCells {
            gameboard.setPlayer(player, at: cell)
            
            let result = minimax(gameboard: gameboard, maximizing: false, player: player.next)
            
            if result > bestEval {
                bestEval = result
                bestMove = cell
            }
            
            gameboard.setEmpty(at: cell)
        }
        
        return bestMove
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

