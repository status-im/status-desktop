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

        function textToType(text) {
            if (text === "__twitter") return Constants.socialLinkType.twitter
            if (text === "__personal_site") return Constants.socialLinkType.personalSite
            if (text === "__github") return Constants.socialLinkType.github
            if (text === "__youtube") return Constants.socialLinkType.youtube
            if (text === "__discord") return Constants.socialLinkType.discord
            if (text === "__telegram") return Constants.socialLinkType.telegram
            return Constants.socialLinkType.custom
        }

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
                    socialLinksModel.append({
                                                "text": obj.text,
                                                "url": obj.url,
                                                "linkType": textToType(obj.text)
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

        function customsLastPredicate(linkTypeLeft, linkTypeRight) {
            if (linkTypeLeft === Constants.socialLinkType.custom) return false
            if (linkTypeRight === Constants.socialLinkType.custom) return true
            return linkTypeLeft < linkTypeRight
        }

        sourceModel: socialLinksModel
        filters: ExpressionFilter {
            expression: model.text !== "" && model.url !== ""
        }
        sorters: [
            ExpressionSorter {
                expression: sortedSocialLinksModel.customsLastPredicate(modelLeft.linkType, modelRight.linkType)
            }
        ]
    }

    contentItem: ColumnLayout {
        spacing: 20

        StatusScrollView {
            id: scrollView
            visible: root.bio !== ""
            padding: 0
            rightPadding: scrollBar.visible ? 16 : 0
            Layout.maximumHeight: 108
            Layout.fillWidth: true
            TextArea.flickable: bioText
            ScrollBar.vertical: StatusScrollBar {
                id: scrollBar
                policy: scrollView.contentHeight > scrollView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }

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
                    linkType: model.linkType
                }
            }
        }
    }
}
