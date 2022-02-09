//
//  NetworkReachability.swift
//  Rafita_app
//
//  Created by Rafael FERNANDEZ on 17/1/22.
//  Copyright © 2022 company_app. All rights reserved.
//

import SystemConfiguration
import Foundation

public class NetworkReachability {

    public enum Connection: String {
        case unavailable = "No Connection"
        case wifi = "WiFi"
        case cellular = "Cellular"
    }

    /// Set to `false` to force NetworkReachability.connection to .none when on cellular connection (default value `true`)
    public var allowsCellularConnection: Bool

    // The notification center on which "reachability changed" events are being posted
    public var notificationCenter: NotificationCenter = NotificationCenter.default

    public var connection: Connection {
        if flags == nil {
            try? setReachabilityFlags()
        }
        
        switch flags?.connection {
        case .unavailable?, nil: return .unavailable
        case .cellular?: return allowsCellularConnection ? .cellular : .unavailable
        case .wifi?: return .wifi
        }
    }
    
    private var reachabilityHandler: ((NetworkReachability?) -> ())?

    fileprivate var isRunningOnDevice: Bool = {
        #if targetEnvironment(simulator)
            return false
        #else
            return true
        #endif
    }()

    public fileprivate(set) var notifierRunning = false
    fileprivate let reachabilityRef: SCNetworkReachability
    fileprivate let reachabilitySerialQueue: DispatchQueue
    fileprivate let notificationQueue: DispatchQueue?
    fileprivate(set) var flags: SCNetworkReachabilityFlags? {
        didSet {
            guard flags != oldValue else { return }
            notifyReachabilityChanged()
        }
    }

    required public init(reachabilityRef: SCNetworkReachability,
                         queueQoS: DispatchQoS = .default,
                         targetQueue: DispatchQueue? = nil,
                         notificationQueue: DispatchQueue? = .main) {
        self.allowsCellularConnection = true
        self.reachabilityRef = reachabilityRef
        self.reachabilitySerialQueue = DispatchQueue(label: "uk.co.ashleymills.reachability", qos: queueQoS, target: targetQueue)
        self.notificationQueue = notificationQueue
    }

    public convenience init(hostname: String,
                            queueQoS: DispatchQoS = .default,
                            targetQueue: DispatchQueue? = nil,
                            notificationQueue: DispatchQueue? = .main) throws {
        guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else {
            throw NetworkReachabilityError.failedToCreateWithHostname(hostname, SCError())
        }
        self.init(reachabilityRef: ref, queueQoS: queueQoS, targetQueue: targetQueue, notificationQueue: notificationQueue)
    }

    public convenience init(queueQoS: DispatchQoS = .default,
                            targetQueue: DispatchQueue? = nil,
                            notificationQueue: DispatchQueue? = .main) throws {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)

        guard let ref = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else {
            throw NetworkReachabilityError.failedToCreateWithAddress(zeroAddress, SCError())
        }

        self.init(reachabilityRef: ref, queueQoS: queueQoS, targetQueue: targetQueue, notificationQueue: notificationQueue)
    }

    deinit {
        stopNotifier()
    }
}

public extension NetworkReachability {
    // MARK: - *** Notifier methods ***
    func startNotifier() throws -> AsyncThrowingStream<NetworkReachability, Error> {
        guard !notifierRunning else { throw NetworkReachabilityError.alreadyRunning }
        let reachability = AsyncThrowingStream(NetworkReachability.self) { [weak self] continuation in
            continuation.onTermination = { @Sendable _ in
//                self?.stopNotifier()
            }
            reachabilityHandler = { reachability in
                if let reachability = reachability {
                    continuation.yield(reachability)
                } else {
                    continuation.finish()
                }
            }
            do {
                try self?.start()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        return reachability
    }
    
    private func start() throws {
        let callback: SCNetworkReachabilityCallBack = { (reachability, flags, info) in
            guard let info = info else { return }

            // `weakifiedReachability` is guaranteed to exist by virtue of our
            // retain/release callbacks which we provided to the `SCNetworkReachabilityContext`.
            let weakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info).takeUnretainedValue()

            // The weak `reachability` _may_ no longer exist if the `NetworkReachability`
            // object has since been deallocated but a callback was already in flight.
            weakifiedReachability.reachability?.flags = flags
        }

        let weakifiedReachability = ReachabilityWeakifier(reachability: self)
        let opaqueWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.passUnretained(weakifiedReachability).toOpaque()

        var context = SCNetworkReachabilityContext(
            version: 0,
            info: UnsafeMutableRawPointer(opaqueWeakifiedReachability),
            retain: { (info: UnsafeRawPointer) -> UnsafeRawPointer in
                let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info)
                _ = unmanagedWeakifiedReachability.retain()
                return UnsafeRawPointer(unmanagedWeakifiedReachability.toOpaque())
            },
            release: { (info: UnsafeRawPointer) -> Void in
                let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info)
                unmanagedWeakifiedReachability.release()
            },
            copyDescription: { (info: UnsafeRawPointer) -> Unmanaged<CFString> in
                let unmanagedWeakifiedReachability = Unmanaged<ReachabilityWeakifier>.fromOpaque(info)
                let weakifiedReachability = unmanagedWeakifiedReachability.takeUnretainedValue()
                let description = weakifiedReachability.reachability?.description ?? "nil"
                return Unmanaged.passRetained(description as CFString)
            }
        )

