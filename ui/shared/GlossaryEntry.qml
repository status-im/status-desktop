import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "../shared"

Item {
    id: root
    property string name: ""
    property string description: ""
    property string letter: ""
    height: glossaryEntryTitle.height + Style.current.smallPadding + glossaryEntryDescription.height
    width: parent.width

    GlossaryLetter {
        id: glossaryLetter
        text: root.letter
        anchors.left: parent.left
        anchors.top: glossaryEntryTitle.top
        visible: !!root.letter
    }

    StyledText {
        id: glossaryEntryTitle
        text: root.name
        font.pixelSize: 17
        color: Style.current.textColor
        font.weight: Font.Bold
        anchors.left: parent.left
        anchors.leftMargin: Style.current.bigPadding
    }

    StyledText {
        id: glossaryEntryDescription
        text: root.description
        color: Style.current.textColor
        font.pixelSize: 15
        anchors.top: glossaryEntryTitle.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.bigPadding
        anchors.right: parent.right
        wrapMode: Text.WordWrap
    }
}
