import Foundation

class ContentViewModel: ObservableObject {

    @Published var enabled = true

    func show() {
        Cookie.shared.presentViewController()
    }

    func sendTestRequests() {
        sendPut()
        sendGet()
        sendGetWithParameters()
        sendPost()
        sendDelete()
        sendPatch()
        sendGet401()
        getXml()
        getHtml()
        getYml()
        getRepos()
    }

    private func sendPost() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        var request = URLRequest(url: url)

        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Lorem ipsum dolor sit amet, consectetur adipiscing elit", forHTTPHeaderField: "Curabitur ut auctor lorem. Quisque sed sagittis dolor. Aenean quis ultricies ipsum.")

        request.httpMethod = "POST"
        let json: [String: Any] = ["foo": "bar",
                                   "abc": ["1": "First", "2": "Second"]]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        sendRequest(request)
    }

    private func sendPut() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        var request = URLRequest(url: url)

        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "PUT"
        let json: [String: Any] = ["foo": "bar",
                                   "abc": ["1": "First", "2": "Second"]]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        sendRequest(request)
    }

    private func sendPatch() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        var request = URLRequest(url: url)

        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        let json: [String: Any] = ["title": "bar"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        sendRequest(request)
    }

    private func sendGet() {
        let url = URL(string: "https://postman-echo.com/delay/3")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        sendRequest(request)
    }

    private func sendGetWithParameters() {
        let url = URL(string: "http://postman-echo.com/get?foo1=bar1&foo2=bar2")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        sendRequest(request)
    }

    private func sendGet401() {
        let url = URL(string: "https://postman-echo.com/status/401")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        sendRequest(request)
    }

    private func sendDelete() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/0")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        sendRequest(request)
    }

    private func getXml() {
        let url = URL(string: "https://schemas.xmlsoap.org/soap/envelope/")!
        let request = URLRequest(url: url)
        sendRequest(request)
    }

    private func getRepos() {
        let url = URL(string: "https://api.github.com/repositories")!
        let request = URLRequest(url: url)
        sendRequest(request)
    }

    private func getHtml() {
        let url = URL(string: "https://raw.githubusercontent.com/GoogleChrome/samples/gh-pages/index.html")!
        let request = URLRequest(url: url)
        sendRequest(request)
    }

    private func getYml() {
        let url = URL(string: "https://raw.githubusercontent.com/GoogleChrome/samples/gh-pages/.travis.yml")!
        let request = URLRequest(url: url)
        sendRequest(request)
    }

    private func sendRequest(_ request: URLRequest) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
    }
}
