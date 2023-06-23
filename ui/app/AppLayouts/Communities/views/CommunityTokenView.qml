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

import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.panels 1.0

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design
    property bool preview: false

    // https://bugreports.qt.io/browse/QTBUG-84269
    /* readonly */ property TokenObject token

    readonly property bool isAssetView: token.type === TokenObject.Type.Asset

    readonly property string name: token.name
    readonly property string description: token.description
    readonly property string symbol: token.symbol
    readonly property int supply: token.supply
    readonly property url artworkSource: token.artworkSource
    readonly property rect artworkCropRect: token.artworkCropRect
    readonly property bool infiniteSupply: token.infiniteSupply
    readonly property int remainingTokens: root.preview ? root.supply : token.remainingTokens
    readonly property int deployState: token.deployState
    readonly property string accountName: token.accountName
    readonly property string chainName: token.chainName
    readonly property string chainId: token.chainId
    readonly property string accountAddress: token.accountAddress
    readonly property bool remotelyDestruct: token.remotelyDestruct
    readonly property int remotelyDestructState: token.remotelyDestructState
    readonly property bool transferable: token.transferable
    readonly property string chainIcon: token.chainIcon
    readonly property int decimals: token.decimals

    // Models:
    property var tokenOwnersModel

    signal mintClicked()

    signal airdropRequested(string address)
    signal generalAirdropRequested

    signal remoteDestructRequested(string address)

    QtObject {
        id: d

        readonly property int imageSelectorRectSize: root.isAssetView ? 104 : 280
        readonly property int iconSize: 20
        readonly property string infiniteSymbol: "∞"
        readonly property int burnState: root.token.burnState

        function startAnimation(isBurn) {
            totalbox.highlighted = true

            if(isBurn)
                remainingBox.highlighted = true
        }

        onBurnStateChanged: if(burnState === Constants.ContractTransactionStatus.Completed) d.startAnimation(true)
    }

    padding: 0
    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.padding

        RowLayout {
            visible: !root.preview && ((root.deployState === Constants.ContractTransactionStatus.InProgress) ||
                                       (root.deployState === Constants.ContractTransactionStatus.Failed))
            spacing: Style.current.halfPadding

            StatusDotsLoadingIndicator { visible: (root.deployState === Constants.ContractTransactionStatus.InProgress) }

            StatusIcon {
                visible: (root.deployState === Constants.ContractTransactionStatus.Failed)
                icon: "warning"
                color: Theme.palette.dangerColor1
            }

            StatusBaseText {
                elide: Text.ElideRight
                font.pixelSize: Theme.primaryTextFontSize
                text: (root.deployState === Constants.ContractTransactionStatus.InProgress) ?
                          (root.isAssetView ?
                               qsTr("Asset is being minted") : qsTr("Collectible is being minted")) :
                          (root.deployState === Constants.ContractTransactionStatus.Failed) ?
                              (root.isAssetView ? qsTr("Asset minting failed") : qsTr("Collectible minting failed")) : ""
                color: (root.deployState === Constants.ContractTransactionStatus.Failed) ? Theme.palette.dangerColor1 : Theme.palette.directColor1
            }
        }

        Rectangle {
            Layout.preferredHeight: d.imageSelectorRectSize
            Layout.preferredWidth: Layout.preferredHeight

            radius: root.isAssetView ? Layout.preferredWidth / 2 : 8
            color:Theme.palette.baseColor2
            clip: true

            Image {
                id: image

                readonly property rect imageCropRect: root.artworkCropRect

                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                visible: false
                source: root.artworkSource
                sourceClipRect: imageCropRect ? imageCropRect : undefined
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
                value: root.symbol
            }

            CustomPreviewBox {
                id: totalbox                

                label: qsTr("Total")
                value: root.infiniteSupply ? d.infiniteSymbol : LocaleUtils.numberToLocaleString(root.supply)
                isLoading: !root.infiniteSupply &&
                           ((!root.isAssetView && root.remotelyDestructState === Constants.ContractTransactionStatus.InProgress) ||
                            (d.burnState === Constants.ContractTransactionStatus.InProgress))
            }

            CustomPreviewBox {
                id: remainingBox

                label: qsTr("Remaining")
                value: root.infiniteSupply ? d.infiniteSymbol : LocaleUtils.numberToLocaleString(root.remainingTokens)
                isLoading: !root.infiniteSupply && (d.burnState === Constants.ContractTransactionStatus.InProgress)
            }

            CustomPreviewBox {
                visible: root.isAssetView
                label: qsTr("DP")
                value: root.decimals
            }

            CustomPreviewBox {
                visible: !root.isAssetView
                label: qsTr("Transferable")
                value: root.transferable ? qsTr("Yes") : qsTr("No")
            }

            CustomPreviewBox {
                visible: !root.isAssetView

                label: qsTr("Destructible")
                value: root.remotelyDestruct ? qsTr("Yes") : qsTr("No")
            }

            CustomPreviewBox {
                label: qsTr("Account")
                value: root.accountName
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
                        Layout.alignment: Qt.AlignVCenter

                        height: 24
                        width: height
                        source: Style.svg(root.chainIcon)
                    }

                    StatusBaseText {
                        Layout.alignment: Qt.AlignVCenter

                        text: root.chainName
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: Theme.palette.baseColor1
                    }
                }
            }
        }

        StatusBaseText {
            Layout.fillWidth: true

            text: root.description
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

            onClicked: root.mintClicked()
        }

        SortableTokenHoldersPanel {
            visible: !root.preview

            model: root.tokenOwnersModel
            tokenName: root.name
            showRemotelyDestructMenuItem: !root.isAssetView && root.remotelyDestruct

            Layout.topMargin: Style.current.padding
            Layout.fillWidth: true

            onAirdropRequested: root.airdropRequested(address)
            onGeneralAirdropRequested: root.generalAirdropRequested()
            onRemoteDestructRequested: root.remoteDestructRequested(address)
        }
    }

    Connections {
        target: root.token

        function onRemotelyDestructStateChanged() {
            if(root.remotelyDestructState === Constants.ContractTransactionStatus.Completed) d.startAnimation(false)
        }
    }
}
