import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import Qt5Compat.GraphicalEffects

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialogFooter {
    id: root

    /** property to set loading state **/
    property bool loading
    /** property to set estimated time **/
    property string estimatedTime
    /** property to set estimates fees in fiat **/
    property string estimatedFees
    /** property to set error state **/
    property bool error

    /** input property to blur the background of the footer **/
    property var blurSource: null
    /** input property to source size of the blur soruce **/
    property rect blurSourceRect: Qt.rect(0, 0, 0, 0)

    // Signal to propogate Send clicked
    signal reviewSendClicked()

    spacing: Theme.bigPadding
    color: Theme.palette.baseColor3
    dropShadowEnabled: true

    QtObject {
        id: d

        readonly property string emptyText: "--"
        readonly property string loadingText: "XXXXXXXXXX"
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: radius
            anchors.rightMargin: radius
            color: root.color
            visible: !!root.blurSource
            radius: 8

            layer.enabled: !!root.blurSource
            layer.effect: FastBlur {
                radius: 36
            }

            ShaderEffectSource {
                sourceItem: root.blurSource
                anchors.fill: parent
                anchors.leftMargin: Theme.xlPadding - parent.radius
                anchors.rightMargin: -Theme.xlPadding - parent.radius
                sourceRect: root.blurSourceRect
                live: true
            }
        }

        Item {
            anchors.fill: parent
            Rectangle {
                anchors.fill: parent
                color: !!root.blurSource ? Theme.palette.alphaColor(root.color, 0.85) : root.color
                radius: 8

                // cover for the bottom rounded corners
                Rectangle {
                    width: parent.radius
                    height: parent.radius
                    anchors.top: parent.top
                    anchors.left: parent.left
                    color: parent.color
                }
                // cover for the bottom rounded corners
                Rectangle {
                    width: parent.radius
                    height: parent.radius
                    anchors.top: parent.top
                    anchors.right: parent.right
                    color: parent.color
                }
            }

            layer.enabled: root.dropShadowEnabled
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: -3
                samples: 24
                color: Theme.palette.alphaColor(Theme.palette.dropShadow, 0.06)
            }

            StatusDialogDivider {
                anchors.top: parent.top
                width: parent.width
                visible: !root.dropShadowEnabled
            }
        }
    }

    leftButtons: ObjectModel {
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: Theme.padding

            spacing: 0

            StatusBaseText {
                objectName: "estTimeLabel"

                font.weight: Font.Medium
                color: Theme.palette.directColor5
                text: qsTr("Est time")
            }
            StatusTextWithLoadingState {
                id: estimatedTime

                objectName: "estimatedTimeText"

                font.weight: Font.Medium
                customColor: !!root.estimatedTime ? Theme.palette.directColor1:
                                                   Theme.palette.directColor5
                loading: root.loading

                text: !!root.estimatedTime ? root.estimatedTime:
                      root.loading ? d.loadingText : d.emptyText
            }
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter

            spacing: 0

            StatusBaseText {
                objectName: "estFeesLabel"

                font.weight: Font.Medium
                color: Theme.palette.directColor5
                text: qsTr("Est fees")
            }
            StatusTextWithLoadingState {
                id: estimatedFees

                objectName: "estimatedFeesText"

                font.weight: Font.Medium
                customColor: root.error ? Theme.palette.dangerColor1:
                                          !!root.estimatedFees ?
                                              Theme.palette.directColor1:
                                              Theme.palette.directColor5

                loading: root.loading

                text: !!root.estimatedFees ? root.estimatedFees:
                      loading ? d.loadingText : d.emptyText
            }
        }
    }

    rightButtons: ObjectModel {
        StatusButton {
            objectName: "transactionModalFooterButton"

            Layout.rightMargin: Theme.padding
            Layout.maximumHeight: implicitHeight

            disabledColor: Theme.palette.directColor8
            enabled: !!root.estimatedTime &&
                     !!root.estimatedFees &&
                     !root.loading && !root.error

            text: qsTr("Review Send")

            onClicked: root.reviewSendClicked()
        }
    }
}
