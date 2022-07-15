import QtQml

/// An application section with button and content view
QtObject {
    /// \c NavigationBarSection
    required property Component navigationSection

    /// \c ApplicationContentView
    required property Component content
}
