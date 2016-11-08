//
//  MioAPI.swift
//  MioSwitch
//
//  Created by tanabe on 2016/11/08.
//  Copyright © 2016年 Addon Inc. All rights reserved.
//

import Foundation
import Moya
import Keys

public enum MioAPI {
	case coupon(token: String)
	case packet(token: String)
}

extension MioAPI: TargetType {
	
	public var baseURL: URL { return URL(string: "https://api.iijmio.jp/mobile/d/v1/")! }
	
	public var path: String {
		switch self {
		case .coupon:
			return "coupon/"
		case .packet:
			return "log/packet/"
		}
	}
	
	public var method: Moya.Method {
		return .get
	}
	
	public var parameters: [String: Any]? {
		return nil
	}
	
	public var sampleData: Data {
		switch self {
		case .coupon:
			return "[{\"name\": \"master\"}]".data(using: String.Encoding.utf8)!
		case .packet:
			return "[{\"name\": \"master\"}]".data(using: String.Encoding.utf8)!
		}
	}
	
	var multipartBody: [MultipartFormData]? {
		return nil
	}

	public var task: Task {
		return .request
	}
	
	public func headers() -> [String: String] {
		var assigned: [String: String] = [
			"X-IIJmio-Developer": MioswitchKeys().devID()
		]
		switch self {
		case let .coupon(token: token):
			assigned["X-IIJmio-Authorization"] = token
		case let .packet(token: token):
			assigned["X-IIJmio-Authorization"] = token
		}
		return assigned
	}
	
}

// ヘッダーを有効化するProvider

struct MioProvider {
	static let endpointsClosure = {(target: MioAPI) -> Endpoint<MioAPI> in
		let url = target.baseURL.appendingPathComponent(target.path).absoluteString
		let endpoint: Endpoint<MioAPI> = Endpoint<MioAPI>(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
		return endpoint.adding(newHttpHeaderFields:target.headers())
	}
	
	static func DefaultProvider() -> MoyaProvider<MioAPI> {
		return MoyaProvider(endpointClosure: endpointsClosure)
	}
}


// MARK: - Helpers
private extension String {
	var urlEscapedString: String {
		return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
	}
}
