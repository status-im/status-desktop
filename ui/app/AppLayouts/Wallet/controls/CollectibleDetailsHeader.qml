import QtQuick 2.15
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    property alias collectibleName: collectibleName.text
    property alias collectibleId: collectibleId.text

    property string collectionName

    property string communityName
    property string communityId
    property string communityImage

    property string networkShortName
    property string networkColor
    property string networkIconURL
    property string networkExplorerName

    property bool collectibleLinkEnabled
    property bool collectionLinkEnabled
    property bool explorerLinkEnabled

    signal collectionTagClicked()
    signal openCollectibleExternally()
    signal openCollectibleOnExplorer()

    RowLayout {
        RowLayout {
            StatusBaseText {
                id: collectibleName

                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                color: Theme.palette.directColor1
            }
            StatusBaseText {
                id: collectibleId
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                color: Theme.palette.baseColor1
            }
        }

        Item{Layout.fillWidth: true}

        RowLayout {
            spacing: 12
            StatusButton {
                size: StatusBaseButton.Size.Small
                text: root.networkExplorerName
                icon.name: "external"
                onClicked: root.openCollectibleOnExplorer()
                visible: root.explorerLinkEnabled
            }
            StatusButton {
                size: StatusBaseButton.Size.Small
                text: "OpenSea"
                icon.name: "external"
                onClicked: root.openCollectibleExternally()
                visible: root.collectibleLinkEnabled
            }
        }
    }

    RowLayout {
        spacing: 10

        InformationTag {
            id: collectionTag
            readonly property bool isCollection: !!root.collectionName && !root.communityId
            readonly property bool isUnkownCommunity: !!root.communityId && !root.communityName
            property bool copySuccess: false
            asset.name: {
                if (!!root.communityImage) {
                    return root.communityImage
                }
                if (sensor.containsMouse) {
                    return "tiny/external"
                }
                if (root.isCollection) {
                    return "tiny/folder"
                }
                return "tiny/profile"
            }
            asset.isImage: !!root.communityImage
            enabled: root.collectionLinkEnabled || !!root.communityId
            tagPrimaryLabel.text: !!root.communityName ? root.communityName : root.collectionName
            backgroundColor: sensor.containsMouse ? Theme.palette.baseColor5 : Theme.palette.baseColor4
            states: [
                State {
                    name: "copiedCommunity"
                    extend: "unkownCommunityHover"
                    when: collectionTag.copySuccess && collectionTag.isUnkownCommunity
                    PropertyChanges {
                        target: collectionTag
                        asset.name: "tiny/checkmark"
                        asset.color: Theme.palette.successColor1
                    }
                    PropertyChanges {
                        target: statusToolTip
                        text: qsTr("Community address copied")
                    }
                },
                State {
                    name: "unkownCommunityHover"
                    when: collectionTag.isUnkownCommunity && sensor.containsMouse
                    PropertyChanges {
                        target: collectionTag
                        asset.name: "tiny/copy"
                        tagPrimaryLabel.text: qsTr("Community %1").arg(Utils.compactAddress(root.communityId, 4))
                    }
                    PropertyChanges {
                        target: statusToolTip
                        visible: true
                        text: qsTr("Community name could not be fetched")
                    }
                },
                State {
                    name: "unkownCommunity"
                    when: collectionTag.isUnkownCommunity
                    PropertyChanges {
                        target: collectionTag
                        asset.name: "tiny/help"
                        asset.color: Theme.palette.baseColor1
                        tagPrimaryLabel.text: qsTr("Unknown community")
                    }
                }
            ]

            MouseArea {
                id: sensor
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: {
                    if (!containsMouse)
                        collectionTag.copySuccess = false
                }
                onClicked: {
                    if (collectionTag.isUnkownCommunity) {
                        collectionTag.copySuccess = true
                        debounceTimer.restart()
                        ClipboardUtils.setText(root.communityId)
                        return
                    }
                    root.collectionTagClicked()
                }
                Timer {
                    id: debounceTimer
                    interval: 2000
                    running: collectionTag.copySuccess
                    onTriggered: collectionTag.copySuccess = false
                }
            }
            StatusToolTip {
                id: statusToolTip
                visible: false
                delay: 0
                orientation: StatusToolTip.Orientation.Top
            }
        }

        InformationTag {
            id: networkTag
            readonly property bool isNetworkValid: networkShortName !== ""
            asset.name: isNetworkValid && networkIconURL !== "" ? Theme.svg("tiny/" + networkIconURL) : ""
            asset.isImage: true
            tagPrimaryLabel.text: isNetworkValid ? networkShortName : "---"
            tagPrimaryLabel.color: isNetworkValid ? networkColor : "black"
            visible: isNetworkValid
        }
    }
}
