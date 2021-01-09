//
//  RestApi.swift
//
//  Created by Sean Liao on 4/9/20.
//

import UIKit

class RestHelper {    
    class func getAmortization(_ request: GetAmortizationRequest, completionUiHandler: @escaping ([PaymentScheduleDto]?, Data?) -> Void, errorUiHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        doWsApi(request, completionHandler: completionUiHandler, errorHandler: errorUiHandler)
    }

    fileprivate class func doWsApi<X:WsRequestable, Y:Decodable>(_ request: X, completionHandler: @escaping (Y?, Data?) -> Void, errorHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        doRest(request, completionHandler: { (data, response) in
            do {
                if response == nil {
                    // offline, no need to process response/data
                    completionHandler(nil, nil)
                } else {
                    let model = try JSONDecoder().decode(Y.self, from: data!)
                    completionHandler(model, data!)
                }
            } catch {
                errorHandler(data, response, error)
            }
        }) { (data, response, error) in
            errorHandler(data, response, error)
        }
    }
    private class func doRest<T:WsRequestable>(_ req: T, completionHandler: @escaping (Data?, HTTPURLResponse?) -> Void, errorHandler: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let url = URL(string: req.url())!
        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 300 // 5 mins (default is 60 sec if not specified).
        request.httpMethod = req.method()
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let headers = req.headers() {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        print("api headers \(request.allHTTPHeaderFields ?? [:])")
        if request.httpMethod == "GET" || request.httpMethod == "DELETE" {
          print("api \(request.httpMethod ?? "") req: \(request)")
        } else {
          let postData = req.postBody()
          print("api req: \(request) \(request.httpMethod ?? ""): \(String(data: postData ?? Data(), encoding: .utf8) ?? "")")
          request.httpBody = postData
        }

        invokeDataTask(request, completionUiHandler: {(data, response) in
            completionHandler(data, response)
        }, errorUiHandler: { (data, response, error, offline) in
            errorHandler(data, response, error)
        })
    }
    private class func invokeDataTask(_ request: URLRequest, retry: Int = 0, completionUiHandler: @escaping (Data?, HTTPURLResponse) -> Void, errorUiHandler: @escaping (Data?, HTTPURLResponse?, Error?, Bool) -> Void) {
        let dataTask = URLSession(configuration: .default).dataTask(with: request, completionHandler: {(data, response, error) in
            DispatchQueue.main.async {
                let httpResponse = response as? HTTPURLResponse
                if let error = error {
                    debugPrint(error)
                    errorUiHandler(data, httpResponse, error, false)
                } else {
                    if let httpResponse = httpResponse {
                        let statusCode = httpResponse.statusCode
                        if statusCode == 200 {
                            if data != nil {
                                print("api resp: \(String(data: data!, encoding: .utf8) ?? "")")
                                completionUiHandler(data, httpResponse)
                            } else {
                                let emptyDataError = NSError(domain: "empty", code: 0, userInfo: [:])
                                errorUiHandler(data, httpResponse, emptyDataError, false) // no error but empty data
                            }
                        } else if statusCode >= 500 {
                            if retry >= 2 {
                                // max retry reached
                                errorUiHandler(data, httpResponse, error, false)
                            } else {
                                // retry
                                let count = retry + 1
                                invokeDataTask(request, retry: count, completionUiHandler: completionUiHandler, errorUiHandler: errorUiHandler)
                            }
                        } else {
                            errorUiHandler(data, httpResponse, error, false)
                        }
                    } else {
                        errorUiHandler(data, httpResponse, nil, false)
                    }
                }
            }
        })
        dataTask.resume()
    }
}

protocol WsRequestable: Codable {
    // protocol definition goes here
    func path() -> String
    func method() -> String
    func queryString() -> String?
    func headers() -> [String: String]?
    func postBody() -> Data?
}

//fileprivate let Host = "https://getIccid.lt.ult.rocks"
extension WsRequestable {
    func url() -> String {
        let str = self.path()
        if str.starts(with: "http") {
            return str
        }

        var url = self.path()
        let mStr = method()
        if mStr == "GET" || mStr == "DELETE" {
            if let queryString = queryString() {
                url += "?" + queryString
            }
        }
        return url
    }

    func method() -> String {
        return "GET"
    }

    func queryString() -> String? {
        return nil
    }

    func headers() -> [String: String]? {
        return nil
    }
    func postBody() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

private struct MyStatic {
    static let URL_service_tmpl = "http://www.pdachoice.com/ras/service/amortization?loan=%.2f&rate=%.3f&terms=%d&extra=%.2f&escrow=%.2f"
    static let KEY_DATA = "data"
    static let KEY_RC = "rc"
    static let KEY_ERROR = "error"
}

struct GetAmortizationRequest: WsRequestable {
    var loanAmt: Double // = 0.0;
    var interestRate: Double // = 5.0;
    var numOfTerms: Int // = 30;
    var escrow: Double // = 0.0;
    var extra: Double // = 0.0;
    
    init(amount: Double, rate: Double, terms: Int, escrow: Double = 0, extra: Double = 0) {
        loanAmt = amount
        interestRate = rate
        numOfTerms = terms
        self.escrow = escrow
        self.extra = extra
    }
    
    
    func path() -> String {
        // "http://www.pdachoice.com/ras/service/amortization?loan=%.2f&rate=%.3f&terms=%d&extra=%.2f&escrow=%.2f"
        let url = String(format: MyStatic.URL_service_tmpl, loanAmt, interestRate, numOfTerms, extra, escrow)
        return url
    }

    func method() -> String {
        return "GET"
    }
}
