import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import "../controls"

import SortFilterProxyModel 0.2

Control {
    id: root

    property string bio
    property string userSocialLinksJson

    onUserSocialLinksJsonChanged: d.buildSocialLinksModel()

    QtObject {
        id: d

        // Unfortunately, nim can't expose temporary QObjects thorugh slots
        // The only way to expose static models on demand is through json strings (see getContactDetailsAsJson)
        // Model is built here manually, which I know is completely wrong..
        function buildSocialLinksModel() {
            socialLinksModel.clear()

            if (root.userSocialLinksJson == "") return

            try {
                let links = JSON.parse(root.userSocialLinksJson)
                for (let i=0; i<links.length; i++) {
                    let obj = links[i]
                    const url = obj.url
                    const type = ProfileUtils.linkTextToType(obj.text)
                    socialLinksModel.append({
                                                "text": type === Constants.socialLinkType.custom ? obj.text : ProfileUtils.stripSocialLinkPrefix(url, type),
                                                "url": url,
                                                "linkType": type,
                                                "icon": obj.icon
                                            })
                }
            }
            catch (e) {
                console.warn("can't parse userSocialLinksJson", e)
            }
        }
    }

    ListModel {
        id: socialLinksModel
    }

    SortFilterProxyModel {
        id: sortedSocialLinksModel

        sourceModel: socialLinksModel
        filters: ExpressionFilter {
            expression: model.text !== "" && model.url !== ""
        }
    }

    contentItem: ColumnLayout {
        spacing: 20

        StatusScrollView {
            id: scrollView

            visible: root.bio
            padding: 0
            topPadding: Style.current.halfPadding
            rightPadding: ScrollBar.vertical.visible ? 16 : 0

            Layout.maximumHeight: 108
            Layout.fillWidth: true

            contentWidth: availableWidth

            ScrollBar.vertical.policy: bioText.height > scrollView.availableHeight
                                            ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

            StatusBaseText {
                id: bioText
                text: root.bio
                wrapMode: Text.Wrap
                font.weight: Font.Medium
                lineHeight: 1.2
                width: scrollView.availableWidth
            }
        }

        StatusCenteredFlow {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: Style.current.halfPadding
            visible: repeater.count > 0

            Repeater {
                id: repeater

                model: sortedSocialLinksModel
                delegate: SocialLinkPreview {
                    height: 32
                    text: model.text
                    url: model.url
                    icon: model.icon
                }
            }
        }
    }
}
