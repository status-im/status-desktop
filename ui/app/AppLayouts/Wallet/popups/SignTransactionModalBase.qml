import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

import shared.controls 1.0

import utils 1.0

StatusDialog {
    id: root

    required property int loginType // RootStore.loginType -> Constants.LoginType enum

    property Component headerIconComponent

    property bool feesLoading

    property ObjectModel leftFooterContents
    property ObjectModel rightFooterContents: ObjectModel {
        RowLayout {
            Layout.rightMargin: 4
            spacing: Style.current.halfPadding
            StatusFlatButton {
                objectName: "rejectButton"
                Layout.preferredHeight: signButton.height
                text: qsTr("Reject")
                onClicked: root.reject() // close and emit rejected() signal
            }
            StatusButton {
                objectName: "signButton"
                id: signButton
                interactive: !root.feesLoading
                icon.name: Constants.authenticationIconByType[root.loginType]
                text: qsTr("Sign")
                onClicked: root.accept() // close and emit accepted() signal
            }
        }
    }

    property color gradientColor: backgroundColor
    property url fromImageSource
    property url toImageSource
    property alias headerMainText: headerMainText.text
    property alias headerSubTextLayout: headerSubTextLayout.children
    property string infoTagText

    default property alias contents: contentsLayout.children

    width: 480
    padding: 0

    function formatBigNumber(number: string, decimals = -1) {
        if (!number)
            return ""
        const big = SQUtils.AmountsArithmetic.fromString(number)
        const resultNum = decimals === -1 ? big.toFixed() : big.round(decimals).toFixed()
        return resultNum.replace('.', Qt.locale().decimalPoint)
    }

    header: StatusDialogHeader {
        visible: root.title || root.subtitle
        headline.title: root.title
        headline.subtitle: root.subtitle
        actions.closeButton.onClicked: root.closeHandler()

        leftComponent: root.headerIconComponent
    }

    footer: StatusDialogFooter {
        dropShadowEnabled: true

        leftButtons: root.leftFooterContents
        rightButtons: root.rightFooterContents
    }

    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth
        topPadding: 0
        bottomPadding: 0

        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: 4
            spacing: 0

            // header box with gradient
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: -parent.anchors.leftMargin - scrollView.leftPadding
                Layout.rightMargin: -parent.anchors.rightMargin - scrollView.rightPadding
                Layout.preferredHeight: 266 // design
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.gradientColor }
                    GradientStop { position: 1.0; color: root.backgroundColor }
                }

                ColumnLayout {
                    width: 336 // by design
                    spacing: 12
                    anchors.centerIn: parent

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 4
                        spacing: -10
                        StatusRoundedImage {
                            objectName: "fromImage"
                            width: 42
                            height: 42
                            border.width: 2
                            border.color: "transparent"
                            image.source: root.fromImageSource
                        }
                        StatusRoundedImage {
                            objectName: "toImage"
                            width: 42
                            height: 42
                            border.width: 2
                            border.color: Theme.palette.statusBadge.foregroundColor
                            image.source: root.toImageSource
                        }
                    }

                    StatusBaseText {
                        id: headerMainText
                        objectName: "headerText"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        font.weight: Font.DemiBold
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        horizontalAlignment: Text.AlignHCenter
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 22
                    }

                    RowLayout {
                        id: headerSubTextLayout
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4
                    }

                    InformationTag {
                        id: infoTag
                        Layout.alignment: Qt.AlignHCenter
                        asset.name: "info"
                        tagPrimaryLabel.text: root.infoTagText
                        visible: !!root.infoTagText
                    }
                }
            }

            StatusDialogDivider {
                Layout.fillWidth: true
                Layout.bottomMargin: Style.current.bigPadding
            }

            ColumnLayout {
                Layout.fillWidth: true
                id: contentsLayout
            }
        }
    }
}
