import Foundation
import OSLog

struct SimpleKeyGenerator<Key, Attempt> where Key: FixedWidthInteger, Attempt: FixedWidthInteger {
	private var nextKey: Key

	private let range: ClosedRange<Key>

	private let maxAttempts: Attempt

	init(
		in range: ClosedRange<Key> = Key.zero...Key.max,
		maxAttempts: Attempt = Attempt.max
	) {
		assert(Key.bitWidth <= Attempt.bitWidth)

		nextKey = range.lowerBound
		self.range = range
		self.maxAttempts = maxAttempts
	}

	mutating func generate(
		excluding usedKeys: some Sequence<Key>,
		logFailure: Bool = true
	) throws -> Key {
		let result: Key = nextKey

		var nextKey: Key = self.nextKey
		var attempts: Attempt = 0

		repeat {
			nextKey = wrap(nextKey &+ 1)
			attempts += 1
		} while attempts < maxAttempts && usedKeys.contains(nextKey)

		if attempts >= maxAttempts {
			throw GenerationFailure.attemptsExceeded
		}

		self.nextKey = nextKey

		return result
	}

	private func wrap(_ value: Key) -> Key {
		let stride = range.upperBound - range.lowerBound
		let local = (value - range.lowerBound) % stride
		return local % stride
	}
}

// MARK: - Errors

private extension SimpleKeyGenerator {
	enum GenerationFailure: Error {
		case attemptsExceeded
	}
}