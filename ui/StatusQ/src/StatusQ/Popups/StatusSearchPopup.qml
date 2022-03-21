import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1


StatusModal {
    id: root
    width: 700
    height: (!!searchResults && (searchResults.count >= 0) && (searchText !== "")) ? (((searchResults.count < 5)) ? 560 : 770) : 142 //970
    anchors.centerIn: parent
    showHeader: false
    showFooter: false

    property string searchText: contentItem.searchText
    property string noResultsLabel: "No results"
    property string defaultSearchLocationText: "Anywhere"
    property bool loading
    property Menu searchOptionsPopupMenu: Menu { }
    property var searchResults: [ ]
    property var searchSelectionButton
    // This function is called to know if the popup accepts clicks in the title
    // If it does not, the clicks on the titles mousearea will be propagated to the main body instead
    property var acceptsTitleClick: function(titleId) {return true}

    signal resultItemClicked(string itemId)
    signal resultItemTitleClicked(string titleId)

    property var formatTimestampFn: function (ts) {
        return ts
    }

    function setSearchSelection(text = "",
                                secondaryText = "",
                                imageSource = "",
                                isIdenticon = "",
                                iconName = "",
                                iconColor = "") {
        searchSelectionButton.primaryText = text
        searchSelectionButton.secondaryText = secondaryText
        searchSelectionButton.image.source = imageSource
        searchSelectionButton.image.isIdenticon = isIdenticon
        searchSelectionButton.iconSettings.name = iconName
        searchSelectionButton.iconSettings.color = iconColor !== ""? iconColor : Theme.palette.primaryColor1
        searchSelectionButton.iconSettings.isLetterIdenticon = !iconName && !imageSource
    }

    function resetSearchSelection() {
        setSearchSelection(defaultSearchLocationText, "", "", false, "", "transparent")
    }

    function forceActiveFocus() {
        contentItem.searchInput.edit.forceActiveFocus()
    }

    onOpened: {
        forceActiveFocus();
    }

    contentItem: Item {
        width: parent.width
        height: root.height
        property alias searchText: inputText.text
        property alias searchInput: inputText

        ColumnLayout {
            id: contentItemColumn
            anchors.fill: parent
            spacing: 0
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 63
                StatusIcon {
                    id: statusIcon
                    width: 40
                    height: 40
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "search"
                    color: Theme.palette.baseColor1
                }

                StatusBaseInput {
                    id: inputText
                    anchors.left: statusIcon.right
                    anchors.leftMargin: 15
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    focus: true
                    font.pixelSize: 28
                    clearable: true
                    showBackground: false
                    font.family: Theme.palette.baseFont.name
                    color: Theme.palette.directColor1
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
                            event.accepted = true
                    }
                }
            }
            StatusMenuSeparator {
                topPadding: 0
                Layout.fillWidth: true
            }
            Item {
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 58
                Button {
                    id: searchOptionsMenuButton

                    Component.onCompleted: {
                        root.searchSelectionButton = searchOptionsMenuButton
                    }

                    property string prefixText: "In"
                    property string primaryText: ""
                    property string secondaryText: ""
                    property StatusIconSettings iconSettings: StatusIconSettings {
                        width: 16
                        height: 16
                        name: ""
                        isLetterIdenticon: false
                        letterSize: 11
                    }

                    property StatusImageSettings image: StatusImageSettings {
                        width: 16
                        height: 16
                        source: ""
                        isIdenticon: false
                    }

                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    implicitWidth: (contentItemRowLayout.width + 24)
                    implicitHeight: 32

                    background: Rectangle {
                        anchors.fill: parent
                        color: Theme.palette.baseColor2
                        radius: 8
                    }

                    contentItem: Item {
                        anchors.fill: parent

                        MouseArea {
                            id: sensor
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.searchOptionsPopupMenu.popup();

                            RowLayout {
                                id: contentItemRowLayout
                                anchors.centerIn: parent
                                spacing: 2
                                StatusBaseText {
                                    color: Theme.palette.directColor1
                                    text: searchOptionsMenuButton.prefixText + ": "
                                    font.weight: Font.Medium
                                }

                                StatusSmartIdenticon {
                                    id: identicon
                                    Layout.preferredWidth: active ? 16 : 0
                                    Layout.preferredHeight: 16
                                    image: searchOptionsMenuButton.image
                                    icon: searchOptionsMenuButton.iconSettings
                                    name: searchOptionsMenuButton.primaryText
                                    active: searchOptionsMenuButton.primaryText !== defaultSearchLocationText &&
                                            (searchOptionsMenuButton.iconSettings.name ||
                                             searchOptionsMenuButton.iconSettings.isLetterIdenticon ||
                                             !!searchOptionsMenuButton.image.source.toString())
                                }

                                StatusBaseText {
                                    color: Theme.palette.directColor1
                                    text: searchOptionsMenuButton.primaryText
                                    font.weight: Font.Medium
                                }
                                StatusIcon {
                                    Layout.preferredWidth: 14.5
                                    Layout.preferredHeight: 17.5
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: !!searchOptionsMenuButton.secondaryText
                                    color: Theme.palette.baseColor1
                                    icon: "next"
                                }
                                StatusIcon {
                                    Layout.preferredWidth: 17.5
                                    Layout.preferredHeight: 17.5
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: !!searchOptionsMenuButton.secondaryText
                                    color: Theme.palette.directColor1
                                    icon: "channel"
                                }
                                StatusBaseText {
                                    color: Theme.palette.directColor1
                                    visible: !!searchOptionsMenuButton.secondaryText
                                    text: searchOptionsMenuButton.secondaryText
                                    font.weight: Font.Medium
                                }
                                StatusIcon {
                                    Layout.preferredWidth: 17.5
                                    Layout.preferredHeight: 14.5
                                    Layout.alignment: Qt.AlignVCenter
                                    icon: "chevron-down"
                                    color: Theme.palette.directColor1
                                }
                            }
                        }
                    }
                }

                StatusFlatRoundButton {
                    id: closeButton
                    width: 32
                    height: 32
                    anchors.left: searchOptionsMenuButton.right
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: (searchOptionsMenuButton.primaryText === defaultSearchLocationText) ? 0.0 : 1.0
                    visible: (opacity > 0.1)
                    type: StatusFlatRoundButton.Type.Secondary
                    icon.name: "close"
                    icon.color: Theme.palette.directColor1
                    icon.width: 20
                    icon.height: 20
                    onClicked: { root.resetSearchSelection(); }
                }
            }

            StatusMenuSeparator { Layout.fillWidth: true; visible: (root.height > 142) }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ListView {
                    id: view
                    anchors.fill: parent
                    anchors {
                        leftMargin: 0
                        rightMargin: 0
                        bottomMargin: 67
                    }
                    visible: (!root.loading && (count > 0))
                    model: root.searchResults
                    ScrollBar.vertical: ScrollBar { }
                    delegate: StatusListItem {
                        width: view.width
                        itemId: model.itemId
                        titleId: model.titleId
                        title: model.title
                        statusListItemTitle.color: model.title.startsWith("@") ? Theme.palette.primaryColor1 : Theme.palette.directColor1
                        subTitle: model.content
                        radius: 0
                        statusListItemSubTitle.height: model.content !== "" ? 20 : 0
                        statusListItemSubTitle.elide: Text.ElideRight
                        statusListItemSubTitle.color: Theme.palette.directColor1
                        icon.isLetterIdenticon: (model.image === "")
                        icon.background.color: model.color
                        titleAsideText: root.formatTimestampFn(model.time)
                        image.source: model.image
                        badge.primaryText: model.badgePrimaryText
                        badge.secondaryText: model.badgeSecondaryText
                        badge.image.source: model.badgeImage
                        badge.icon.isLetterIdenticon: model.badgeIsLetterIdenticon
                        badge.icon.color: model.badgeIconColor

                        onClicked: {
                            root.resultItemClicked(itemId)
                        }

                        propagateTitleClicks: !root.acceptsTitleClick(titleId)
                        onTitleClicked: {
                            if (root.acceptsTitleClick(titleId)) {
                                root.resultItemTitleClicked(titleId)
                            }
                        }
                    }
                    section.property: "sectionName"
                    section.criteria: ViewSection.FullString
                    section.delegate: Item {
                        height: 34
                        width: view.width
                        StatusBaseText {
                            font.pixelSize: 15
                            color: Theme.palette.baseColor1
                            text: section
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                        }
                    }
                }
                StatusLoadingIndicator {
                    anchors.centerIn: parent
                    visible: root.loading
                    color: Theme.palette.primaryColor1
                    width: 24
                    height: 24
                }

                StatusBaseText {
                    anchors.centerIn: parent
                    text: root.noResultsLabel
                    color: Theme.palette.baseColor1
                    font.pixelSize: 13
                    visible: ((inputText.text !== "") && (view.count === 0) && !root.loading)
                }
            }
        }
    }
    onClosed: {
        root.resetSearchSelection();
        root.loading = false;
        contentItem.searchText = "";
    }
}
