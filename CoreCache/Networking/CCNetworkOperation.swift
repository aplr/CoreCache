// MIT License
//
// Copyright (c) 2017 Oliver Borchert (borchero@in.tum.de)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import CorePromises
import Alamofire
import WebParsing

public typealias CCNetworkUrl = String
public typealias CCNetworkRoutingPaths = [String]
public typealias CCNetworkMethod = HTTPMethod
public typealias CCNetworkEncoding = ParameterEncoding
public typealias CCNetworkHeaders = HTTPHeaders
public typealias CCNetworkStatusCodes = CountableClosedRange<Int>

public enum CCNetworkContent {
    
    case parameters(data: WPEncodable?, encoding: CCNetworkEncoding)
    case data(Data)
    
}

public protocol CCNetworkOperation {
    
    associatedtype ResultType
    
    var apiUrl: CCNetworkUrl { get }
    var routingPaths: CCNetworkRoutingPaths { get }
    
    var requestMethod: CCNetworkMethod { get }
    var requestContent: CCNetworkContent { get }
    var requestHeaders: CCNetworkHeaders { get }
    
    var validStatusCodes: CCNetworkStatusCodes { get }
    
    func authorize() -> CPPromise<Void>
    
    func process(data: CPPromise<Data>) -> CPPromise<ResultType>
    func processError(from data: Data) throws -> Error
    
}

public extension CCNetworkOperation {
    
    public var routingPaths: [String] {
        return []
    }
    
    public var requestMethod: CCNetworkMethod {
        return .get
    }
    
    public var requestContent: CCNetworkContent {
        return .parameters(data: nil, encoding: JSONEncoding.default)
    }
    
    public var requestHeaders: CCNetworkHeaders {
        return [:]
    }
    
    public var validStatusCodes: CCNetworkStatusCodes {
        return 200...299
    }
    
    public func authorize() -> CPPromise<Void> {
        return CPPromise(value: ())
    }
    
    public func processError(from data: Data) -> Error {
        return CCNetworkError.invalidStatusCode(WPJson(reading: data))
    }
    
    internal var requestUrl: String {
        return ([apiUrl] + routingPaths).joined(separator: "/")
    }
    
}


