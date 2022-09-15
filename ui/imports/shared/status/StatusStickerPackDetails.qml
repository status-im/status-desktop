import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import utils 1.0
import shared 1.0
import shared.panels 1.0

Item {
    id: root
    property string packThumb: "QmfZrHmLR5VvkXSDbArDR3TX6j4FgpDcrvNz2fHSJk1VvG"
    property string packName: "Status Cat"
    property string packAuthor: "cryptoworld1373"
    property int packNameFontSize: 15
    property int spacing: Style.current.padding

    height: childrenRect.height
    width: parent.width

    RoundedImage {
        id: imgThumb
        anchors.left: parent.left
        width: 40
        height: 40
        source: packThumb
    }

    Column {
        anchors.left: imgThumb.right
        anchors.leftMargin: root.spacing
        StyledText {
            id: txtPackName
            text: packName
            font.family: Style.current.baseFont.name
            font.weight: Font.Bold
            font.pixelSize: packNameFontSize
        }
        StyledText {
            color: Style.current.secondaryText
            text: packAuthor
            font.family: Style.current.baseFont.name
            font.pixelSize: 15
        }
    }

    Separator {
        anchors.top: imgThumb.bottom
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: -Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: -Style.current.padding
    }
}
