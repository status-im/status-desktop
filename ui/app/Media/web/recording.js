const _durationNotificationInterval = 300;

let _recordingContext;
let _recorder;
let _durationTimerId;
let _startedAt;

async function initRecording(recordingContext) {
    _recordingContext = recordingContext;
    _recordingContext.stop.connect(stopRecording);
    await startRecording();
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
        let duration = (new Date() - _startedAt) / 1000.0;
        if (_recorder && _startedAt) {
            _recordingContext.duration = duration;
        }
    },
    _durationNotificationInterval);
}

async function startRecording() {
    if (_recorder) {
        return;
    }

    let recorderOptions = {
        encoderPath: 'opus-recorder/encoderWorker.min.js',
        numberOfChannels: 1,
        recordingGain: _recordingContext.micLevel,
    };

    _recorder = new Recorder(recorderOptions);
    _recorder.start().catch(function(err){
        _recordingContext.handleError(error);
    });
    _recorder.onstart = restartDurationTimer;
    _recorder.ondataavailable = onRecordingAvailable;
    _recordingContext.duration = 0;
}

function onRecordingAvailable(data) {
    if (_recorder) {
        let duration = (new Date() - _startedAt) / 1000.0;
        _recordingContext.handleRecorded(btoa(String.fromCharCode(...new Uint8Array(data))), duration);
        _recorder.close();
        stopDurationTimer();
    }
}

function stopRecording() {
    if (_recorder) {
        _recorder.stop();
    }
}
