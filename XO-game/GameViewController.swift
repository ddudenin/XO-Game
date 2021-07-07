//
//  GameViewController.swift
//  XO-game
//
//  Created by Evgeny Kireev on 25/02/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet private var gameboardView: GameboardView!
    @IBOutlet private(set) var firstPlayerTurnLabel: UILabel!
    @IBOutlet private(set) var secondPlayerTurnLabel: UILabel!
    @IBOutlet private(set) var winnerLabel: UILabel!
    @IBOutlet private var restartButton: UIButton!
    
    private let gameboard = Gameboard()
    private lazy var referee = Referee(gameboard: self.gameboard)
    
    var vsAI = true
    
    private var currentState: GameState! {
        didSet {
            self.currentState.begin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.goToFisrtState()
        
        self.gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            self.currentState.addMark(at: position)
            
            if self.currentState.isCompleted {
                self.vsAI ? self.goToNextStateAI() : self.goToNextState()
            }
        }
    }
    
    func goToFisrtState() {
        self.currentState = PlayerInputGameState(
            player: .first,
            gameboard: self.gameboard,
            gameView: self.gameboardView,
            gameViewController: self
        )
    }
    
    func goToNextState() {
        if let player = self.referee.determineWinner() {
            self.currentState = EndGameState(winner: player, gameViewController: self)
            return
        }
        
        if self.gameboard.getEmptyPositions().isEmpty {
            self.currentState = EndGameState(winner: nil, gameViewController: self)
            return
        }
        
        guard let playerInputState = self.currentState as? PlayerInputGameState else {
            return
        }
        
        let player = playerInputState.player
        
        self.currentState = PlayerInputGameState(
            player: player.next,
            gameboard: self.gameboard,
            gameView: self.gameboardView,
            gameViewController: self
        )
    }
    
    func goToNextStateAI() {
        if let player = self.referee.determineWinner() {
            self.currentState = EndGameState(winner: player, gameViewController: self)
            return
        }
        
        if self.gameboard.getEmptyPositions().isEmpty {
            self.currentState = EndGameState(winner: nil, gameViewController: self)
            return
        }
        
        if (self.currentState as? ComputerInputGameState) != nil {
            self.currentState = PlayerInputGameState(
                player: .first,
                gameboard: self.gameboard,
                gameView: self.gameboardView,
                gameViewController: self
            )
        } else {
            self.currentState = ComputerInputGameState(
                gameboard: self.gameboard,
                gameView: self.gameboardView,
                gameViewController: self
            )
        }
    }
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        self.gameboard.clear()
        self.gameboardView.clear()
        self.goToFisrtState()
    }
}

