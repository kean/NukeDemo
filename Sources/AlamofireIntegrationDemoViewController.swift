// The MIT License (MIT)
//
// Copyright (c) 2015-2024 Alexander Grebenyuk (github.com/kean).

import UIKit
import Nuke
@preconcurrency import Alamofire

final class AlamofireIntegrationDemoViewController: BasicDemoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        pipeline = ImagePipeline {
            $0.dataLoader = AlamofireDataLoader()
            $0.imageCache = ImageCache()
        }
    }
}

/// Implements data loading using Alamofire framework.
public final class AlamofireDataLoader: Nuke.DataLoading {
    public let session: Alamofire.Session

    /// Initializes the receiver with a given Alamofire.SessionManager.
    /// - parameter session: Alamofire.Session.default by default.
    public init(session: Alamofire.Session = Alamofire.Session.default) {
        self.session = session
    }

    // MARK: DataLoading

    // TODO: Simplify DataLoading protocol to better accomodate Alamofire

    /// Loads data using Alamofire.Session.
    public func loadData(with request: URLRequest) async throws -> (AsyncThrowingStream<Data, any Swift.Error>, URLResponse) {
        let task = self.session.streamRequest(request)
        return try await withTaskCancellationHandler {
            try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<(AsyncThrowingStream<Data, any Swift.Error>, URLResponse), any Swift.Error>) in
                var streamContinuation: AsyncThrowingStream<Data, any Swift.Error>.Continuation?
                var didResume = false

                let stream = AsyncThrowingStream<Data, any Swift.Error> { cont in
                    streamContinuation = cont
                }

                task.responseStream { [weak task] streamEvent in
                    switch streamEvent.event {
                    case let .stream(result):
                        switch result {
                        case let .success(data):
                            if !didResume, let response = task?.response {
                                didResume = true
                                continuation.resume(returning: (stream, response))
                            }
                            streamContinuation?.yield(data)
                        }
                    case let .complete(completion):
                        if let error = completion.error {
                            if didResume {
                                streamContinuation?.finish(throwing: error)
                            } else {
                                continuation.resume(throwing: error)
                            }
                        } else {
                            if !didResume {
                                if let response = task?.response {
                                    didResume = true
                                    continuation.resume(returning: (stream, response))
                                } else {
                                    continuation.resume(throwing: URLError(.badServerResponse))
                                    didResume = true
                                }
                            }
                            streamContinuation?.finish()
                        }
                    }
                }
            }
        } onCancel: {
            task.cancel()
        }
    }
}
