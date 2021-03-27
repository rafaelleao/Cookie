import SwiftUI

struct TextViewer: View {
    @ObservedObject var viewModel: TextViewerViewModel
    
    var body: some View {
        if #available(iOS 15.0, *) {
            contentView
                .searchable(text: $viewModel.searchText,  placement: .navigationBarDrawer(displayMode: .always))
                .autocapitalization(.none)
        } else {
            contentView
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            ScrollView(.vertical, showsIndicators: true, content: {
                text
                    .font(viewModel.font)
                    .multilineTextAlignment(.leading)
            })
            
            Divider()
                .frame(minWidth: 0, maxWidth: .infinity)
        })
            .padding()
            .navigationBarItems( trailing: navigationBarItems )
    }
    
    private var text: Text {
        if #available(iOS 15, *) {
            return Text(viewModel.attributedText)
        } else {
            return Text(viewModel.text)
        }
    }
    
    private var navigationBarItems: some View {
        HStack {
            Button(action: {
                viewModel.share()
            }, label: {
                Image(systemName: "square.and.arrow.up")
            })
            Spacer(minLength: 20.0)
            
            Stepper("", value: .init(get: { viewModel.currentFontSize },
                                     set: { viewModel.currentFontSize = $0} ), in: viewModel.minimumFontSize...viewModel.maximumFontSize)
        }
    }
}

struct TextViewer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TextViewer(viewModel: testViewModel())
        }
    }
    
    static func testViewModel() -> TextViewerViewModel {
        let text =
"""
[ This program prints "Hello World!" and a newline to the screen, its
  length is 106 active command characters. [It is not the shortest.]

  This loop is an "initial comment loop", a simple way of adding a comment
  to a BF program such that you don't have to worry about any command
  characters. Any ".", ",", "+", "-", "<" and ">" characters are simply
  ignored, the "[" and "]" characters just have to be balanced. This
  loop and the commands it contains are ignored because the current cell
  defaults to a value of 0; the 0 value causes this loop to be skipped.
]
++++++++               Set Cell #0 to 8
[
    >++++               Add 4 to Cell #1; this will always set Cell #1 to 4
    [                   as the cell will be cleared by the loop
        >++             Add 2 to Cell #2
        >+++            Add 3 to Cell #3
        >+++            Add 3 to Cell #4
        >+              Add 1 to Cell #5
        <<<<-           Decrement the loop counter in Cell #1
    ]                   Loop until Cell #1 is zero; number of iterations is 4
    >+                  Add 1 to Cell #2
    >+                  Add 1 to Cell #3
    >-                  Subtract 1 from Cell #4
    >>+                 Add 1 to Cell #6
    [<]                 Move back to the first zero cell you find; this will
                        be Cell #1 which was cleared by the previous loop
    <-                  Decrement the loop Counter in Cell #0
]                       Loop until Cell #0 is zero; number of iterations is 8

The result of this is:
Cell no :   0   1   2   3   4   5   6
Contents:   0   0  72 104  88  32   8
Pointer :   ^

>>.                     Cell #2 has value 72 which is 'H'
>---.                   Subtract 3 from Cell #3 to get 101 which is 'e'
+++++++..+++.           Likewise for 'llo' from Cell #3
>>.                     Cell #5 is 32 for the space
<-.                     Subtract 1 from Cell #4 for 87 to give a 'W'
<.                      Cell #3 was set to 'o' from the end of 'Hello'
+++.------.--------.    Cell #3 for 'rl' and 'd'
>>+.                    Add 1 to Cell #5 gives us an exclamation point
>++.                    And finally a newline from Cell #6
"""
        return TextViewerViewModel(text: text, filename: "Filename")
    }
}
