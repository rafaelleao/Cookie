import Foundation

@available(macOS 10.15, *)
protocol NetworkingSwizzlerDelegate: AnyObject {
    func taskDidResume(_ task: URLSessionTask)
    func task(_ task: URLSessionTask, didReceiveResponse response: HTTPURLResponse)
    func task(_ task: URLSessionTask, didReceiveData data: Data)
    func task(_ task: URLSessionTask, didCompleteWithError error: Error?)
    func webSocketTask(_ task: URLSessionTask, didSendMessage message: URLSessionWebSocketTask.Message)
    func webSocketTask(_ task: URLSessionTask, didReceiveMessage message: URLSessionWebSocketTask.Message)
}

@available(macOS 10.15, *)
class NetworkingSwizzler {
    static let shared = NetworkingSwizzler()
    weak var delegate: NetworkingSwizzlerDelegate?
    private static var requestInterceptor = ProtocolClassesInterceptor.shared//

    func activate() throws {
        //NSClassFromString("__NSCFURLSessionConnection")
        guard let sessionClass = NSClassFromString("__NSCFURLLocalSessionConnection") else {
            throw SwizzlingError.classNotFound
        }

        try swizzleURLSessionTaskDidReceiveResponse(baseClass: sessionClass)
        try swizzleURLSessionDataTaskDidReceiveData(baseClass: sessionClass)
        try swizzleURLSessionTaskDidCompleteWithError(baseClass: sessionClass)

        guard let webSocketClass = NSClassFromString("__NSURLSessionWebSocketTask") else {
            throw SwizzlingError.classNotFound
        }

        try swizzleResume(baseClass: URLSessionTask.self)
        try swizzleURLSessionWebSocketSendMessageSelector(webSocketClass)
        try swizzleURLSessionWebSocketReceiveMessageSelector(webSocketClass)
    }

    private func originalMethod(baseClass: AnyClass, selector: Selector) throws -> Method {
        guard let method = class_getInstanceMethod(baseClass, selector),
              baseClass.instancesRespond(to: selector)
        else {
            throw SwizzlingError.instancesDoesNotRespondToSelector
        }
        return method
    }

    private func swizzleResume(baseClass: AnyClass) throws {
        let selector = NSSelectorFromString("resume")
        let originalMethod = try originalMethod(baseClass: baseClass, selector: selector)

        typealias Function = @convention(c) (AnyObject, Selector) -> Void
        let originalImp = method_getImplementation(originalMethod)
        let block: @convention(block) (URLSessionTask) -> Void = { [weak self] task in
            unsafeBitCast(originalImp, to: Function.self)(task, selector)
            self?.delegate?.taskDidResume(task)
        }
        method_setImplementation(originalMethod, imp_implementationWithBlock(block))
    }

    private func swizzleURLSessionDataTaskDidReceiveData(baseClass: AnyClass) throws {
        let selector = NSSelectorFromString("_didReceiveData:")
        let originalMethod = try originalMethod(baseClass: baseClass, selector: selector)

        typealias Function = @convention(c) (AnyObject, Selector, AnyObject) -> Void
        let originalImp = method_getImplementation(originalMethod)
        let block: @convention(block) (AnyObject, AnyObject) -> Void = { [weak self] sessionConnection, data in
            unsafeBitCast(originalImp, to: Function.self)(sessionConnection, selector, data)

            if let task = sessionConnection.value(forKey: "task") as? URLSessionTask,
               let data = data as? Data
            {
                self?.delegate?.task(task, didReceiveData: data)
            }
        }

        method_setImplementation(originalMethod, imp_implementationWithBlock(block))
    }

    private func swizzleURLSessionTaskDidReceiveResponse(baseClass: AnyClass) throws {
        let selector = NSSelectorFromString("_didReceiveResponse:sniff:")
        let originalMethod = try originalMethod(baseClass: baseClass, selector: selector)

        typealias Function = @convention(c) (AnyObject, Selector, AnyObject, Bool) -> Void
        let originalImp = method_getImplementation(originalMethod)
        let block: @convention(block) (AnyObject, AnyObject, Bool) -> Void = { [weak self] sessionConnection, response, sniff in

            unsafeBitCast(originalImp, to: Function.self)(sessionConnection, selector, response, sniff)

            if let task = sessionConnection.value(forKey: "task") as? URLSessionTask,
               let response = response as? HTTPURLResponse
            {
                self?.delegate?.task(task, didReceiveResponse: response)
            }
        }

        method_setImplementation(originalMethod, imp_implementationWithBlock(block))
    }

