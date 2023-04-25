//
//  ContentView.swift
//  CopyPomodoroFocusTimerAppFromYT
//
//  Created by july on 2023/4/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        HomeView()
            .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
