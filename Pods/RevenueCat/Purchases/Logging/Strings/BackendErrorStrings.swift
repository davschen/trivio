//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  BackendErrorStrings.swift
//
//  Created by Joshua Liebowitz on 10/26/21.

import Foundation

// swiftlint:disable identifier_name
enum BackendErrorStrings {

    // A backend response came back after the Backend object was deallocated.
    case backend_deallocated

    // Backend tried to instantiate a CustomerInfo but for some reason it couldn't.
    case customer_info_instantiation_error(response: [String: Any]?)

    // getOfferings response was totally empty.
    case offerings_empty_response

    // getOfferings object was missing from response.
    case offerings_response_json_error(response: [String: Any])

    // getOfferings response contained no offerings.
    case no_offerings_response_json(response: [String: Any])

    // Posting offerIdForSigning failed due to a signature problem.
    case signature_error(signatureDataString: Any?)

    // getOfferings failed and we're not totally sure why.
    case unknown_get_offerings_error(statusCode: Int, responseString: String?)

}

extension BackendErrorStrings: CustomStringConvertible {

    var description: String {
        switch self {
        case .backend_deallocated:
            return "Received response from getOfferings but Backend was already deallocated, response will be ignored."
        case .customer_info_instantiation_error(let response):
            var message = "Login failed, unable to instantiate \(CustomerInfo.self)"
            if let response = response {
                message += " from:\n \(response.debugDescription)"
            }
            return message
        case .offerings_empty_response:
            return "Unable to parse Offerings object from empty response"
        case .offerings_response_json_error(let response):
            return "Unable to parse Offerings from response:\n\(String(describing: response["offers"]))"
        case .no_offerings_response_json(let response):
            return "No offerings found in response:\n\(String(describing: response["offers"]))"
        case .signature_error(let signatureDataString):
            return "Missing 'signatureData' or its structure changed:\n\(String(describing: signatureDataString))"
        case .unknown_get_offerings_error(let statusCode, let responseString):
            var message = "Encountered an error getting offerings, status code:\(statusCode)"
            if let responseString = responseString {
                message += "\nresponse: \(responseString)"
            }
            return message
        }
    }

}