    func swizzleURLSessionTaskDidCompleteWithError(baseClass: AnyClass) throws {
        let selector = NSSelectorFromString("_didFinishWithError:")
        let originalMethod = try originalMethod(baseClass: baseClass, selector: selector)

        typealias Function = @convention(c) (AnyObject, Selector, AnyObject?) -> Void
        let originalImp = method_getImplementation(originalMethod)
        let block: @convention(block) (AnyObject, AnyObject?) -> Void = { [weak self] sessionConnection, error in

            unsafeBitCast(originalImp, to: Function.self)(sessionConnection, selector, error)

            if let task = sessionConnection.value(forKey: "task") as? URLSessionTask {
                let error = error as? Error
                self?.delegate?.task(task, didCompleteWithError: error)
            }
        }

        method_setImplementation(originalMethod, imp_implementationWithBlock(block))
    }

    private func swizzleURLSessionWebSocketSendMessageSelector(_ baseClass: AnyClass) throws {
        let selector = NSSelectorFromString("sendMessage:completionHandler:")
        let originalMethod = try originalMethod(baseClass: baseClass, selector: selector)

        typealias Function = @convention(c) (AnyObject, Selector, AnyObject, AnyObject) -> Void
        let originalImp = method_getImplementation(originalMethod)

        let block: @convention(block) (URLSessionTask, AnyObject, AnyObject) -> Void = { [weak self] task, message, block in
            unsafeBitCast(originalImp, to: Function.self)(task, selector, message, block)

            if let wsMessage = URLSessionWebSocketTask.Message(object: message) {
                self?.delegate?.webSocketTask(task, didSendMessage: wsMessage)
            }
        }

        method_setImplementation(originalMethod, imp_implementationWithBlock(block))
    }

    private func swizzleURLSessionWebSocketReceiveMessageSelector(_ baseClass: AnyClass) throws {
        let selector = NSSelectorFromString("receiveMessageWithCompletionHandler:")
        guard let method = class_getInstanceMethod(baseClass, selector),
              baseClass.instancesRespond(to: selector)
        else {
            throw SwizzlingError.instancesDoesNotRespondToSelector
        }

        typealias NewClosureType = @convention(c) (AnyObject, Selector, AnyObject) -> Void
        let originalImp: IMP = method_getImplementation(method)
        let block: @convention(block) (URLSessionTask, AnyObject) -> Void = { [weak self] task, handler in

            let wrapperHandler = NetworkingSwizzlerHelper.swizzleWebSocketReceiveMessage(withCompleteHandler: handler, responseHandler: { [weak self] str, data, _ in
                var message: URLSessionWebSocketTask.Message?
                if let str {
                    message = .string(str)
                }
                if let data {
                    message = .data(data)
                }
                if let message {
                    self?.delegate?.webSocketTask(task, didReceiveMessage: message)
                }
            }) ?? handler

            let original: NewClosureType = unsafeBitCast(originalImp, to: NewClosureType.self)
            original(task, selector, wrapperHandler as AnyObject)
        }

        method_setImplementation(method, imp_implementationWithBlock(block))
    }
}

@available(macOS 10.15, *)
private extension URLSessionWebSocketTask.Message {
    init?(object: AnyObject) {
        if let strValue = object.value(forKey: "string") as? String {
            self = .string(strValue)
            return
        }
        if let dataValue = object.value(forKey: "data") as? Data {
            self = .data(dataValue)
            return
        }
        return nil
    }
}

@objc(NetworkingSwizzlerHelper) class NetworkingSwizzlerHelper: NSObject {
    static let dataSelector: String = "data"
    static let stringSelector: String = "string"

    @objc static func swizzleWebSocketReceiveMessage(
        withCompleteHandler handler: AnyObject,
        responseHandler: ((String?, Data?, Error?) -> Void)?
    ) -> AnyObject? {
        typealias WebSocketHandler = @convention(block) (NSObject?, NSError?) -> Void

        let originalHandler = unsafeBitCast(handler, to: WebSocketHandler.self)

        let wrapperHandler: WebSocketHandler = { message, error in
            if let message, NSStringFromClass(type(of: message)) == "NSURLSessionWebSocketMessage" {
                if let responseHandler {
                    let body: (string: String?, data: Data?) = {
                        // Basically "switch message as? URLSessionWebSocketTask.Message"
                        if let data = message.perform(
                            Selector(Self.dataSelector)
                        )?.takeUnretainedValue() as? Data {
                            return (nil, data)
                        }
                        if let string = message.perform(
                            Selector(Self.stringSelector)
                        )?.takeUnretainedValue() as? String {
                            return (string, nil)
                        }

                        return (nil, nil)
                    }()
                    responseHandler(body.string, body.data, error)
                }
            }

            originalHandler(message, error)
        }

        return wrapperHandler as AnyObject
    }
}
