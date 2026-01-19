extension String {
    /// Returns a new string where each line after the first is prefixed with the given indentation.
    ///
    /// This is useful for formatting multi-line output where subsequent lines
    /// should be indented relative to the first line (e.g., pretty-printing nested
    /// structures or aligning wrapped text under a label).
    ///
    /// - Parameter indentation: The string to insert before each subsequent line (e.g., "  " or "\t").
    /// - Returns: A new string with the specified indentation applied to every line after the first.
    ///
    /// - Note: The first line is not modified. Empty strings will remain empty.
    ///
    /// - Example:
    /// ```swift
    /// let text = "Title\nline 1\nline 2"
    /// let indented = text.indentedBy("  ")
    /// // indented == "Title\n  line 1\n  line 2"
    /// ```
    func indentedBy(_ indentation: String) -> String {
        split(separator: "\n").joined(separator: "\n" + indentation)
    }
}
