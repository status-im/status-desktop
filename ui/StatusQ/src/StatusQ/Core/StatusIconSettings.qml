import QtQuick 2.13
import StatusQ.Core 0.1

QtObject {
    id: root

    property string name
    property real width
    property real height
    property color color
    property color disabledColor
    property url source
    property int rotation
    property bool isLetterIdenticon
    property int letterSize: emoji ? 11 : (charactersLen == 1 ? _oneLetterSize : _twoLettersSize)
    property int charactersLen: 1
    property string emoji
    property string emojiSize: _emojiSize
    property StatusIconBackgroundSettings background: StatusIconBackgroundSettings {}

    // can't have QtObject { id: d } inside QtObject, using '_' to indicate private
    readonly property int _oneLetterSize: Math.max(15, root.width / 2.0)
    readonly property int _twoLettersSize: Math.max(12, root.width / 2.2)
    readonly property string _emojiSize: "%1x%1".arg(Math.max(16, root.width * 0.6))
}
