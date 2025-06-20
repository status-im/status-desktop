import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Rectangle {
    id: root

    property alias primaryText: primaryText.text
    property alias secondaryText: secondaryText.text
    property alias primaryLabel: primaryText
    property alias secondaryLabel: secondaryText
    property alias tagsModel: tags.model
    property alias tagsDelegate: tags.delegate
    property int maxWidth: 0
    property bool copy: false
    property bool isLoading: false

    signal copyClicked(string textToCopy)

    implicitHeight: root.copy ? 75 : 52
    implicitWidth: layout.width + Theme.xlPadding
    radius: Theme.radius
    border.width: 1
    border.color: Theme.palette.baseColor2
    color: Theme.palette.transparent

    ColumnLayout {
        id: layout
        spacing: 0
        anchors.centerIn: parent
        StatusBaseText {
            id: primaryText
            Layout.maximumWidth: root.maxWidth - Theme.xlPadding
            font.pixelSize: Theme.additionalTextSize
            color: Theme.palette.directColor5
            visible: text
            elide: Text.ElideRight
        }
        RowLayout {
            width: 100
            StatusTextWithLoadingState {
                id: secondaryText
                Layout.maximumWidth: root.maxWidth - Theme.xlPadding - (root.copy ? 50 : 0)
                font.pixelSize: Theme.primaryTextFontSize
                customColor: Theme.palette.directColor1
                visible: text
                elide: Text.ElideRight
                loading: root.isLoading
            }
            CopyToClipBoardButton {
                visible: root.copy
                icon.width: 15
                icon.height: 15
                type: StatusRoundButton.Type.Tertiary
                color: "transparent"
                icon.color: Theme.palette.directColor1
                textToCopy: secondaryText.text
                onCopyClicked: root.copyClicked(textToCopy)
            }
        }
        ScrollView {
            Layout.preferredHeight: 24
            Layout.maximumWidth: root.maxWidth - Theme.xlPadding
            clip: true
            visible: tags.count > 0
            ListView {
                id: tags
                orientation: ListView.Horizontal
                spacing: 10
            }
        }
    }
}
