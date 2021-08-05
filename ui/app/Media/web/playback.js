let _playbackContext;
let _wavesurfer;

function initPlayback(playbackContext, waveformElementId) {
    _playbackContext = playbackContext;
    _wavesurfer = WaveSurfer.create({
        // http://wavesurfer-js.org/docs/options.html
        container: waveformElementId,
        barWidth: 2,
        barHeight: 1,
        barMinHeight: 1,
        barGap: null,
        barRadius: 2,
        normalize: true,
        height: 32,
        cursorWidth: 0,
        backgroundColor: playbackContext.backgroundColor,
        waveColor: playbackContext.waveColor,
        progressColor: playbackContext.progressColor,
    });

    // http://wavesurfer-js.org/docs/events.html
    _wavesurfer.on('audioprocess', function () {
        _playbackContext.position = _wavesurfer.getCurrentTime();
    });
    _wavesurfer.on('play', function () {
        _playbackContext.playing = true;
    });
    _wavesurfer.on('pause', function () {
        _playbackContext.playing = false;
    });
    _wavesurfer.on('finish', function () {
        _playbackContext.playing = false;
    });
    _wavesurfer.on('error', function (error) {
        _playbackContext.error = error
    });

    _playbackContext.play.connect(function() {
        _wavesurfer.play();
    });
    _playbackContext.pause.connect(function() {
        _wavesurfer.pause();
    });
    _playbackContext.volumeChanged.connect(function() {
        _wavesurfer.setVolume(_playbackContext.volume);
    });

    _wavesurfer.load(_playbackContext.audioSrc);
}
