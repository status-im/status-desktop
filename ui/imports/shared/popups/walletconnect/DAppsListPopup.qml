import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.controls 1.0

import utils 1.0

StatusDropdown {
    id: root

    objectName: "dappsPopup"

    required property DelegateModel delegateModel

    signal connectDapp()

    width: 312
    padding: 0

    modal: false

    contentItem: ColumnLayout {
        id: mainLayout

        spacing: 0

        ShapeRectangle {
            id: listPlaceholder

            text: qsTr("Connected dApps will appear here")

            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.leftMargin: Theme.halfPadding
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: Layout.leftMargin
            Layout.bottomMargin: 4

            visible: listView.count === 0
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: Theme.halfPadding

            visible: !listPlaceholder.visible

            StatusBaseText {
                text: qsTr("Connected dApps")

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: Theme.tertiaryTextFontSize
                color: Theme.palette.baseColor1
            }
        }

        Item {
            id: listViewWrapper
            Layout.fillWidth: true
            Layout.preferredHeight: listView.contentHeight

            // TODO: uncomment maximumHeight: 290 and remove fillHeight: true
            // after status app upgrades to
            // a Qt version that has ListView scrolling with mouse wheel and
            // touchpad fixed.
            // https://github.com/status-im/status-desktop/issues/15595
            // Layout.maximumHeight: 290
            Layout.fillHeight: true

            visible: !listPlaceholder.visible

            Rectangle {
                id: header
                width: parent.width
                height: 4
                color: Theme.palette.directColor8
                visible: !listView.atYBeginning
            }
            StatusListView {
                id: listView
                anchors.fill: parent
                anchors.leftMargin: Theme.halfPadding
                anchors.rightMargin: anchors.leftMargin
                model: root.delegateModel
            }
            Rectangle {
                id: footer
                anchors.bottom: parent.bottom
                width: parent.width
                height: 4
                color: Theme.palette.directColor8
                visible: !listView.atYEnd
            }
        }

        StatusButton {
            id: connectDappButton
            objectName: "connectDappButton"
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            Layout.leftMargin: Theme.halfPadding
            Layout.rightMargin: Layout.leftMargin
            Layout.bottomMargin: Layout.leftMargin
            Layout.topMargin: 4

            size: StatusButton.Size.Small

            text: qsTr("Connect a dApp")
            onClicked: root.connectDapp()
        }
    }
}
