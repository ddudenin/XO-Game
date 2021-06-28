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
        let markView = OView()
        
        var position: GameboardPosition
        
        repeat {
            let row = Int.random(in: 0..<GameboardSize.rows)
            let col = Int.random(in: 0..<GameboardSize.columns)
            position = GameboardPosition(column: row, row: col)
        } while !self.gameView.canPlaceMarkView(at: position)
        
        self.gameView.placeMarkView(markView, at: position)
        self.gameboard.setPlayer(.second, at: position)
        
        self.isCompleted = true
        
        self.gameViewController.goToNextState()
    }
    
    func addMark(at position: GameboardPosition) { }
}

class WinnerGameState: GameState {

    let winner: Player
    
    private unowned let gameViewController: GameViewController
    
    private(set) var isCompleted: Bool = false
    
    init(winner: Player, gameViewController: GameViewController) {
        self.winner = winner
        self.gameViewController = gameViewController
    }
    
    func begin() {
        let name = self.getWinnerName()
        
        self.gameViewController.firstPlayerTurnLabel.isHidden = true
        self.gameViewController.secondPlayerTurnLabel.isHidden = true
        
        self.gameViewController.winnerLabel.isHidden = false
        self.gameViewController.winnerLabel.text = "Winner \(name) player"
    }
    
    func addMark(at position: GameboardPosition) { }
    
    private func getWinnerName() -> String {
        switch self.winner {
        case .first: return "1st"
        case .second: return "2nd"
        }
    }
}

