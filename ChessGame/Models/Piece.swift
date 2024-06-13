//
// Copyright iOS Mastery.
// All Rights Reserved.


import SwiftUI


class Piece {
    var owner: Team
    
    required init(owner: Team){
        self.owner = owner
    }
    
    var value: Int{
        return 0
    }
    
    var image: Image{
        let color = owner.description
        let piece = String(describing: type(of: self)).lowercased()
        return Image("\(piece)_\(color)", bundle: Bundle(for: type(of: self)))
        
    }
    //possibleMoves
    func possibleMoves(position: Position, game: Game) -> Set<Move> {
        fatalError("Must be overriden by the subclass")
        
    }
    
    
    //threatenedPositions
    func threatenedPositions(position: Position, game: Game) -> BooleanChessGrid {
        fatalError("Must be overriden by the subclass")
    }
    
    
}

extension Piece: Equatable{
    static func == (lhs: Piece, rhs: Piece) -> Bool {
        guard lhs.owner == rhs.owner && type(of: lhs) == type(of: rhs) else {
            return false
        }
        return true
    }
    
    
    
    
}

extension Piece: Hashable{
    func hash(into hasher: inout Hasher) {
        hasher.combine(owner)
        hasher.combine(String(describing: type(of: self)))
    }
    
}
