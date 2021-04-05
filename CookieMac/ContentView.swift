//
//  ContentView.swift
//  CookieMac
//
//  Created by Rafael Leao on 04.04.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            //Spacer()
            RequestList(viewModel: RequestListViewModel())//.frame(minWidth: 700, minHeight: 300)
            //TextViewer(viewModel: TextViewerViewModel(text: "bla bla", filename: "fil"))


        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
