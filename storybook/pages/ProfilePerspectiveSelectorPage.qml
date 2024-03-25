import QtQuick 2.15

import shared.controls 1.0

Item {
    ProfilePerspectiveSelector {
        anchors.centerIn: parent
        onVisibilitySelected: (visibility) => showcaseVisibility = visibility
    }
}

//category: Controls

// https://www.figma.com/file/ibJOTPlNtIxESwS96vJb06/👤-Profile-%7C-Desktop?type=design&node-id=2460-28481&mode=design&t=XMfk3mxF7lZD7DZe-0