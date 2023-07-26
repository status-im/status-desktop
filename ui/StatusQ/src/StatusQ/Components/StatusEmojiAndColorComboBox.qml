import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1

// model expected roles: emoji, color, name
/*!
   \qmltype StatusEmojiAndColorComboBox
   \inherits StatusComboBox
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It is a combobox where the delegate and the content item are an emoji + color and the text.

   The \c StatusEmojiAndColorComboBox behaves like a combobox but with specific content item and delegate look (emoji + color + text)

   Example of how the control looks like:
   \image status_emoji_and_color_combobox.png

   Example of how to use it:

   \qml
            StatusEmojiAndColorComboBox {
                Layout.preferredWidth: 300
                model: WalletAccountsModel {}
                type: StatusComboBox.Type.Secondary
                size: StatusComboBox.Size.Small
                implicitHeight: 44
                defaultAssetName: "filled-account"
            }
   \endqml

   For a list of components available see StatusQ.
*/
StatusComboBox {
    id: root

    /*!
       \qmlproperty string StatusEmojiAndColorComboBox::defaultAssetName
       This property holds the default asset shown if no emoji provided.
    */
    property string defaultAssetName: "info"

    /*!
       \qmlproperty int StatusEmojiAndColorComboBox::delegateHeight
       This property holds the delegate height value.
    */
    property int delegateHeight: 44

    ModelChangeTracker {
        id: modelTracker

        model: root.model
    }

    QtObject {
        id: d

        readonly property string emoji: {
            modelTracker.revision
            return ModelUtils.get(root.model, currentIndex, "emoji") ?? ""
        }

        readonly property string color: {
            modelTracker.revision
            return ModelUtils.get(root.model, currentIndex, "color") ?? ""
        }
    }

    control.textRole: "name"

    contentItem: CustomComboItem {
        anchors.fill: parent
        text: root.control.displayText
        emoji: d.emoji
        color: d.color
        onClicked: control.popup.opened ? control.popup.close() : control.popup.open()
    }

    delegate: CustomComboItem {
        width: root.width
        text: model.name
        emoji: model.emoji
        color: model.color
        highlighted: root.control.highlightedIndex === index
    }

    component CustomComboItem: StatusItemDelegate {
        id: comboItem

        property string emoji
        property color color

        height: root.delegateHeight

        contentItem: RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            StatusSmartIdenticon {
                asset.emoji: comboItem.emoji ?? ""
                asset.color: comboItem.color
                asset.name: !!comboItem.emoji ? "" : root.defaultAssetName
                asset.width: 22
                asset.height: asset.width
                asset.isLetterIdenticon: !!comboItem.emoji
                asset.bgColor: Theme.palette.primaryColor3
            }

            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: comboItem.text
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                color: Theme.palette.directColor1
            }
        }
    }
}
