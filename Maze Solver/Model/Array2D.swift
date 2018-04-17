/*
 https://github.com/raywenderlich/swift-algorithm-club/blob/master/Array2D/Array2D.swift
 Two-dimensional array with a fixed number of rows and columns.
 This is mostly handy for games that are played on a grid, such as chess.
 Performance is always O(1).
 */
public struct Array2D<T> {
    public let columns: Int
    public let rows: Int
    fileprivate var array: [T]
    
    public init(columns: Int, rows: Int, values: [T]) {
        self.columns = columns
        self.rows = rows
        array = values
    }
    
    public subscript(column: Int, row: Int) -> T {
        get {
            precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            return array[row*columns + column]
        }
        set {
            precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            array[row*columns + column] = newValue
        }
    }
    
    func getArray() -> [T] {
        return array
    }
}
