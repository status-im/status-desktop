let _recordingContext;
let _recorder;
let _durationTimerId;
let _startedAt;

function initRecording(recordingContext) {
    if (!Recorder.isRecordingSupported()) {
        _recordingContext.handleError("Audio recording is not supported.");
        return
    }

    _recordingContext = recordingContext;
    _recordingContext.stop.connect(function() {
        if (_recorder) {
            _recorder.stop();
        }
    });

    const recorderOptions = {
        // https://github.com/chris-rudmin/opus-recorder
        encoderPath: 'opus-recorder/encoderWorker.min.js',
        numberOfChannels: 1,
        recordingGain: _recordingContext.micLevel,
        encoderApplication: 2048,
    };

    _recorder = new Recorder(recorderOptions);
    _recorder.start().catch(function(err){
        _recordingContext.handleError(error);
    });
    _recorder.onstart = restartDurationTimer;
    _recorder.ondataavailable = dataAvailable;
    _recordingContext.duration = 0;
}

function stopDurationTimer() {
    if (_durationTimerId) {
        clearInterval(_durationTimerId);
        _startedAt = null;
    }
}

function restartDurationTimer() {
    stopDurationTimer();
    _startedAt = new Date();

    _durationTimerId = setInterval(() => {
        const duration = (new Date() - _startedAt) / 1000.0;
        if (_recorder && _startedAt) {
            _recordingContext.duration = duration;
        }
    },
    100);
}

function dataAvailable(arrayBuffer) {
    if (_recorder) {
        const duration = (new Date() - _startedAt) / 1000.0;
        const audioBase64 = btoa(String.fromCharCode(...new Uint8Array(arrayBuffer)));
        _recordingContext.handleRecorded(audioBase64, duration);
        _recorder.close();
        stopDurationTimer();
    }
}

