import QtQuick 2.15
import QtQml 2.15
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
    \qmltype StatusRoundedMedia
    \inherits StatusRoundedComponent
    \inqmlmodule StatusQ.Components
    \since StatusQ.Components 0.1
    \brief Specialization of StatusRoundedComponent which handles different media types as content.

    This component is a StatusRoundedComponent which is able to display several types of media using
    the corresponding component according to the provided \l{https://www.iana.org/assignments/media-types/media-types.xhtml}{media type}, 
    with the posibility of diplaying a fallback image if the media fails to load properly.
    
    The list of supported media types and how the component to display them is chosen is the following:
    
    - \c image
    Initially, we try to display the media using StatusAnimatedImage. If loading fails, we try using
    StatusImage. If that results in an error as well, we display the fallback image using StatusImage.

    - \c video
    Initially, we try to display the media using StatusVideo. If that results in an error, 
    we display the fallback image using StatusImage.

    - For any other media type, we default to showing the fallback image using StatusImage.

    Example of how to use it:

    \qml
        StatusRoundedMedia {
            width: 100
            height: 100
            mediaUrl: "qrc:/demoapp/data/test-video.avi"
            mediaType: "video"
            fallbackImageUrl: "qrc:/demoapp/data/test-image.png"
        }
    \endqml
*/
StatusRoundedComponent {
    id: root

    enum MediaType {
        Image,
        Video,
        Unknown
    }

    /*!
        \qmlproperty url StatusRoundedMedia::mediaUrl

        Used to set the source for the main media we want to display.

    */
    property url mediaUrl

    /*!
        \qmlproperty string StatusRoundedMedia::mediaType

         \l{https://www.iana.org/assignments/media-types/media-types.xhtml}{Media type} corresponding to the media pointed to by mediaUrl.

    */
    property string mediaType

    /*!
        \qmlproperty url StatusRoundedMedia::fallbackImageUrl

        Image shown in case attempting to load the media pointed to by mediaUrl results in an error.

    */
    property url fallbackImageUrl

    /*!
        \qmlproperty url StatusRoundedMedia::fillMode
        helps set fillModel for the Media file loaded
    */
    property int fillMode: Image.PreserveAspectFit

    /*!
        \qmlproperty url StatusRoundedMedia::maxDimension
        is used to set dimension for the image in case of portrait or landscape
        when fillMode = Image.PreserveAspectFit
        if not set the width/height of parent will be considered
    */
    property int manualMaxDimension: 0

    readonly property int componentMediaType: {
        if (root.mediaType.startsWith("image")) {
            return StatusRoundedMedia.MediaType.Image
        } else if (root.mediaType.startsWith("video")) {
            return StatusRoundedMedia.MediaType.Video
        }
        return StatusRoundedMedia.MediaType.Unknown
    }

    isLoading: {
        if (mediaLoader.status === Loader.Ready) {
            return mediaLoader.item.isLoading
        }
        return true
    }

    Binding on isError {
        when: mediaLoader.status === Loader.Ready
        value: mediaLoader.item ? mediaLoader.item.isError : true
        delayed: true
        restoreMode: Binding.RestoreBindingOrValue
    }

    onIsErrorChanged: {
        if (isError) {
            d.errorCounter = d.errorCounter + 1
            processError()
        }
    }

    QtObject {
        id: d
        property bool isFallback: false
        property int errorCounter: 0

        function reset() {
            isFallback = false
            errorCounter = 0
        }
    }

    implicitWidth: {
        // Use Painted width so that the rectangle follow width of the image actually painted
        if(!!mediaLoader.item && (mediaLoader.item.paintedWidth > 0 || mediaLoader.item.paintedHeight > 0)) {
            return mediaLoader.item.paintedWidth
        }
        else return root.manualMaxDimension
    }
    implicitHeight: {
        // Use Painted height so that the rectangle follows height of the image actually painted
        if(!!mediaLoader.item && (mediaLoader.item.paintedWidth > 0 || mediaLoader.item.paintedHeight > 0)) {
            return mediaLoader.item.paintedHeight
        }
        else return root.manualMaxDimension
    }

    Component.onCompleted: updateMediaLoader()
    onMediaUrlChanged: updateMediaLoader()
    onComponentMediaTypeChanged: updateMediaLoader()
    onFallbackImageUrlChanged: updateMediaLoader()

    Loader {
        id: mediaLoader
        anchors.centerIn: parent
        // In case manualMaxDimension is not defined then use parent width and height instead
        width: root.manualMaxDimension === 0 ? parent.width : root.manualMaxDimension
        height: root.manualMaxDimension === 0 ? parent.height : root.manualMaxDimension
        asynchronous: true
        visible: !root.isError && !root.isLoading
    }

    function updateMediaLoader() {
        d.reset()
        if (root.mediaUrl !== "") {
            if (componentMediaType === StatusRoundedMedia.MediaType.Image) {
                mediaLoader.setSource("StatusAnimatedImage.qml",
                                    {
                                        "source": root.mediaUrl,
                                        "fillMode": root.fillMode
                                    });
                return
            } else if (componentMediaType === StatusRoundedMedia.MediaType.Video) {
                mediaLoader.setSource("StatusVideo.qml",
                                    {
                                        "player.source": root.mediaUrl,
                                        "fillMode": root.fillMode
                                    });
                return
            }
        }
        setFallbackImage()
    }

    function processError() {
        if (!d.isFallback) {
            // AnimatedImage sometimes cannot load stuff that plan Image can, try that first
            if (componentMediaType === StatusRoundedMedia.MediaType.Image && d.errorCounter <= 1) {
                mediaLoader.setSource("StatusImage.qml",
                                    {
                                        "source": root.mediaUrl,
                                        "fillMode": root.fillMode
                                    })
                return
            } else if (root.fallbackImageUrl !== "") {
                setFallbackImage()
                return
            }
        }
        setEmptyComponent()
    }

    function setFallbackImage() {
        d.isFallback = true
        mediaLoader.setSource("StatusImage.qml",
                            {
                                "source": root.fallbackImageUrl,
                                "fillMode": root.fillMode
                            })
    }

    function setEmptyComponent() {
        mediaLoader.setSource("StatusImage.qml",
                            {
                                "source": "",
                                "fillMode": root.fillMode
                            });
    }
}
