//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import Foundation

internal func aes256Crypt(operation: CCOperation,
                          options: CCOptions,
                          keyData: Data,
                          initializationVector: Data?,
                          dataIn: Data) throws -> Data {
    let dataOutLength = dataIn.count + kCCBlockSizeAES128
    guard let dataOut = NSMutableData(length: dataOutLength) else {
        throw JsonWebEncryptionError.encryptionFailed
    }
    let keyData = keyData as NSData
    let dataIn = dataIn as NSData
    let initializationVector = initializationVector as NSData?
    var numBytesOut: size_t = 0
    let algorithm = CCAlgorithm(kCCAlgorithmAES)
    let status: CCCryptorStatus = CCCrypt(operation,
                                          algorithm,
                                          options,
                                          keyData.bytes, keyData.length,
                                          initializationVector?.bytes,
                                          dataIn.bytes, dataIn.length,
                                          dataOut.mutableBytes, dataOut.length,
                                          &numBytesOut)
    guard status == kCCSuccess else {
        throw JsonWebEncryptionError.encryptionFailed
    }
    let startIndex = dataOut.startIndex
    let endIndex = startIndex.advanced(by: numBytesOut)
    return (dataOut as Data).subdata(in: 0..<endIndex)
}

internal func hmac(data: Data, withKey: Data) throws -> Data {
    guard let dataOut = NSMutableData(length: Int(CC_SHA512_DIGEST_LENGTH)) else {
        throw JsonWebEncryptionError.unknownError
    }
    let dataIn = data as NSData
    let keyData = withKey as NSData
    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512),
           keyData.bytes,
           keyData.length,
           dataIn.bytes,
           dataIn.length,
           dataOut.mutableBytes)
    return dataOut as Data
}

internal func generateRandomData(length: Int) throws -> Data {
    var bytes = [Int8](repeating: 0, count: length)
    let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
    guard status == errSecSuccess else { throw JsonWebEncryptionError.failedToGenerateRandomData }
    return Data(bytes: bytes, count: length)
}

internal func secKey(fromModulus modulus: String, exponent: String) throws -> SecKey {
    guard let modulusHex = modulus.hexadecimal,
          let exponentHex = exponent.hexadecimal else { throw JsonWebEncryptionError.invalidKey }
    let keyData = generateRSAPublicKey(with: modulusHex, exponent: exponentHex)
    var error: Unmanaged<CFError>?
    let parsedKey = SecKeyCreateWithData(keyData as NSData,
                                         [
                                             kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                             kSecAttrKeyClass: kSecAttrKeyClassPublic
                                         ] as NSDictionary,
                                         &error)
    if let error = error {
        throw JsonWebEncryptionError.other(error.takeRetainedValue())
    }
    
    guard let key = parsedKey else { throw JsonWebEncryptionError.invalidKey }
    return key
}

/// https://github.com/henrinormak/Heimdall/blob/master/Heimdall/Heimdall.swift
internal func generateRSAPublicKey(with modulus: Data, exponent: Data) -> Data {
    var modulusBytes = modulus.asBytes
    let exponentBytes = exponent.asBytes

    // Make sure modulus starts with a 0x00
    if let prefix = modulusBytes.first, prefix != 0x00 {
        modulusBytes.insert(0x00, at: 0)
    }

    // Lengths
    let modulusLengthOctets = modulusBytes.count.encodedOctets()
    let exponentLengthOctets = exponentBytes.count.encodedOctets()

    // Total length is the sum of components + types
    let totalLengthOctets = (modulusLengthOctets.count + modulusBytes.count +
        exponentLengthOctets.count + exponentBytes.count + 2).encodedOctets()

    // Combine the two sets of data into a single container
    var builder: [CUnsignedChar] = []
    let data = NSMutableData()

    // Container type and size
    builder.append(0x30)
    builder.append(contentsOf: totalLengthOctets)
    data.append(builder, length: builder.count)
    builder.removeAll(keepingCapacity: false)

    // Modulus
    builder.append(0x02)
    builder.append(contentsOf: modulusLengthOctets)
    data.append(builder, length: builder.count)
    builder.removeAll(keepingCapacity: false)
    data.append(modulusBytes, length: modulusBytes.count)

    // Exponent
    builder.append(0x02)
    builder.append(contentsOf: exponentLengthOctets)
    data.append(builder, length: builder.count)
    data.append(exponentBytes, length: exponentBytes.count)

    return Data(bytes: data.bytes, count: data.length)
}
