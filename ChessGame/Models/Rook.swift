//
// Copyright iOS Mastery.
// All Rights Reserved.


import Foundation


class Rook: Piece {
    
    required init(owner: Team) {
        super.init(owner: owner)
    }
    
    override var value: Int{
        return 5
    }
    
    
    override func threatenedPositions(position: Position, game: Game) -> BooleanChessGrid {
        let directedPosition = DirectedPosition(position: position, perspective: owner)
        
        let frontMoves = Position.pathConsideringCollisions(team: owner, path: directedPosition.frontSpaces.map({
            $0.position
        }), board: game.board)
        
        let backMoves = Position.pathConsideringCollisions(team: owner, path: directedPosition.backSpaces.map({
            $0.position
        }), board: game.board)
        let leftMoves = Position.pathConsideringCollisions(team: owner, path: directedPosition.leftSpaces.map({
            $0.position
        }), board: game.board)
        let rightMoves = Position.pathConsideringCollisions(team: owner, path: directedPosition.rightSpaces.map({
            $0.position
        }), board: game.board)
        
         let allMoves = frontMoves + backMoves + leftMoves + rightMoves
        
        return BooleanChessGrid(positions: allMoves)
        
    }
    
    override func possibleMoves(position: Position, game: Game) -> Set<Move> {
        return threatenedPositions(position: position, game: game).toMoves(origin: position, board: game.board)
    }
    
    
}
