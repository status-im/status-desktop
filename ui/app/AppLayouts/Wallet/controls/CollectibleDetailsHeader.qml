import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils

import StatusQ
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme

import shared.controls

Control {
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

    padding: 0

    StatusButton {
        id: explorerButton

        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

        size: StatusBaseButton.Size.Small
        text: root.networkExplorerName
        icon.name: "external"
        onClicked: root.openCollectibleOnExplorer()
        visible: root.explorerLinkEnabled
    }
    StatusButton {
        id: openSeaButton

        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

        size: StatusBaseButton.Size.Small
        text: "OpenSea"
        icon.name: "external"
        onClicked: root.openCollectibleExternally()
        visible: root.collectibleLinkEnabled
    }

    contentItem: ColumnLayout {
        RowLayout {
            id: topRow

            readonly property bool wrapButtons:
                explorerButton.implicitWidth +
                openSeaButton.implicitWidth >= parent.width / 2

            RowLayout {
                StatusBaseText {
                    id: collectibleName

                    Layout.fillWidth: true
                    Layout.horizontalStretchFactor: 0

                    font.pixelSize: Theme.fontSize22
                    lineHeight: 30
                    lineHeightMode: Text.FixedHeight
                    elide: Text.ElideRight
                    color: Theme.palette.directColor1
                }
                StatusBaseText {
                    id: collectibleId

                    Layout.fillWidth: true
                    Layout.minimumWidth: implicitWidth
                    Layout.horizontalStretchFactor: 1

                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    font.pixelSize: Theme.fontSize22
                    lineHeight: 30
                    lineHeightMode: Text.FixedHeight
                    elide: Text.ElideRight
                    color: Theme.palette.baseColor1
                }
            }

            RowLayout {
                visible: !topRow.wrapButtons
                spacing: 12

                LayoutItemProxy {
                    target: explorerButton
                }

                LayoutItemProxy {
                    target: openSeaButton
                }
            }

            ColumnLayout {
                visible: topRow.wrapButtons
                spacing: 12

                LayoutItemProxy {
                    target: explorerButton
                }

                LayoutItemProxy {
                    target: openSeaButton
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

                StatusMouseArea {
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
                asset.name: isNetworkValid && networkIconURL !== "" ? Theme.svg(networkIconURL) : ""
                asset.isImage: true
                tagPrimaryLabel.text: isNetworkValid ? networkShortName : "---"
                tagPrimaryLabel.color: isNetworkValid ? networkColor : "black"
                visible: isNetworkValid
            }
        }
    }
}
