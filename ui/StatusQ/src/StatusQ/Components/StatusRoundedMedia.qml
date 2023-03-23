import QtQuick 2.15
import QtQml 2.15
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusRoundedComponent {
    id: root

    enum MediaType {
        Image,
        Video,
        Unknown
    }

    property url mediaUrl
    property string mediaType
    property url fallbackImageUrl

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

    Loader {
        id: mediaLoader
        anchors.fill: parent
        asynchronous: true
        visible: !root.isError && !root.isLoading
    }

    Component.onCompleted: updateMediaLoader()
    onMediaUrlChanged: updateMediaLoader()
    onComponentMediaTypeChanged: updateMediaLoader()
    onFallbackImageUrlChanged: updateMediaLoader()

    function updateMediaLoader() {
        d.reset()
        if (root.mediaUrl !== "") {
            if (componentMediaType === StatusRoundedMedia.MediaType.Image) {
                mediaLoader.setSource("StatusAnimatedImage.qml",
                                    {
                                        "source": root.mediaUrl
                                    });
                return
            } else if (componentMediaType === StatusRoundedMedia.MediaType.Video) {
                mediaLoader.setSource("StatusVideo.qml",
                                    {
                                        "player.source": root.mediaUrl
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
                                        "source": root.mediaUrl
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
                                "source": root.fallbackImageUrl
                            })
    }

    function setEmptyComponent() {
        mediaLoader.setSource("StatusImage.qml",
                            {
                                "source": ""
                            });
    }
}
