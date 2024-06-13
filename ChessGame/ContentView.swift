//
// Copyright iOS Mastery.
// All Rights Reserved.


import SwiftUI

struct ContentView: View {
    @State var vm: GameViewModel = GameViewModel(roster: Roster(whitePlayer: .human, blackPlayer: .AI(Mike())))
    
    var body: some View {
        VStack {
         GameView(viewModel: vm)
            
        }
        
    }
}

#Preview {
    ContentView()
}
