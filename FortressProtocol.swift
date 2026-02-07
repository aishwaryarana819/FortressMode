import Foundation

@objc(FortressProtocol)
protocol FortressProtocol {
    func checkStatus(withReply reply: @escaping (Bool, String) -> Void)
    
    func setTouchID(enabled: Bool, withReply reply: @escaping (Bool, String) -> Void)
    
    func ping(withReply reply: @escaping (Bool) -> Void)
}
