import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Communities.panels 1.0

import utils 1.0

StatusDialog {
    id: root

    // Community related props:
    required property var communitiesStore
    required property string communityId
    required property string communityName
    required property string communityLogo

    // Token related props:
    required property string tokenName
    required property string tokenSymbol
    required property string tokenImage
    required property string tokenAmount
    required property int tokenType // ERC20 or ERC721
    readonly property bool isAssetType : tokenType === Constants.TokenType.ERC20

    signal hideClicked(string tokenSymbol, string tokenName, string tokenImage, bool isAsset)

    QtObject {
        id: d

        readonly property string contentText: root.isAssetType ? qsTr("Congratulations on receiving your first community asset: <br><b>%1 %2 (%3) minted by %4</b>. Community assets are assets that have been minted by a community. As these assets cannot be verified, always double check their origin and validity before interacting with them. If in doubt, ask a trusted member or admin of the relevant community.").arg(root.tokenAmount).arg(root.tokenName).arg(root.tokenSymbol).arg(root.communityName)
                                                               : qsTr("Congratulations on receiving your first community collectible: <br><b>%1 %2 minted by %3</b>. Community collectibles are collectibles that have been minted by a community. As these collectibles cannot be verified, always double check their origin and validity before interacting with them. If in doubt, ask a trusted member or admin of the relevant community.").arg(root.tokenAmount).arg(root.tokenName).arg(root.communityName)

    }

    width: 521 // by design
    padding: 0

    contentItem: StatusScrollView {
        id: scrollView

        contentWidth: availableWidth
        padding: Style.current.padding

        ColumnLayout {
            spacing: Style.current.padding
            width: scrollView.availableWidth

            StatusRoundedImage {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: Style.current.padding
                Layout.preferredWidth: 68
                Layout.preferredHeight: Layout.preferredWidth

                radius: root.isAssetType ? width / 2 : 8
                image.source: root.tokenImage
                showLoadingIndicator: false
                image.fillMode: Image.PreserveAspectCrop
            }

            StatusBaseText {
                Layout.fillWidth: true

                text: d.contentText
                textFormat: Text.RichText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                lineHeight: 1.2
            }

            // Navigate to community button
            StatusListItem {
                Layout.fillWidth: true
                Layout.bottomMargin: Style.current.halfPadding

                title: root.communityName
                border.color: Theme.palette.baseColor2
                asset.name: root.communityLogo
                asset.isImage: true
                asset.isLetterIdenticon: !asset.name
                components: [
                    RowLayout {
                        StatusIcon {
                            Layout.alignment: Qt.AlignVCenter

                            icon: "arrow-right"
                            color: Theme.palette.primaryColor1
                        }

                        StatusBaseText {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: Style.current.padding

                            text: qsTr("Visit Community")
                            font.pixelSize: Style.current.additionalTextSize
                            color: Theme.palette.primaryColor1
                        }
                    }
                ]

                onClicked: {
                    root.close()
                    root.communitiesStore.navigateToCommunity(root.communityId)
                }
            }
        }
    }

    header: StatusDialogHeader {
        headline.title: root.isAssetType ? qsTr("You received your first community asset") : qsTr("You received your first community collectible")
        actions.closeButton.onClicked: root.close()
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                id: hideBtn

                text: root.isAssetType ? qsTr("Hide this asset") : qsTr("Hide this collectible")

                onClicked: {
                    root.close()
                    root.hideClicked(root.tokenSymbol, root.tokenName, root.tokenImage, root.isAssetType)
                }
            }

            StatusButton {
                id: acceptBtn

                text: qsTr("Got it!")

                onClicked: root.close()
            }
        }
    }
}
