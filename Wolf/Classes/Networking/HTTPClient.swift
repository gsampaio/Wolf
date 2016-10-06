import Foundation
import Alamofire
import BrightFutures

public protocol HTTPClient {
    var baseURL: URL { get }
    var manager: Manager { get }

    func sendRequest<S: ResponseSerializerType>(_ request: Request,
                     responseSerializer: S,
                     completionHandler: (Response<S.SerializedObject, S.ErrorObject>) -> Void) -> Request
}

public extension HTTPClient {
    func request<R: HTTPResource>(_ resource: R) -> Request {
        let target = HTTPTarget(baseURL: baseURL, resource: resource)
        return manager.request(target)
    }

    func sendRequest<R: HTTPResource>(_ resource: R, completionHandler: (Response<R.Value, R.Error>) -> Void) -> Request {
        return sendRequest(request(resource),
                           responseSerializer: resource.responseSerializer,
                           completionHandler: completionHandler)
    }

    func sendRequest<S: ResponseSerializerType>(_ request: Request,
                     responseSerializer: S,
                     completionHandler: (Response<S.SerializedObject, S.ErrorObject>) -> Void) -> Request {
        return request.validate().response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

public protocol HTTPResource {
    associatedtype Value
    associatedtype Error: Swift.Error

    var path: String { get }
    var method: Alamofire.Method { get }
    var parameters: [String: AnyObject]? { get }
    var headers: [String: String]? { get }
    var parameterEncoding: ParameterEncoding { get }

    func serialize(_ data: Data?, error: NSError?) -> Result<Value, Error>
}

public extension HTTPResource {
    var method: Alamofire.Method {
        return .GET
    }

    var parameters: [String: AnyObject]? {
        return nil
    }

    var headers: [String: String]? {
        return nil
    }

    var parameterEncoding: ParameterEncoding {
        return .URL
    }

    var responseSerializer: ResponseSerializer<Value, Error> {
        return ResponseSerializer { _, _, data, error in
            return self.serialize(data, error: error)
        }
    }
}

struct HTTPTarget<R: HTTPResource>: HTTPTargetProtocol {
    let baseURL: URL
    let resource: R
}

protocol HTTPTargetProtocol {
    associatedtype Resource: HTTPResource

    var baseURL: Foundation.URL { get }
    var resource: Resource { get }
}

extension HTTPTargetProtocol {
    var URL: Foundation.URL {
        return baseURL.appendingPathComponent(resource.path)
    }
}

private extension Manager {
    func request<T: HTTPTargetProtocol>(_ target: T) -> Request {
        return request(target.resource.method,
                       target.URL.absoluteString,
                       parameters: target.resource.parameters,
                       encoding: target.resource.parameterEncoding,
                       headers: target.resource.headers)
    }
}
