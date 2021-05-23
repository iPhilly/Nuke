// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import Foundation
import Combine

final class AnyPublisher<Output> {
    private let _sink: (@escaping ((PublisherCompletion) -> Void), @escaping ((Output) -> Void)) -> Cancellable

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    init<P: Publisher>(_ publisher: P) where P.Output == Output {
        self._sink = { onCompletion, onValue in
            let cancellable = publisher.sink(receiveCompletion: {
                switch $0 {
                case .finished: onCompletion(.finished)
                case .failure(let error): onCompletion(.failure(error))
                }
            }, receiveValue: {
                onValue($0)
            })
            return AnyCancellable(cancellable.cancel)
        }
    }

    func sink(receiveCompletion: @escaping ((PublisherCompletion) -> Void), receiveValue: @escaping ((Output) -> Void)) -> Cancellable {
        _sink(receiveCompletion, receiveValue)
    }
}

private final class AnyCancellable: Cancellable {
    let closure: () -> Void

    init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }

    func cancel() {
        closure()
    }
}

enum PublisherCompletion {
    case finished
    case failure(Error)
}
