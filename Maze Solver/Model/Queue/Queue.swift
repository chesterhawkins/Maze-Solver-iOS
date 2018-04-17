//https://koenig-media.raywenderlich.com/uploads/2017/03/BreadthFirstSearch-Start.playground.zip

public struct Queue<T> {

	fileprivate var list = LinkedList<T>()

	public init() {}

	public var isEmpty: Bool {
		return list.isEmpty
	}

	public mutating func enqueue(_ element: T) {
		list.append(element)
	}

	public mutating func dequeue() -> T? {
		guard !list.isEmpty, let element = list.first else { return nil }

		_ = list.remove(element)

		return element.value
	}

	public func peek() -> T? {
		return list.first?.value
	}
}

extension Queue: CustomStringConvertible {
	public var description: String {
		return list.description
	}
}
