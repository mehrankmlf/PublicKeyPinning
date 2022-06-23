# PublicKeyPinning

This is an example implementation of TLS/SSL public key pinning for iOS, using Alamofire. When a client connects to a server over SSL/TLS, the server provides a certificate. That certificate contains a public key. In this example we extract the public key and compare it against a local copy. If the server public key does not match expectations, Alamofire does not trust it and will not connect to the remote server.

## Libraries

- Alamofire
