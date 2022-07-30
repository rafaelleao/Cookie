import Combine
import SwiftUI

struct RequestDetailTab: View, Identifiable {
    var id = UUID()
    @ObservedObject var viewModel: RequestDetailTabViewModel
    @Binding var detailPresented: Bool

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }

            SearchBar(text: $viewModel.searchText, placeholder: "Search")

            List {
                if let action = viewModel.action {
                    NavigationLink(destination:
                        TextViewer(viewModel: action.handler())
                            .onAppear(perform: {
                                detailPresented = true
                            })
                            .onDisappear(perform: {
                                detailPresented = false
                            })
                    ) {
                        Text(action.title)
                            .bold()
                    }
                }

                ForEach(viewModel.data, id: \.self) { row in
                    Section(header: Text(row.title)) {
                        ForEach(row.pairs, id: \.key) { pair in
                            let viewModel = RequestDetailRowViewModel(pair: pair, searchText: viewModel.searchText)
                            RequestDetailRow(viewModel: viewModel)
                        }
                    }
                }
            }
        }.tabItem {
            Image(systemName: viewModel.image)
            Text(viewModel.title)
        }
        .listStyle(GroupedListStyle())
    }
}

struct RequestDetailTab_Previews: PreviewProvider {
    static let request = TestRequest.completedTestRequest

    private static func makeSummaryPreview() -> some View {
        let descriptor = SummaryTabDescriptor(request: request)
        let viewModel = RequestDetailTabViewModel(descriptor: descriptor)
        return RequestDetailTab(viewModel: viewModel, detailPresented: .constant(false))
    }

    private static func makeRequestPreview() -> some View {
        let descriptor = RequestTabDescriptor(request: request)
        let viewModel = RequestDetailTabViewModel(descriptor: descriptor)
        return RequestDetailTab(viewModel: viewModel, detailPresented: .constant(false))
    }

    private static func makeResponsePreview() -> some View {
        let descriptor = ResponseTabDescriptor(request: request)
        let viewModel = RequestDetailTabViewModel(descriptor: descriptor)
        return RequestDetailTab(viewModel: viewModel, detailPresented: .constant(false))
    }

    static var previews: some View {
        Group {
            makeSummaryPreview()
                .previewLayout(.sizeThatFits)
            makeRequestPreview()
                .previewLayout(.sizeThatFits)
            makeResponsePreview()
                .previewLayout(.sizeThatFits)
        }
    }
}
