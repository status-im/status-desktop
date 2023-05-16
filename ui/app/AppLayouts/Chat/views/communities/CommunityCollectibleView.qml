import QtQuick 2.15
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0
import shared.panels 1.0

import AppLayouts.Chat.panels.communities 1.0

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design
    property bool preview: false

    // Collectible object properties:
    property alias artworkSource: image.source
    property rect artworkCropRect
    property alias symbol: symbolBox.value
    property alias description: descriptionItem.text
    property alias chainName: chainText.text
    property string name
    property int supplyAmount
    property int remainingTokens
    property bool infiniteSupply
    property bool transferable
    property bool selfDestruct
    property int chainId
    property string chainIcon
    property int deployState: Constants.BackendProcessState.None
    property int remotelyDestructState: Constants.BackendProcessState.None
    property int burnState: Constants.BackendProcessState.None
    property var tokenOwnersModel
    property alias accountName: accountBox.value

    signal mintCollectible(url artworkSource,
                           string name,
                           string symbol,
                           string description,
                           int supply,
                           bool infiniteSupply,
                           bool transferable,
                           bool selfDestruct,
                           int chainId,
                           string accountName)

    QtObject {
        id: d

        readonly property int imageSelectorRectSize: 280
        readonly property int iconSize: 20
        readonly property string infiniteSymbol: "∞"

        function startAnimation(isBurn) {
            totalbox.highlighted = true

            if(isBurn)
                remainingBox.highlighted = true
        }
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height
    padding: 0

    onRemotelyDestructStateChanged: if(remotelyDestructState === Constants.BackendProcessState.Completed) d.startAnimation(false)
    onBurnStateChanged: if(burnState === Constants.BackendProcessState.Completed) d.startAnimation(true)

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.padding

        RowLayout {
            visible: !root.preview && (root.deployState === Constants.BackendProcessState.InProgress)
            spacing: Style.current.halfPadding

            StatusDotsLoadingIndicator {}

            StatusBaseText {
                elide: Text.ElideRight
                font.pixelSize: Theme.primaryTextFontSize
                text: qsTr("Collectible is being minted")
            }
        }

        Rectangle {
            Layout.preferredHeight: d.imageSelectorRectSize
            Layout.preferredWidth: Layout.preferredHeight

            radius: 8
            color:Theme.palette.baseColor2
            clip: true

            Image {
                id: image

                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                visible: false
                sourceClipRect: root.artworkCropRect ? root.artworkCropRect : undefined
            }

            OpacityMask {
                anchors.fill: image
                source: image
                maskSource: parent
            }
        }

        Flow {
            spacing: Style.current.halfPadding
            Layout.fillWidth: true

            component CustomPreviewBox: Rectangle {
                id: previewBox

                property string label
                property string value
                property bool isLoading: false
                property bool highlighted: false

                radius: 8
                border.color: Theme.palette.baseColor2
                implicitWidth: Math.min(boxContent.implicitWidth + Style.current.padding, mainLayout.width)
                implicitHeight: boxContent.implicitHeight + Style.current.padding
                states: [
                    State {
                        when: !previewBox.highlighted
                        PropertyChanges { target: previewBox; color: "transparent" }
                    },
                    State {
                        when: previewBox.highlighted
                        PropertyChanges { target: previewBox; color: Theme.palette.primaryColor3 }
                    }
                ]

                onHighlightedChanged: if(highlighted) animation.start()

                ColumnLayout {
                    id: boxContent
                    anchors.centerIn: parent
                    spacing: 2

                    StatusBaseText {
                        Layout.fillWidth: true
                        text: previewBox.label
                        elide: Text.ElideRight
                        font.pixelSize: 13
                        color: Theme.palette.baseColor1
                    }

                    RowLayout {
                        spacing: 3

                        StatusBaseText {
                            text: StatusQUtils.Emoji.fromCodePoint("1f525") // :fire: emoji
                            font.pixelSize: Theme.tertiaryTextFontSize
                            visible: previewBox.isLoading
                            color: Theme.palette.directColor1
                        }

                        StatusBaseText {
                            Layout.maximumWidth: mainLayout.width - Style.current.padding
                            text: previewBox.value
                            elide: Text.ElideRight
                            font.pixelSize: Theme.primaryTextFontSize
                            color: Theme.palette.directColor1
                        }

                        StatusLoadingIndicator {
                            Layout.preferredHeight: Theme.primaryTextFontSize
                            Layout.preferredWidth: Layout.preferredHeight
                            Layout.leftMargin: 6
                            Layout.rightMargin: 3
                            visible: previewBox.isLoading
                            color: Theme.palette.primaryColor1
                        }
                    }
                }

                Timer {
                    id: animation

                    interval: 1500
                    onRunningChanged: if(!running) previewBox.highlighted = false
                }
            }

            CustomPreviewBox {
                id: symbolBox

                label: qsTr("Symbol")
            }

            CustomPreviewBox {
                id: totalbox

                label: qsTr("Total")
                value: root.infiniteSupply ? d.infiniteSymbol : LocaleUtils.numberToLocaleString(root.supplyAmount)
                isLoading: !root.infiniteSupply &&
                           ((root.remotelyDestructState === Constants.BackendProcessState.InProgress) ||
                            (root.burnState === Constants.BackendProcessState.InProgress))
            }

            CustomPreviewBox {
                id: remainingBox

                label: qsTr("Remaining")
                value: root.infiniteSupply ? d.infiniteSymbol : LocaleUtils.numberToLocaleString(root.remainingTokens)
                isLoading: !root.infiniteSupply && (root.burnState === Constants.BackendProcessState.InProgress)
            }

            CustomPreviewBox {
                label: qsTr("Transferable")
                value: root.transferable ? qsTr("Yes") : qsTr("No")
            }

            CustomPreviewBox {
                label: qsTr("Remotely destructible")
                value: root.selfDestruct ? qsTr("Yes") : qsTr("No")
            }

            CustomPreviewBox {
                id: accountBox

                label: qsTr("Account")
            }

            Rectangle {
                height: symbolBox.height
                width: rowChain.implicitWidth + 2 * Style.current.padding
                border.width: 1
                radius: 8
                border.color: Theme.palette.baseColor2
                color: "transparent"

                RowLayout {
                    id: rowChain

                    anchors.centerIn: parent
                    spacing: Style.current.padding

                    SVGImage {
                        id: chainIcon

                        Layout.alignment: Qt.AlignVCenter
                        height: 24
                        width: height
                        source: Style.svg(root.chainIcon)
                    }

                    StatusBaseText {
                        id: chainText

                        Layout.alignment: Qt.AlignVCenter
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: Theme.palette.baseColor1
                    }
                }
            }
        }

        StatusBaseText {
            id: descriptionItem

            Layout.fillWidth: true
            wrapMode: TextEdit.WordWrap
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: 1.2
        }

        RowLayout {
            visible: root.preview
            Layout.fillWidth: true

            StatusIcon {
                Layout.preferredWidth: d.iconSize
                Layout.preferredHeight: d.iconSize
                Layout.alignment: Qt.AlignTop
                color: Theme.palette.baseColor1
                icon: "info"
            }

            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.baseColor1
                text: qsTr("Make sure you’re happy with your token before minting it as it can’t be edited later")
            }
        }

        StatusButton {
            visible: root.preview
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: Style.current.halfPadding
            text: qsTr("Mint")

            onClicked: {
                root.mintCollectible(root.artworkSource,
                                     root.name,
                                     root.symbol,
                                     root.description,
                                     root.supplyAmount,
                                     root.infiniteSupply,
                                     root.transferable,
                                     root.selfDestruct,
                                     root.chainId,
                                     root.accountName)
            }
        }

        TokenHoldersPanel {
            visible: !root.preview
            tokenName: root.name
            model: root.tokenOwnersModel
            Layout.topMargin: Style.current.padding
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
