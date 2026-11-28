import Foundation

/// A failure with a message suitable for showing to the user, from any Cloud provider.
public struct CloudError: Error, LocalizedError, Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        case unauthorized
        case http(status: Int)
        case transport
        case decoding
    }

    public let kind: Kind
    public let message: String

    public init(kind: Kind, message: String) {
        self.kind = kind
        self.message = message
    }

    public var errorDescription: String? { message }

    /// The "not connected" error actions throw while no server answers.
    public static let notConnected = CloudError(kind: .transport, message: String(localized: "Not connected to the server. Try again when it’s reachable."))

    /// Converts any thrown error (transport, decoding, provider-specific, already-readable) into a `CloudError`.
    public static func wrap(_ error: any Error, operation: String) -> CloudError {
        if let error = error as? CloudError { return error }
        if let convertible = error as? any CloudErrorConvertible {
            return convertible.cloudError(operation: operation)
        }
        return describe(error, operation: operation, causeDescription: nil)
    }

    /// Readable text for transport and decoding failures.
    public static func describe(_ error: any Error, operation: String, causeDescription: String?) -> CloudError {
        let action = NSLocalizedString(operation, comment: "Action that failed")
        if let urlError = error as? URLError {
            return CloudError(kind: .transport, message: String(localized: "\(action): \(NetworkErrorDescription.describe(urlError))"))
        }
        if error is DecodingError {
            return CloudError(kind: .decoding, message: String(localized: "\(action): the server's response could not be read (\(causeDescription ?? String(describing: error)))."))
        }
        return CloudError(kind: .transport, message: String(localized: "\(action): \(causeDescription ?? error.localizedDescription)"))
    }

    /// The message to show for any error.
    public static func message(for error: any Error) -> String {
        (error as? CloudError)?.message ?? error.localizedDescription
    }
}

/// Provider error types (e.g. a generated client's) that know how to describe themselves.
public protocol CloudErrorConvertible: Error {
    func cloudError(operation: String) -> CloudError
}

public enum NetworkErrorDescription {
    public static func describe(_ error: URLError) -> String {
        switch error.code {
        case .appTransportSecurityRequiresSecureConnection:
            String(localized: "iOS blocked plain HTTP to this address (App Transport Security).")
        case .timedOut:
            String(localized: "the server did not answer in time.")
        case .cannotConnectToHost:
            String(localized: "the server refused the connection. Is the Cloud server running?")
        case .cannotFindHost, .dnsLookupFailed:
            String(localized: "the server address could not be found.")
        case .notConnectedToInternet:
            String(localized: "no network connection (or Local Network access is turned off for Photos in Settings › Privacy).")
        case .networkConnectionLost:
            String(localized: "the connection dropped.")
        case .cancelled:
            String(localized: "cancelled.")
        default:
            String(localized: "network error \(String(error.code.rawValue)) (\(error.localizedDescription)).")
        }
    }
}
