import Foundation

@available(macOS 10.15, *)
protocol NetworkingSwizzlerDelegate: AnyObject {
    func taskDidResume(_ task: URLSessionTask)
    func task(_ task: URLSessionTask, didReceiveResponse response: HTTPURLResponse)
    func task(_ task: URLSessionTask, didReceiveData data: Data)
    func task(_ task: URLSessionTask, didCompleteWithError error: Error?)
}

private enum SwizzlingError: Error {
    case classNotFound
    case instancesDoesNotRespondToSelector
}

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

        typealias Function =  @convention(c) (AnyObject, Selector, AnyObject) -> Void
        let originalImp = method_getImplementation(originalMethod)
        let block: @convention(block) (AnyObject, AnyObject) -> Void = { [weak self] sessionConnection, data in
            unsafeBitCast(originalImp, to: Function.self)(sessionConnection, selector, data)

            if let task = sessionConnection.value(forKey: "task") as? URLSessionTask,
               let data = data as? Data {
                self?.delegate?.task(task, didReceiveData: data)
            }
        }

        method_setImplementation(originalMethod, imp_implementationWithBlock(block))
    }

    private func swizzleURLSessionTaskDidReceiveResponse(baseClass: AnyClass) throws {
        let selector = NSSelectorFromString("_didReceiveResponse:sniff:")
        let originalMethod = try originalMethod(baseClass: baseClass, selector: selector)

        typealias Function =  @convention(c) (AnyObject, Selector, AnyObject, Bool) -> Void
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

        typealias Function =  @convention(c) (AnyObject, Selector, AnyObject?) -> Void
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
}
