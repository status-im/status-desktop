import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Communities.helpers 1.0

import utils 1.0
import shared.panels 1.0

Control {
    id: root

    // Panel properties:
    property bool preview: false
    property bool accountBoxVisible: true
    property bool networkBoxVisible: true

    // Token object properties:
    /* required */ property TokenObject token // https://bugreports.qt.io/browse/QTBUG-84269
    readonly property bool isAssetPanel: token.type === Constants.TokenType.ERC20

    QtObject {
        id: d

        readonly property int imageSelectorRectSize: root.isAssetPanel ? 104 : 280
        readonly property string infiniteSymbol: "∞"
        readonly property int burnState: token.burnState

        function startAnimation(isBurn) {
            totalbox.highlighted = true

            if(isBurn)
                remainingBox.highlighted = true
        }

        onBurnStateChanged: if(burnState === Constants.ContractTransactionStatus.Completed) d.startAnimation(true)
    }

    implicitWidth: 560 // by design

    contentItem: ColumnLayout {
        id: mainLayout

        spacing: Style.current.padding

        // General artwork representation:
        Rectangle {
            visible: !token.isPrivilegedToken
            Layout.preferredHeight: d.imageSelectorRectSize
            Layout.preferredWidth: Layout.preferredHeight

            radius: root.isAssetPanel ? Layout.preferredWidth / 2 : 8
            color:Theme.palette.baseColor2

            Image {
                id: image

                readonly property rect imageCropRect: token.artworkCropRect

                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                visible: false
                source: token.artworkSource
                sourceClipRect: imageCropRect ? imageCropRect : undefined
            }

            OpacityMask {
                anchors.fill: image
                source: image
                maskSource: parent
            }
        }        

        // Special artwork representation for `Owner and Master Token` tokens:
        PrivilegedTokenArtworkPanel {
            visible: token.isPrivilegedToken
            size: PrivilegedTokenArtworkPanel.Size.Large
            artwork: token.artworkSource
            color: token.color
            isOwner: token.isOwner
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
                        font.pixelSize: Style.current.additionalTextSize
                        color: Theme.palette.baseColor1
                    }

                    RowLayout {
                        spacing: 3

                        StatusBaseText {
                            text: StatusQUtils.Emoji.fromCodePoint("1f525") // :fire: emoji
                            font.pixelSize: Style.current.tertiaryTextFontSize
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
                value: token.symbol
            }

            CustomPreviewBox {
                id: totalbox

                label: qsTr("Total")
                value: token.infiniteSupply ? d.infiniteSymbol : LocaleUtils.numberToLocaleString(token.supply)
                isLoading: !token.infiniteSupply &&
                           ((!root.isAssetPanel && token.remotelyDestructState === Constants.ContractTransactionStatus.InProgress) ||
                            (d.burnState === Constants.ContractTransactionStatus.InProgress))
            }

            CustomPreviewBox {
                id: remainingBox

                readonly property int remainingTokens: root.preview ? token.supply : token.remainingTokens

                label: qsTr("Remaining")
                value: token.infiniteSupply ? d.infiniteSymbol : LocaleUtils.numberToLocaleString(remainingTokens)
                isLoading: !token.infiniteSupply && (d.burnState === Constants.ContractTransactionStatus.InProgress)
            }

            CustomPreviewBox {
                visible: root.isAssetPanel
                label: qsTr("DP")
                value: token.decimals
            }

            CustomPreviewBox {
                visible: !root.isAssetPanel
                label: qsTr("Transferable")
                value: token.transferable ? qsTr("Yes") : qsTr("No")
            }

            CustomPreviewBox {
                visible: !root.isAssetPanel

                label: qsTr("Destructible")
                value: token.remotelyDestruct ? qsTr("Yes") : qsTr("No")
            }

            CustomPreviewBox {
                visible: root.accountBoxVisible

                label: qsTr("Account")
                value: token.accountName
            }

            Rectangle {
                visible: root.networkBoxVisible
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
                        Layout.alignment: Qt.AlignVCenter

                        height: 24
                        width: height
                        source: token.chainIcon ? Style.svg(token.chainIcon) : undefined
                    }

                    StatusBaseText {
                        Layout.alignment: Qt.AlignVCenter

                        text: token.chainName
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: Theme.palette.baseColor1
                    }
                }
            }
        }

        StatusBaseText {
            Layout.fillWidth: true

            text: token.description
            wrapMode: TextEdit.WordWrap
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: 1.2
        }
    }

    Connections {
        target: token

        function onRemotelyDestructStateChanged() {
            if(token.remotelyDestructState === Constants.ContractTransactionStatus.Completed) d.startAnimation(false)
        }
    }
}
