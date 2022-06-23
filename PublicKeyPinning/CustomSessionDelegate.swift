//
//  CustomSessionDelegate.swift
//  PublicKeyPinning
//
//  Created by Mehran on 4/2/1401 AP.
//

import UIKit
import CryptoKit
import CommonCrypto
import Alamofire

class CustomSessionDelegate: SessionDelegate {
    
    private static let publicKeyHash = "d4nkrlYHuWU2tlgWSiZuYeGka+S/3wg8HzhRuDUmQbg="
    
    let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    override func urlSession(_ session: URLSession,
                             task: URLSessionTask,
                             didReceive challenge: URLAuthenticationChallenge,
                             completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return
        }
        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            // Server public key
            guard let serverPublicKey = SecCertificateCopyKey(serverCertificate) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            guard let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            let data:Data = serverPublicKeyData as Data
            // Server Hash key
            let serverHashKey = sha256(data: data)
            // Local Hash Key
            let publickKeyLocal = type(of: self).publicKeyHash
            if (serverHashKey == publickKeyLocal) {
                // Success! This is our server
                print("Public key pinning is successfully completed")
                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                return
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
        }
    }
    
    private func sha256(data : Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
        }
        
        return Data(hash).base64EncodedString()
    }
}