        if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
            stopNotifier()
            throw NetworkReachabilityError.unableToSetCallback(SCError())
        }

        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
            stopNotifier()
            throw NetworkReachabilityError.unableToSetDispatchQueue(SCError())
        }

        // Perform an initial check
        try setReachabilityFlags()

        notifierRunning = true
    }

    func stopNotifier() {
        defer { notifierRunning = false }

        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
        reachabilityHandler?(nil)
        reachabilityHandler = nil
    }

    var isReachable: Bool {
        return connection != .unavailable
    }
    
    var isReachableViaWWAN: Bool {
        // Check we're not on the simulator, we're REACHABLE and check we're on WWAN
        return connection == .cellular
    }

    var isReachableViaWiFi: Bool {
        return connection == .wifi
    }

    var description: String {
        return flags?.description ?? "unavailable flags"
    }
}

fileprivate extension NetworkReachability {

    func setReachabilityFlags() throws {
        try reachabilitySerialQueue.sync { [unowned self] in
            var flags = SCNetworkReachabilityFlags()
            if !SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags) {
                self.stopNotifier()
                throw NetworkReachabilityError.unableToGetFlags(SCError())
            }
            
            self.flags = flags
        }
    }
    

    func notifyReachabilityChanged() {
        let notify = { [weak self] in
            guard let self = self else { return }
            self.reachabilityHandler?(self)
        }

        // notify on the configured `notificationQueue`, or the caller's (i.e. `reachabilitySerialQueue`)
        notificationQueue?.async(execute: notify) ?? notify()
    }
}

extension SCNetworkReachabilityFlags {

    typealias Connection = NetworkReachability.Connection

    var connection: Connection {
        guard isReachableFlagSet else { return .unavailable }

        // If we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
        #if targetEnvironment(simulator)
        return .wifi
        #else
        var connection = Connection.unavailable

        if !isConnectionRequiredFlagSet {
            connection = .wifi
        }

        if isConnectionOnTrafficOrDemandFlagSet {
            if !isInterventionRequiredFlagSet {
                connection = .wifi
            }
        }

        if isOnWWANFlagSet {
            connection = .cellular
        }

        return connection
        #endif
    }

    var isOnWWANFlagSet: Bool {
        #if os(iOS)
        return contains(.isWWAN)
        #else
        return false
        #endif
    }
    var isReachableFlagSet: Bool {
        return contains(.reachable)
    }
    var isConnectionRequiredFlagSet: Bool {
        return contains(.connectionRequired)
    }
    var isInterventionRequiredFlagSet: Bool {
        return contains(.interventionRequired)
    }
    var isConnectionOnTrafficFlagSet: Bool {
        return contains(.connectionOnTraffic)
    }
    var isConnectionOnDemandFlagSet: Bool {
        return contains(.connectionOnDemand)
    }
    var isConnectionOnTrafficOrDemandFlagSet: Bool {
        return !intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }
    var isTransientConnectionFlagSet: Bool {
        return contains(.transientConnection)
    }
    var isLocalAddressFlagSet: Bool {
        return contains(.isLocalAddress)
    }
    var isDirectFlagSet: Bool {
        return contains(.isDirect)
    }
    var isConnectionRequiredAndTransientFlagSet: Bool {
        return intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }

    var description: String {
        let W = isOnWWANFlagSet ? "W" : "-"
        let R = isReachableFlagSet ? "R" : "-"
        let c = isConnectionRequiredFlagSet ? "c" : "-"
        let t = isTransientConnectionFlagSet ? "t" : "-"
        let i = isInterventionRequiredFlagSet ? "i" : "-"
        let C = isConnectionOnTrafficFlagSet ? "C" : "-"
        let D = isConnectionOnDemandFlagSet ? "D" : "-"
        let l = isLocalAddressFlagSet ? "l" : "-"
        let d = isDirectFlagSet ? "d" : "-"

        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }
}

/**
 `ReachabilityWeakifier` weakly wraps the `NetworkReachability` class
 in order to break retain cycles when interacting with CoreFoundation.

 CoreFoundation callbacks expect a pair of retain/release whenever an
 opaque `info` parameter is provided. These callbacks exist to guard
 against memory management race conditions when invoking the callbacks.

 #### Race Condition

 If we passed `SCNetworkReachabilitySetCallback` a direct reference to our
 `NetworkReachability` class without also providing corresponding retain/release
 callbacks, then a race condition can lead to crashes when:
 - `NetworkReachability` is deallocated on thread X
 - A `SCNetworkReachability` callback(s) is already in flight on thread Y

 #### Retain Cycle

 If we pass `NetworkReachability` to CoreFoundtion while also providing retain/
 release callbacks, we would create a retain cycle once CoreFoundation
 retains our `NetworkReachability` class. This fixes the crashes and his how
 CoreFoundation expects the API to be used, but doesn't play nicely with
 Swift/ARC. This cycle would only be broken after manually calling
 `stopNotifier()` — `deinit` would never be called.

 #### ReachabilityWeakifier

 By providing both retain/release callbacks and wrapping `NetworkReachability` in
 a weak wrapper, we:
 - interact correctly with CoreFoundation, thereby avoiding a crash.
 See "Memory Management Programming Guide for Core Foundation".
 - don't alter the public API of `NetworkReachability.swift` in any way
 - still allow for automatic stopping of the notifier on `deinit`.
 */
private class ReachabilityWeakifier {
    weak var reachability: NetworkReachability?
    init(reachability: NetworkReachability) {
        self.reachability = reachability
    }
}
