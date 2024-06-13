//
// Copyright iOS Mastery.
// All Rights Reserved.


import SwiftUI

struct GameView: View {
    
    var viewModel: GameViewModel
    @State var checkMate = false
    
    
    var body: some View {
        VStack{
            
            Text("\(viewModel.roster.blackPlayer.description) (black)")
            BoardView(viewModel: viewModel)
            Text("\(viewModel.roster.whitePlayer.description) (white)")
            HStack(alignment: .center){
                StatusView(viewModel: viewModel)
            }
            
        }
        .padding()
        .alert("Checkmate", isPresented: $checkMate){
            
        } message: {
            Text("Game Over. \(viewModel.game.turn.opponent) has won")
        }
        .onReceive(viewModel.checkmateOccured, perform: { _ in
            checkMate = true
        })
        
        
    }
}

#Preview {
    GamePreviews.previews
}

struct GamePreviews: PreviewProvider{
    
    static var previews: some View{
        
        Group {
            gameViewStandardGame()
        }
        
    }
    
    static func gameViewStandardGame() -> some View {
        
        let vm = GameViewModel(roster: Roster(whitePlayer: .human, blackPlayer: .human))
        return GameView(viewModel: vm)
            .previewLayout(.fixed(width: 350, height: 350))
    }
    
}
