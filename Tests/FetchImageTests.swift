// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import XCTest
@testable import Nuke

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
class FetchImageTests: XCTestCase {
    var dataLoader: MockDataLoader!
    var imageCache: MockImageCache!
    var dataCache: MockDataCache!
    var pipeline: ImagePipeline!
    var image: FetchImage!

    override func setUp() {
        super.setUp()

        dataLoader = MockDataLoader()
        imageCache = MockImageCache()
        dataCache = MockDataCache()

        pipeline = ImagePipeline {
            $0.dataLoader = dataLoader
            $0.imageCache = imageCache
            $0.dataCache = dataCache
        }

        image = FetchImage()
        image.pipeline = pipeline
    }

    func testImageLoaded() throws {
        // RECORD
        let record = expect(image.$result.dropFirst()).toPublishSingleValue()

        // WHEN
        image.load(Test.request)
        wait()

        // THEN
        let result = try XCTUnwrap(try XCTUnwrap(record.last))
        XCTAssertTrue(result.isSuccess)
    }
}
