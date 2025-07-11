import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme

import utils
import shared
import shared.panels

Item {
    id: root
    property string packThumb: "QmfZrHmLR5VvkXSDbArDR3TX6j4FgpDcrvNz2fHSJk1VvG"
    property string packName: "Status Cat"
    property string packAuthor: "cryptoworld1373"
    property int packNameFontSize: Theme.primaryTextFontSize
    property int spacing: Theme.padding

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
            font.family: Theme.baseFont.name
            font.weight: Font.Bold
            font.pixelSize: packNameFontSize
        }
        StyledText {
            color: Theme.palette.secondaryText
            text: packAuthor
            font.family: Theme.baseFont.name
            font.pixelSize: Theme.primaryTextFontSize
        }
    }

    Separator {
        anchors.top: imgThumb.bottom
        anchors.topMargin: Theme.padding
        anchors.left: parent.left
        anchors.leftMargin: -Theme.padding
        anchors.right: parent.right
        anchors.rightMargin: -Theme.padding
    }
}
