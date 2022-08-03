import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

/*!
    \qmltype StatusAddressPanel
    \inherits Item
    \inqmlmodule StatusQ.Components
    \since StatusQ.Components 0.1
    \brief Show an address as defined efined in design https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?node-id=4222%3A178403 and https://www.figma.com/file/h2Ab3k4wy1Y7SFHEvbcZZx/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop-(Copy)?node-id=1009%3A106451

    Panel's components:
      - Address: displays the rquired \c address property
      - Frame: a rounded frame and the \c 0x icon prefix
      - Copy action: clickable copy icon. Activable using \c showCopy

    \qmlproperty string address address to show
    \qmlproperty bool showCopy if \c true shows the copy action which triggers \c doCopy signal
    \qmlproperty bool autHideCopyIcon if \c true shows the copy action when hovered. \see showCopy
    \qmlproperty alias showFrame if \c true displays frame and \c 0x prefix
    \qmlproperty bool expandable if \c true user can toggle between expanded and compact version; \see expanded
    \qmlproperty bool expanded if \c true show address in full; if \c false show the address in compact mode eliding in the middle

    \qmlproperty font: statusAddress.font

    signal doCopy(string address)

    \see StatusImageCrop for more details

    Usage example:
    \qml
        StatusAddressPanel {
            address: currentAccount.mixedcaseAddress

            autHideCopyIcon: true
            expanded: false

            onDoCopy: (address) => root.store.copyToClipboard(address)
        }
    \endqml
    For a list of components available see StatusQ.
 */
Item {
    id: root

    /*required*/ property string address: ""
    property bool showCopy: true
    property bool autHideCopyIcon: false
    property alias showFrame: frameRect.visible
    property bool expandable: false
    property bool expanded: true

    property alias font: statusAddress.font

    signal doCopy(string address)

    implicitWidth: frameLayout.implicitWidth
    implicitHeight: frameLayout.implicitHeight

    RowLayout {
        id: frameLayout

        anchors.fill: parent

        RowLayout {
            Layout.leftMargin: frameRect.visible ? 8 : undefined // Theme.geometry.halfPadding
            Layout.rightMargin: Layout.leftMargin
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.minimumWidth: 120
            Layout.preferredHeight: 32

            spacing: 6

            StatusIcon {
                icon: "address"

                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 19
                Layout.preferredHeight: 19

                visible: frameRect.visible

                color: Theme.palette.baseColor1
                opacity: 0.5
            }

            // Ensure the eliding is done in the middle of the value not taking into account `0x`
            RowLayout {
                spacing: 0

                Layout.alignment: Qt.AlignVCenter

                StatusBaseText {
                    text: "0x"

                    Layout.alignment: Qt.AlignVCenter

                    font: statusAddress.font
                    color: statusAddress.color
                }

                StatusBaseText {
                    id: statusAddress

                    text: root.address.replace("0x", "").replace("0X", "")

                    Layout.preferredWidth: expanded ? implicitWidth : (implicitWidth * 0.25).toFixed()
                    Layout.alignment: Qt.AlignVCenter

                    font.family: Theme.palette.monoFont.name
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    elide: Text.ElideMiddle
                    color: Theme.palette.baseColor1
                }
            }

            StatusIcon {
                icon: "copy"

                visible: root.autHideCopyIcon ? (mainMouseArea.containsMouse || copyMouseArea.containsMouse )
                                              : root.showCopy

                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: (statusAddress.font.pixelSize * 1.2).toFixed()
                Layout.preferredHeight: Layout.preferredWidth

                color: Theme.palette.baseColor1

                MouseArea {
                    id: copyMouseArea

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.ArrowCursor
                    preventStealing: true

                    onClicked: root.doCopy(root.address)
                    z: frameRect.z + 1
                }

                StatusIcon {
                    icon: parent.icon

                    x: 1
                    y: 1
                    width: parent.width
                    height: parent.height

                    visible: copyMouseArea.containsMouse && !copyMouseArea.pressed

                    color: "black"
                    opacity: 0.4
                    z: parent.z + 1
                }
            }
        }
    }

    Rectangle {
        id: frameRect

        anchors.fill: frameLayout

        color: "transparent"
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: 36
    }

    MouseArea {
        id: mainMouseArea

        anchors.fill: parent

        hoverEnabled: root.expandable || root.autHideCopyIcon
        enabled: (root.autHideCopyIcon && root.showCopy) || root.expandable
        acceptedButtons: root.expandable ? Qt.LeftButton : Qt.NoButton
        cursorShape: root.expandable ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: root.expanded = !root.expanded
        z: frameLayout.z - 1
    }
}
