import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import "../stores"
import "../controls"

import SortFilterProxyModel 0.2

StatusDialog {
    id: root
    objectName: "socialLinksModal"

    property ProfileStore profileStore

    width: 640
    topPadding: 24
    bottomPadding: 24
    leftPadding: 34
    rightPadding: 34

    title: qsTr("Social Links")
    footer: null

    onOpened: {
        staticLinksRepeater.model = staticSocialLinks
        customLinksRepeater.model = customSocialLinks
    }

    onClosed: {
        // ensure text input values are reevaluated
        staticLinksRepeater.model = null
        customLinksRepeater.model = null
    }

    SortFilterProxyModel {
        id: staticSocialLinks

        sourceModel: root.profileStore.temporarySocialLinksModel
        filters: ValueFilter {
            roleName: "linkType"
            value: Constants.socialLinkType.custom
            inverted: true
        }
        sorters: RoleSorter {
            roleName: "linkType"
        }
    }

    SortFilterProxyModel {
        id: customSocialLinks

        sourceModel: root.profileStore.temporarySocialLinksModel
        filters: ValueFilter {
            roleName: "linkType"
            value: Constants.socialLinkType.custom
        }
    }

    StatusScrollView {
        id: scrollView

        anchors.fill: parent
        padding: 0

        ColumnLayout {
            width: scrollView.availableWidth

            spacing: 24 // by design

            Repeater {
                id: staticLinksRepeater
                delegate: StaticSocialLinkInput {
                    objectName: model.text + "-socialLinkInput"

                    Layout.fillWidth: true
                    linkType: model.linkType
                    text: model.url

                    onTextChanged: root.profileStore.updateLink(model.uuid, model.text, text)
                }
            }

            StatusBaseText {
                text: qsTr("Custom links")
                color: Theme.palette.baseColor1
                font.pixelSize: 15
            }

            ColumnLayout {
                id: customLinksLayout

                spacing: 40

                Layout.topMargin: -4 // by design

                Repeater {
                    id: customLinksRepeater
                    delegate: CustomSocialLinkInput {
                        objectName: "customSocialLinkInput"

                        Layout.fillWidth: true

                        hyperlink: model.text
                        url: model.url

                        removeButton.visible: index > 0
                        removeButton.onClicked: root.profileStore.removeCustomLink(model.uuid)

                        onHyperlinkChanged: root.profileStore.updateLink(model.uuid, hyperlink, url)
                        onUrlChanged: root.profileStore.updateLink(model.uuid, hyperlink, url)

                        Rectangle {
                            y: -customLinksLayout.spacing / 2
                            width: parent.width
                            height: 1
                            color: Theme.palette.baseColor2
                            visible: index > 0
                        }
                    }
                }
            }

            StatusIconTextButton {
                text: qsTr("Add another custom link")
                onClicked: {
                    root.profileStore.createCustomLink("", "")
                    scrollView.contentY = scrollView.contentHeight - scrollView.availableHeight
                }
            }
        }
    }

}
