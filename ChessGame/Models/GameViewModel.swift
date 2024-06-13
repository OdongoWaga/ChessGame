//
// Copyright iOS Mastery.
// All Rights Reserved.


import SwiftUI
import Combine


@Observable
class GameViewModel{
    typealias ValidMoveCollection = Set<Move>
    let roster: Roster
    var game: Game
    var state: State
    var selection: Selection?
    var shouldPromptForPromotion = PassthroughSubject<Move, Never>()
    var checkHandler: CheckHandler
    var validMoveGrid = ChessGrid(repeating: ValidMoveCollection())
    var checkmateOccured = PassthroughSubject<Team, Never>()
    
    
//    init(roster: Roster, game: Game = Game.standard) {
//        self.roster = roster
//        self.game = game
//        self.checkHandler = CheckHandler()
//        self.state = .working
//        
//        self.beginNextTurn()
//    }
    init(roster: Roster, game: Game = Game.standard) {
        self.roster = roster
        self.game = game
        self.state = .working
        self.checkHandler = CheckHandler()
        self.beginNextTurn()
    }
    
    init(game: Game, roster: Roster = Roster(whitePlayer: .human,
           // .AI(Mike() as! ArtificialIntelligence),
                                             blackPlayer: .human), selection: Selection? = nil, checkHandler: CheckHandler = CheckHandler()){
        self.game = game
        self.roster = roster
        self.selection = selection
        self.checkHandler = checkHandler
        self.state = .working
        self.beginNextTurn()
        
    }
    
    enum State: Equatable, CustomStringConvertible{
         case awaitingInput
        case working
        case aiThinking(name: String)
        case stalemate
        case gameOver(Team)
        
        var description: String{
            
            switch self {
            case .awaitingInput:
                return "Make A Move"
            case .working:
                return "Processing"
            case .aiThinking(let name):
            return "\(name) is thinking"
            case .stalemate:
                return "Stalemate"
            case .gameOver(let winner):
                return "\(winner) has won"
            }
            
        }
        
        
    }
    
    struct Selection {
        let moves: Set<Move>
        let origin: Position
        
        var grid: BooleanChessGrid{
            return BooleanChessGrid(positions: moves.map{
                $0.destination
            })
        }
        
        func move(position: Position) -> Move?{
            return moves.first(where: {
                $0.destination == position
            })
        }
        
    }
    
    func beginNextTurn(){
        self.selection = nil
        guard checkHandler.state(team: self.game.turn, game: game) != .checkmate else {
            self.state = .gameOver(self.game.turn.opponent)
            checkmateOccured.send(self.game.turn.opponent)
           
            return
        }
        
        switch roster[game.turn]{
        case .human:
            regenerateValidMoveGrid {
                self.state = .awaitingInput
            }
            
        case .AI(let artificialOpponent):
            regenerateValidMoveGrid {
                self.performAIMove(opponent: artificialOpponent) {
                    self.beginNextTurn()
                }
            }
        }
        
    }
    
    func regenerateValidMoveGrid(completion: @escaping () -> ()){
        self.state = .working
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.validMoveGrid = ChessGrid(repeating: ValidMoveCollection())
            let allMoves = self.game.allMoves(team: self.game.turn)
            let validMoves = self.checkHandler.validMoves(possibleMoves: allMoves, game: self.game)
            
            for validMove in validMoves {
                self.validMoveGrid[validMove.origin].insert(validMove)
            }
            
            DispatchQueue.main.async {
                completion()
            }
            
            
        }
        
        
    }
    
    func performAIMove(opponent: ArtificialIntelligence, callback: () -> ()) {
        self.state = .aiThinking(name: opponent.name)
        
        let minimumThinkingTime = DispatchTime.now() + DispatchTimeInterval.seconds(1)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let nextMove = opponent.nextMove(game: self.game)
            
            DispatchQueue.main.asyncAfter(deadline: minimumThinkingTime) {
                
                self.select(nextMove.origin)
                
                let selectionDelay = DispatchTime.now() + DispatchTimeInterval.seconds(Int(0.8))
                
                DispatchQueue.main.asyncAfter(deadline: selectionDelay){
                    self.perform(move: nextMove)
                }
                
                
                
            }
            
        }
        
    }
    
    func moves(position: Position) -> Set<Move>? {
        let moves = validMoveGrid[position]
        return moves.isEmpty ? nil : moves
    }
    
    func select(_ position: Position){
        
        switch selection {
            
        case .none:
            guard let moves = moves(position: position) else {
                return
            }
            self.selection = Selection(moves: moves, origin: position)
            
        case .some(let selection):
            
            if let moves = moves(position: position){
                self.selection = Selection(moves: moves, origin: position)
            } else if let selectedMove = selection.move(position: position) {
                perform(move: selectedMove)
                return
            } else {
                self.selection = nil
            }
                
            
        }
        
    }
    
    func perform(move: Move){
        game = game.performing(move)
        
        if case .needsPromotion = move.kind {
            
            guard case .human = roster[game.turn.opponent] else {
                handlePromotion(promotionType: Queen.self)
                return
            }
            
            shouldPromptForPromotion.send(move)
            
        } else {
            beginNextTurn()
        }
        
    }
    
    func reverseLastMove(){
        self.game = game.reversingLastMove()
        
        if case .AI(_) = roster[self.game.turn] {
            self.game = game.reversingLastMove()
        }
         beginNextTurn()
        
    }
    
    func handlePromotion(promotionType: Piece.Type){
        let moveToPromote = game.history.last!
        assert(moveToPromote.kind == .needsPromotion)
        
        game = game.reversingLastMove()
        
        let promotionMove = Move(origin: moveToPromote.origin, destination: moveToPromote.destination, capturedPiece: moveToPromote.capturedPiece, kind: .promotion(promotionType.init(owner: game.turn)))
        
        game = game.performing(promotionMove)
        beginNextTurn()
        
    }
    
}
