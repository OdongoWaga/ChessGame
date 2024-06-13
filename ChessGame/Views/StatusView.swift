//
// Copyright iOS Mastery.
// All Rights Reserved.


import SwiftUI

struct StatusView: View {
    var viewModel: GameViewModel
    
    var body: some View {
        VStack{
            HStack{
                Text("\(self.viewModel.state.description)")
                    Spacer()
                
                Spacer()
                
                Text("Turn \(self.viewModel.game.turn.description)")
                
            }
            .padding(.horizontal)
            Button("Reverse", systemImage: "arrow.3.trianglepath"){
                self.viewModel.reverseLastMove()
            }
            .buttonStyle(.borderedProminent)
            .font(.title)
            .disabled(self.viewModel.state != .awaitingInput || self.viewModel.game.history.isEmpty)
        }
    }
}

#Preview {
    StatusViewPreview.previews
}


struct StatusViewPreview: PreviewProvider{
    static var previews: some View{
        Group {
            statusAwaitingInput()
        }
        .previewLayout(.fixed(width: 300, height: 100))
        
    }
    
    static func statusAwaitingInput() -> some View {
        
        let vm = GameViewModel(game: .standard)
        return StatusView(viewModel: vm)
    }
}
