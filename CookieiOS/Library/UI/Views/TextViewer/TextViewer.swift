import SwiftUI

struct TextViewer: View {
    @ObservedObject var viewModel: TextViewerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            ScrollView(.vertical, showsIndicators: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, content: {
                Text(viewModel.text)
                    .font(viewModel.font)
                    .multilineTextAlignment(.leading)
            })
            Spacer()
            Divider()
            HStack {
                Stepper("", value: .init(get: { viewModel.currentFontSize },
                                         set: { viewModel.currentFontSize = $0} ), in: viewModel.minimumFontSize...viewModel.maximumFontSize)
                    
            }.frame(minWidth: 0, maxWidth: .infinity)
        }).padding()
    }
}

struct TextViewer_Previews: PreviewProvider {
    static var previews: some View {
        TextViewer(viewModel: testViewModel())
    }

    static func testViewModel() -> TextViewerViewModel {
        let text = """
            CL-USER> (defun hello ()
                       (format t "Hello, World!~%"))
            HELLO
            CL-USER> (hello)
            Hello, World!
            NIL
            CL-USER> 
            """
        return TextViewerViewModel(text: text, filename: "Filename")
    }
}
