import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.panels 1.0

StatusDialog {
    id: root

    required property string sourceName
    required property string sourceImage
    required property string sourceUrl
    required property int sourceUpdatedAt
    required property string sourceVersion
    required property int tokensCount
    required property var tokensListModel // Expected roles: name, symbol, image, chainName, explorerUrl, isTest

    signal linkClicked(string link)

    QtObject {
        id: d

        readonly property int symbolColumnWidth: 90
        readonly property int addressColumnWidth: 106
        readonly property int externalLinkBtnWidth: 32
    }

    width: 521 // by design
    padding: 0
    horizontalPadding: Style.current.padding

    contentItem: StatusListView {
        id: list

        topMargin: Style.current.padding
        bottomMargin: Style.current.padding
        implicitHeight: contentHeight

        header: ColumnLayout {
            spacing: 20
            width: list.width

            CustomSourceInfoComponent {
                Layout.fillWidth: true
                Layout.margins: Style.current.padding
            }

            Separator {}

            CustomHeaderDelegate {}
        }
        delegate: CustomDelegate {}
        /* This late binding has been added here because without it all
        the items in the list get initialised before the popup is launched
        creating a delay */
        Component.onCompleted: model = Qt.binding(() => root.tokensListModel)
    }

    header: StatusDialogHeader {
        headline.title: qsTr("%1 Token List").arg(root.sourceName)
        headline.subtitle: qsTr("%n token(s)", "", root.tokensCount)
        actions.closeButton.onClicked: root.close()
        leftComponent: StatusSmartIdenticon {
            asset.name: root.sourceImage
            asset.isImage: !!asset.name
        }
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Done")
                type: StatusBaseButton.Type.Normal

                onClicked: close()
            }
        }
    }

    component CustomTextBlock: ColumnLayout {
        id: textBlock

        property string title
        property string text

        Layout.fillWidth: true

        StatusBaseText {
            Layout.fillWidth: true

            text: textBlock.title
        }

        StatusBaseText {
            Layout.fillWidth: true

            text: textBlock.text
            elide: Text.ElideRight
            color: Theme.palette.baseColor1
        }
    }

    component CustomExternalLinkButton: StatusFlatButton {
        id: extButton

        property string link

        Layout.preferredHeight: d.externalLinkBtnWidth
        Layout.preferredWidth: d.externalLinkBtnWidth

        spacing: 0
        textColor: Theme.palette.baseColor1
        textHoverColor: Theme.palette.directColor1
        icon.name: "external-link"
        onClicked: root.linkClicked(link)
    }

    component CustomSourceInfoComponent: ColumnLayout {
        spacing: 20

        RowLayout {
            spacing: Style.current.padding

            CustomTextBlock {
                title: qsTr("Source")
                text: root.sourceUrl
            }

            CustomExternalLinkButton {
                Layout.rightMargin: Style.current.halfPadding

                link: root.sourceUrl
            }
        }

        CustomTextBlock {
            title: qsTr("Version")
            text: root.sourceVersion
        }

        CustomTextBlock {
            title: qsTr("Automatically updates")
            text: qsTr("Last updated %n day(s) ago",
                       "",
                       LocaleUtils.daysBetween(root.sourceUpdatedAt * 1000, Date.now()))
        }
    }

    component CustomHeaderDelegate: RowLayout {
        height: 34
        width: contentItem.width
        spacing: 0

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding

            text: qsTr("Name")
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            Layout.leftMargin: Style.current.padding
            Layout.preferredWidth: d.symbolColumnWidth - Layout.leftMargin
            Layout.alignment: Qt.AlignLeft

            text: qsTr("Symbol")
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            Layout.leftMargin: Style.current.padding
            Layout.preferredWidth: d.addressColumnWidth - Layout.leftMargin
            Layout.alignment: Qt.AlignLeft

            text: qsTr("Address")
            color: Theme.palette.baseColor1
        }

        // Just a filler corresponding to external link column
        Item {
            Layout.leftMargin: Style.current.padding
            Layout.preferredWidth: d.externalLinkBtnWidth
            Layout.rightMargin: Style.current.bigPadding
        }
    }

    component CustomDelegate: Rectangle {
        width: contentItem.width
        height: 64
        color: (sensor.containsMouse || externalLinkBtn.hovered) ? Theme.palette.baseColor2 : "transparent"
        radius: 8

        MouseArea {
            id: sensor

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
        }

        RowLayout {
            spacing: 0
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: Style.current.padding
                spacing: Style.current.padding

                StatusSmartIdenticon {
                    asset.isImage: true
                    asset.name: model.image
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    spacing: 0

                    StatusBaseText {
                        Layout.fillWidth: true

                        text: model.name
                        elide: Text.ElideMiddle
                    }

                    StatusBaseText {
                        Layout.fillWidth: true

                        text: model.chainName + (model.isTest? " " + qsTr("(Test)") : "")
                        elide: Text.ElideMiddle
                        color: Theme.palette.baseColor1
                    }
                }
            }

            StatusBaseText {
                Layout.leftMargin: Style.current.padding
                Layout.preferredWidth: d.symbolColumnWidth - Layout.leftMargin
                Layout.alignment: Qt.AlignLeft

                text: model.symbol
            }

            StatusBaseText {
                Layout.leftMargin: Style.current.padding
                Layout.preferredWidth: d.addressColumnWidth - Layout.leftMargin
                Layout.alignment: Qt.AlignLeft

                text: model.address
                elide: Text.ElideMiddle
            }

            CustomExternalLinkButton {
                id: externalLinkBtn

                Layout.leftMargin: Style.current.padding
                Layout.rightMargin: Style.current.bigPadding

                link: model.explorerUrl
            }
        }
    }
}
