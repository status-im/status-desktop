import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import AppLayouts.Wallet.controls 1.0

import utils 1.0

Control {
    id: root

    padding: 12

    property bool highlight: false
    property string title: ""
    property string subTitle: ""
    property string tagIcon: ""
    property bool loading: false
    property alias rightSideButtons: rightSideButtonsLoader.sourceComponent
    signal clicked(var mouse)
    signal communityTagClicked(var mouse)
    

    property StatusAssetSettings asset: StatusAssetSettings {
        height: 32
        width: 32
        bgRadius: bgWidth / 2
    }

    background: Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.palette.background
        radius: Theme.radius
        border.width: 1
        border.color: Theme.palette.baseColor2
        layer.enabled: mouseArea.containsMouse || root.highlight
        layer.effect: DropShadow {
            source: background
            horizontalOffset: 0
            verticalOffset: 2
            radius: 16
            samples: 25
            spread: 0
            color: Theme.palette.backdropColor
        }
    }

    contentItem: Item {
        StatusMouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton|Qt.RightButton
            hoverEnabled: true
            onClicked: {
                root.clicked(mouse);
            }
        }
        ColumnLayout {
            id: titleColumn
            anchors.fill: parent
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: root.asset.height
                StatusSmartIdenticon {
                    asset: root.asset
                    active: ((root.asset.isLetterIdenticon ||
                              !!root.asset.name ||
                              !!root.asset.emoji) && !root.showLoadingIndicator)
                    loading: root.loading
                }
                Item { Layout.fillWidth: true }
                Loader {
                    id: rightSideButtonsLoader
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                }
            }

            StatusTextWithLoadingState {
                Layout.fillWidth: true
                Layout.preferredHeight: 22
                Layout.topMargin: Theme.halfPadding
                text: root.title
                elide: Text.ElideRight
                font.weight: Font.Medium
                loading: root.loading
            }

            StatusTextWithLoadingState {
                id: statusListItemSubTitle
                objectName: "statusListItemSubTitle"
                Layout.fillWidth: true
                Layout.preferredHeight: 16
                text: root.subTitle
                font.pixelSize: Theme.tertiaryTextFontSize
                lineHeight: 16
                customColor: !root.enabled || !root.tertiaryTitle ?
                                 Theme.palette.baseColor1 : Theme.palette.directColor1
                visible: !!root.subTitle
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                loading: root.loading
                maximumLineCount: 3
                elide: Text.ElideRight
            }
            Item { Layout.fillHeight: true }

            ManageTokensCommunityTag {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                horizontalPadding: 2
                verticalPadding: 0
                spacing: 0
                visible: !!root.tagIcon
                communityImage: root.tagIcon
                asset.width: 20
                asset.height: 20
                StatusMouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.communityTagClicked(mouse);
                    }
                }
            }
        }
    }
}
