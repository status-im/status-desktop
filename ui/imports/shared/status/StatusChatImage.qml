import QtQuick 2.3

StatusChatImageLoader {
    property int chatVerticalPadding: 12
    property int chatHorizontalPadding: 12
    property string imageSource

    id: imageMessage
    verticalPadding: chatVerticalPadding
    source: imageSource
}
