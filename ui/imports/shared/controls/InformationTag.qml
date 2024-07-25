import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

Control {
    id: root

    property alias tagPrimaryLabel: tagPrimaryLabel
    property alias tagSecondaryLabel: tagSecondaryLabel
    property alias middleLabel: middleLabel
    property alias asset: smartIdenticon.asset
    property alias rightComponent: rightComponent.sourceComponent
    property alias leftComponent: leftComponent.sourceComponent
    property bool loading: false
    property int secondarylabelMaxWidth: 100

    property color backgroundColor: "transparent"
    property color bgBorderColor: Theme.palette.baseColor2
    property real bgRadius: 36

    property Component customBackground: Component {
        Rectangle {
            color: root.backgroundColor
            border.width: 1
            border.color: root.bgBorderColor
            radius: root.bgRadius
        }
    }

    QtObject {
        id: d
        property var loadingComponent: Component { LoadingComponent { radius: root.bgRadius } }
    }

    horizontalPadding: 12
    verticalPadding: 8
    spacing: 4

    background: Loader {
        sourceComponent: root.loading ? d.loadingComponent : root.customBackground
    }

    contentItem: RowLayout {
        spacing: root.spacing
        visible: !root.loading
        Loader {
            id: leftComponent
        }
        StatusSmartIdenticon {
            id: smartIdenticon
            Layout.maximumWidth: visible ? 16 : 0
            Layout.maximumHeight: visible ? 16 : 0
            asset.width: visible ? 16 : 0
            asset.height: visible ? 16 : 0
            asset.bgHeight: visible ? 16 : 0
            asset.bgWidth: visible ? 16 : 0
            asset.color: Theme.palette.directColor1
            visible: !!asset.name
        }
        StatusBaseText {
            id: tagPrimaryLabel
            Layout.maximumWidth: root.availableWidth
            font.pixelSize: Style.current.tertiaryTextFontSize
            visible: text !== ""
            elide: Text.ElideRight
        }
        StatusBaseText {
            id: middleLabel
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: Theme.palette.baseColor1
            visible: text !== ""
        }
        StatusBaseText {
            id: tagSecondaryLabel
            Layout.maximumWidth: root.secondarylabelMaxWidth
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: Theme.palette.baseColor1
            visible: text !== ""
            elide: Text.ElideMiddle
        }
        Loader {
            id: rightComponent
            Layout.preferredWidth: active ? implicitWidth : 0
            active: !!sourceComponent
        }
    }
}
