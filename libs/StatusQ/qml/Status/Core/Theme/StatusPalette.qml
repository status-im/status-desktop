import QtQuick

/*!
  Base interface for the palette requirements of presentation layer
 */
QtObject {
    // Generic colors defined by the design style
    required property color baseColor3

    // Application base colors
    required property color appBackgroundColor

    required property color primaryColor1
    required property color primaryColor2
    required property color primaryColor3

    required property color dangerColor1
    required property color dangerColor2
    required property color dangerColor3

    required property color successColor1
    required property color successColor2

    required property color mentionColor1
    required property color mentionColor2
    required property color mentionColor3
    required property color mentionColor4

    required property color pinColor1
    required property color pinColor2
    required property color pinColor3
}
