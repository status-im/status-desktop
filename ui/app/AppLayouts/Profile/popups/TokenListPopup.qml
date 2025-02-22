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

    required property string sourceImage
    required property string sourceUrl
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
    horizontalPadding: Theme.padding

    contentItem: StatusListView {
        id: list

        topMargin: Theme.padding
        bottomMargin: Theme.padding
        implicitHeight: contentHeight

        header: ColumnLayout {
            spacing: 20
            width: list.width

            CustomSourceInfoComponent {
                Layout.fillWidth: true
                Layout.margins: Theme.padding
            }

            Separator {}

            CustomHeaderDelegate {}
        }
        delegate: CustomDelegate {}
        /* This onCompleted has been added here because without it all
        the items in the list get initialised before the popup is launched
        creating a delay */
        Component.onCompleted: model = root.tokensListModel
    }

    header: StatusDialogHeader {
        headline.title: root.title
        headline.subtitle: qsTr("%n token(s)", "", root.tokensCount)
        actions.closeButton.onClicked: root.close()
        leftComponent: StatusSmartIdenticon {
            asset.name: root.sourceImage
            asset.isImage: !!asset.name
        }
    }

    footer: StatusDialogFooter {
        spacing: Theme.padding
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
            spacing: Theme.padding

            CustomTextBlock {
                title: qsTr("Source")
                text: root.sourceUrl
            }

            CustomExternalLinkButton {
                Layout.rightMargin: Theme.halfPadding

                link: root.sourceUrl
            }
        }

        CustomTextBlock {
            title: qsTr("Version")
            text: root.sourceVersion
        }
    }

    component CustomHeaderDelegate: RowLayout {
        height: 34
        width: contentItem.width
        spacing: 0

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding

            text: qsTr("Name")
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            Layout.leftMargin: Theme.padding
            Layout.preferredWidth: d.symbolColumnWidth - Layout.leftMargin
            Layout.alignment: Qt.AlignLeft

            text: qsTr("Symbol")
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            Layout.leftMargin: Theme.padding
            Layout.preferredWidth: d.addressColumnWidth - Layout.leftMargin
            Layout.alignment: Qt.AlignLeft

            text: qsTr("Address")
            color: Theme.palette.baseColor1
        }

        // Just a filler corresponding to external link column
        Item {
            Layout.leftMargin: Theme.padding
            Layout.preferredWidth: d.externalLinkBtnWidth
            Layout.rightMargin: Theme.bigPadding
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
            hoverEnabled: true
        }

        RowLayout {
            spacing: 0
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: Theme.padding
                spacing: Theme.padding

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
                Layout.leftMargin: Theme.padding
                Layout.preferredWidth: d.symbolColumnWidth - Layout.leftMargin
                Layout.alignment: Qt.AlignLeft

                text: model.symbol
            }

            StatusBaseText {
                Layout.leftMargin: Theme.padding
                Layout.preferredWidth: d.addressColumnWidth - Layout.leftMargin
                Layout.alignment: Qt.AlignLeft

                text: model.address
                elide: Text.ElideMiddle
            }

            CustomExternalLinkButton {
                id: externalLinkBtn

                Layout.leftMargin: Theme.padding
                Layout.rightMargin: Theme.bigPadding

                link: model.explorerUrl
            }
        }
    }
}
