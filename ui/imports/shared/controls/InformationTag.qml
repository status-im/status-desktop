import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

Control {
    id: root

    property alias image : image
    property alias iconAsset : iconAsset
    property alias tagPrimaryLabel: tagPrimaryLabel
    property alias tagSecondaryLabel: tagSecondaryLabel
    property alias middleLabel: middleLabel
    property alias rightComponent: rightComponent.sourceComponent
    property bool loading: false
    property int secondarylabelMaxWidth: 100

    property Component customBackground: Component {
        Rectangle {
            color: "transparent"
            border.width: 1
            border.color: Theme.palette.baseColor2
            radius: 36
        }
    }

    QtObject {
        id: d
        property var loadingComponent: Component { LoadingComponent {}}
    }

    horizontalPadding: Style.current.halfPadding
    verticalPadding: 5

    background: Loader {
        sourceComponent: root.loading ? d.loadingComponent : root.customBackground
    }

    contentItem: RowLayout {
        spacing: 4
        visible: !root.loading
        // FIXME this could be StatusIcon but it can't load images from an arbitrary URL
        Image {
            id: image
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: visible ? 16 : 0
            Layout.maximumHeight: visible ? 16 : 0
            visible: image.source !== ""
        }
        StatusIcon {
            id: iconAsset
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: visible ? 16 : 0
            Layout.maximumHeight: visible ? 16 : 0
            visible: iconAsset.icon !== ""
        }
        StatusBaseText {
            id: tagPrimaryLabel
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: Style.current.tertiaryTextFontSize
            font.weight: Font.Normal
            color: Theme.palette.directColor1
            visible: text !== ""
        }
        StatusBaseText {
            id: middleLabel
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: Style.current.tertiaryTextFontSize
            font.weight: Font.Normal
            color: Theme.palette.baseColor1
            visible: text !== ""
        }
        StatusBaseText {
            id: tagSecondaryLabel
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: root.secondarylabelMaxWidth
            font.pixelSize: Style.current.tertiaryTextFontSize
            font.weight: Font.Normal
            color: Theme.palette.baseColor1
            visible: text !== ""
            elide: Text.ElideMiddle
        }
        Loader {
            id: rightComponent
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
