import Foundation
import Combine

class ContentViewModel: ObservableObject {

    @Published var enabled = true
    private var bindings: [AnyCancellable] = []

    init() {
        $enabled.sink { enabled in
            enabled ? Cookie.shared.enable() : Cookie.shared.disable()
        }.store(in: &bindings)
    }

    func show() {
        Cookie.shared.presentViewController()
    }

    func sendTestRequests() {
        let requests = TestRequests().all()
        sendRequests(requests)
    }

    private func sendRequests(_ requests: [URLRequest]) {
        if let request = requests.first {
            let task = URLSession.shared.dataTask(with: request)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                task.resume()
                var new = requests
                new.remove(at: 0)
                sendRequests(new)
            }
        }
    }
}

struct TestRequests {
    
    func all() -> [URLRequest] {
        [
            put(),
            get(),
            getWithParameters(),
            post(),
            delete(),
            patch(),
            get401(),
            getXml(),
            getHtml(),
            getYml(),
            getRepos()
        ]
    }
    
    private func post() -> URLRequest {
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
        return request
    }

    private func put() -> URLRequest  {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        var request = URLRequest(url: url)

        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "PUT"
        let json: [String: Any] = ["foo": "bar",
                                   "abc": ["1": "First", "2": "Second"]]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        return request
    }

    private func patch() -> URLRequest {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        var request = URLRequest(url: url)

        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        let json: [String: Any] = ["title": "bar"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        return request
    }

    private func get() -> URLRequest {
        let url = URL(string: "https://postman-echo.com/delay/10")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    private func getWithParameters() -> URLRequest  {
        let url = URL(string: "http://postman-echo.com/get?foo1=bar1&foo2=bar2")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    private func get401() -> URLRequest {
        let url = URL(string: "https://postman-echo.com/status/401")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    private func delete() -> URLRequest {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/0")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return request
    }

    private func getXml() -> URLRequest {
        let url = URL(string: "https://schemas.xmlsoap.org/soap/envelope/")!
        let request = URLRequest(url: url)
        return request
    }

    private func getRepos() -> URLRequest {
        let url = URL(string: "https://api.github.com/repositories")!
        let request = URLRequest(url: url)
        return request
    }

    private func getHtml() -> URLRequest {
        let url = URL(string: "https://raw.githubusercontent.com/GoogleChrome/samples/gh-pages/index.html")!
        let request = URLRequest(url: url)
        return request
    }

    private func getYml() -> URLRequest {
        let url = URL(string: "https://raw.githubusercontent.com/GoogleChrome/samples/gh-pages/.travis.yml")!
        let request = URLRequest(url: url)
        return request
    }
}
