// AWS Signature Version 4 for Golfbert (hosted on AWS API Gateway, us-east-1).
// Uses only CryptoKit — no SPM dependency needed.
//
// Required headers per Golfbert docs:
//   x-api-key: <API_KEY>
//   X-Amz-Date: <ISO8601 UTC>
//   Authorization: AWS4-HMAC-SHA256 Credential=<API_KEY>/…, SignedHeaders=…, Signature=…
//
// The API key doubles as the AWS access key / Credential value.

import CryptoKit
import Foundation

struct GolfbertSigner {
    private let apiKey: String    // x-api-key header AND Credential component
    private let secretKey: String // AWS secret for HMAC signing chain
    private let region  = "us-east-1"
    private let service = "execute-api"

    init(apiKey: String, secretKey: String) {
        self.apiKey    = apiKey
        self.secretKey = secretKey
    }

    /// Adds all required AWS SigV4 auth headers to the request in-place.
    func sign(_ request: inout URLRequest) {
        guard let url = request.url, let host = url.host else { return }

        let now       = Date()
        let amzDate   = utcString(from: now, format: "yyyyMMdd'T'HHmmss'Z'")
        let dateStamp = utcString(from: now, format: "yyyyMMdd")

        // Required headers (must match signedHeaders list below)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(host,    forHTTPHeaderField: "Host")
        request.setValue(amzDate, forHTTPHeaderField: "X-Amz-Date")
        request.setValue(apiKey,  forHTTPHeaderField: "x-api-key")

        let signedHeaders    = "content-type;host;x-amz-date;x-api-key"
        let canonicalHeaders = "content-type:application/x-www-form-urlencoded\nhost:\(host)\nx-amz-date:\(amzDate)\nx-api-key:\(apiKey)\n"

        let method       = request.httpMethod ?? "GET"
        let canonicalURI = url.path.isEmpty ? "/" : url.path
        let canonicalQS  = sortedQueryString(from: url)
        let bodyHash     = sha256hex(data: request.httpBody ?? Data())

        let canonicalRequest = [method, canonicalURI, canonicalQS, canonicalHeaders, signedHeaders, bodyHash]
            .joined(separator: "\n")

        let credentialScope = "\(dateStamp)/\(region)/\(service)/aws4_request"
        let stringToSign    = "AWS4-HMAC-SHA256\n\(amzDate)\n\(credentialScope)\n\(sha256hex(string: canonicalRequest))"

        let signature = hmacHex(message: stringToSign, key: signingKey(for: dateStamp))

        request.setValue(
            "AWS4-HMAC-SHA256 Credential=\(apiKey)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)",
            forHTTPHeaderField: "Authorization"
        )
    }

    // MARK: - Key derivation

    private func signingKey(for dateStamp: String) -> SymmetricKey {
        let kSecret  = SymmetricKey(data: Data(("AWS4" + secretKey).utf8))
        let kDate    = SymmetricKey(data: hmacData(message: dateStamp,      key: kSecret))
        let kRegion  = SymmetricKey(data: hmacData(message: region,         key: kDate))
        let kService = SymmetricKey(data: hmacData(message: service,        key: kRegion))
        let kSigning = SymmetricKey(data: hmacData(message: "aws4_request", key: kService))
        return kSigning
    }

    // MARK: - Crypto helpers

    private func hmacData(message: String, key: SymmetricKey) -> Data {
        Data(HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: key))
    }

    private func hmacHex(message: String, key: SymmetricKey) -> String {
        hexString(Data(HMAC<SHA256>.authenticationCode(for: Data(message.utf8), using: key)))
    }

    private func sha256hex(data: Data) -> String {
        hexString(Data(SHA256.hash(data: data)))
    }

    private func sha256hex(string: String) -> String {
        sha256hex(data: Data(string.utf8))
    }

    private func hexString(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Canonical query string

    /// Sort params by name, re-encode values per AWS RFC 3986 rules.
    private func sortedQueryString(from url: URL) -> String {
        guard let comps  = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items  = comps.queryItems, !items.isEmpty else { return "" }
        return items
            .map { ($0.name.awsEncoded, ($0.value ?? "").awsEncoded) }
            .sorted { $0.0 < $1.0 }
            .map { "\($0.0)=\($0.1)" }
            .joined(separator: "&")
    }

    // MARK: - Formatting

    private func utcString(from date: Date, format: String) -> String {
        let f = DateFormatter()
        f.dateFormat = format
        f.timeZone   = TimeZone(identifier: "UTC")
        f.locale     = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }
}

// MARK: - AWS percent-encoding (RFC 3986 unreserved chars only)

private extension String {
    static let awsUnreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
    )

    var awsEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .awsUnreserved) ?? self
    }
}
