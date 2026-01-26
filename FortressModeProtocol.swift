//
//  FortressModeProtocol.swift
//  FortressMode
//
//  Created by Aishwarya Rana on 26/01/26.
//

import Foundation

@objc(FortressModeProtocol)
public protocol FortressModeProtocol {
    func disableTouchID(withReply reply: @escaping (Bool, Error?) -> Void)
    func enableTouchID(withReply reply: @escaping (Bool, Error?) -> Void)
}
