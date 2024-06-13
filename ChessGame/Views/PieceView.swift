//
// Copyright iOS Mastery.
// All Rights Reserved.


import SwiftUI

struct PieceView: View {
    
    let piece: Piece?
    
    var body: some View {
        ZStack{
            piece?.image
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    PieceView(piece: Pawn(owner: .black))
        .previewLayout(.fixed(width: 250, height: 250))
}
