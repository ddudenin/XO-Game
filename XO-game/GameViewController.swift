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
    
    var currentSate: GameState! {
        didSet {
            self.currentSate.begin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.goToFisrtState()
        
        self.gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            self.currentSate.addMark(at: position)
            
            if self.currentSate.isCompleted {
                self.goToNextState()
            }
        }
    }
    
    func goToFisrtState() {
        self.currentSate = PlayerInputGameState(
            player: .first,
            gameboard: self.gameboard,
            gameView: self.gameboardView,
            gameViewController: self
        )
    }
    
    func goToNextState() {
        if let player = self.referee.determineWinner() {
            self.currentSate = WinnerGameState(winner: player, gameViewController: self)
            return
        }
        
        if self.gameboard.getEmptyPositions().isEmpty {
            self.currentSate = WinnerGameState(winner: nil, gameViewController: self)
            return
        }

        if (self.currentSate as? ComputerInputGameState) != nil {
            self.currentSate = PlayerInputGameState(
                player: .first,
                gameboard: self.gameboard,
                gameView: self.gameboardView,
                gameViewController: self
            )
        } else {
            let playerInputState = self.currentSate as! PlayerInputGameState
            let player = playerInputState.player.next
            
            if player == .second, self.vsAI {
                self.currentSate = ComputerInputGameState(
                    gameboard: self.gameboard,
                    gameView: self.gameboardView,
                    gameViewController: self
                )
            } else {
                self.currentSate = PlayerInputGameState(
                    player: player,
                    gameboard: self.gameboard,
                    gameView: self.gameboardView,
                    gameViewController: self
                )
            }
        }
    }
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        self.gameboard.clear()
        self.gameboardView.clear()
        self.goToFisrtState()
    }
}

