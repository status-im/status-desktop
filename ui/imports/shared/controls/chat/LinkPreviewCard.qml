import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared.status 1.0

CalloutCard {
    id: root
    
    /// The title of the callout card
    required property string title
    required property string description
    required property string footer
    property StatusAssetSettings logoSettings: StatusAssetSettings {
        width: 28
        height: 28
        bgRadius: bgWidth / 2
    }
    
    property string bannerImageSource: ""

    signal clicked(var mouse)

    borderWidth: 1
    padding: borderWidth
    implicitHeight: 290
    implicitWidth: 305

    contentItem: ColumnLayout {
        StatusImage {
            id: bannerImage
            Layout.fillWidth: true
            Layout.preferredHeight: 170
            asynchronous: true
            source: root.bannerImageSource
            fillMode: Image.PreserveAspectCrop
            layer.enabled: true
            layer.effect: root.clippingEffect
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 12
            
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: root.description.length ? 28 : 72
                StatusSmartIdenticon {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    asset: root.logoSettings
                    name: root.logoSettings.name
                    visible: !!root.logoSettings.name.length || !!root.logoSettings.emoji.length
                }
                StatusBaseText {
                    text: root.title
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.description
                font.pixelSize: 12
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                color: Theme.palette.baseColor1
                visible: root.description.length
            }
            StatusBaseText {
                id: linkSite
                Layout.fillWidth: true
                text: root.footer
                font.pixelSize: 12
                lineHeight: 16
                lineHeightMode: Text.FixedHeight
                color: Theme.palette.baseColor1
                elide: Text.ElideRight
                verticalAlignment: Text.AlignBottom
                textFormat: Text.RichText
            }
        }
    }
    MouseArea {
        anchors.fill: root
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.clicked(mouse)
    }
}
