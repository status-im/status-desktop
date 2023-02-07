import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import shared.controls 1.0

ColumnLayout {
    id: root
    property alias primaryText: collectibleName.text
    property string secondaryText
    property bool isNarrowMode
    property string networkShortName
    property string networkColor
    property string networkIconURL

    property StatusAssetSettings asset: StatusAssetSettings {
        readonly property int size: root.isNarrowMode ? 24 : 38
        width: size
        height: size
        isImage: true
    }

    Component {
        id: collectibleIdComponent
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            font.pixelSize: isNarrowMode ? 15 : 22
            lineHeight: isNarrowMode ? 22 : 30
            lineHeightMode: Text.FixedHeight
            color: Theme.palette.baseColor1
        }
    }

    RowLayout {
        StatusSmartIdenticon {
            id: identiconLoader
            asset: root.asset
        }

        StatusBaseText {
            id: collectibleName

            font.pixelSize: 22
            lineHeight: 30
            lineHeightMode: Text.FixedHeight
            elide: Text.ElideRight
            color: Theme.palette.directColor1
        }

        Loader {
            id: collectibleIdTopRow
            sourceComponent: collectibleIdComponent
            visible: !root.isNarrowMode

            Binding {
                target: collectibleIdTopRow.item
                property: "text"
                value: root.secondaryText
            }
        }
    }

    RowLayout {
        Layout.leftMargin: root.isNarrowMode ? 0 : 48
        spacing: 10

        Loader {
            id: collectibleIdBottomRow
            sourceComponent: collectibleIdComponent
            visible: root.isNarrowMode

            Binding {
                target: collectibleIdBottomRow.item
                property: "text"
                value: root.secondaryText
            }
        }

        InformationTag {
            id: networkTag
            readonly property bool isNetworkValid: networkShortName !== ""
            image.source: isNetworkValid && networkIconURL !== "" ? Style.svg("tiny/" + networkIconURL) : ""
            tagPrimaryLabel.text: isNetworkValid ? networkShortName : "---"
            tagPrimaryLabel.color: isNetworkValid ? networkColor : "black"
            visible: isNetworkValid
        }
    }
}
