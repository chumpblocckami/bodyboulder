import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Attention;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.System;

enum WorkoutState {
    STATE_READY,
    STATE_LIFT,
    STATE_REST,
    STATE_DONE
}

// Every set and every rest is its own FIT lap; set laps carry muscle group, reps and
// weight as developer fields (rest laps carry "Rest", 0, 0). Connect IQ cannot
// write native strength "set" messages.
class Workout {
    var state as WorkoutState = STATE_READY;
    var exerciseIndex as Number = 0;
    var setsThisExercise as Number = 0;
    var totalSets as Number = 0;
    var totalVolumeKg as Float = 0.0;
    var lastReps as Array<Number>;
    var lastKg as Array<Float>;

    private var _phaseStart as Number = 0;
    private var _buzzed as Boolean = false;
    private var _session as ActivityRecording.Session?;
    private var _exerciseField as FitContributor.Field?;
    private var _repsField as FitContributor.Field?;
    private var _kgField as FitContributor.Field?;
    private var _setsField as FitContributor.Field?;
    private var _volumeField as FitContributor.Field?;

    function initialize() {
        var n = Exercises.NAMES.size();
        lastReps = new Array<Number>[n];
        lastKg = new Array<Float>[n];
        for (var i = 0; i < n; i++) {
            lastReps[i] = Exercises.DEFAULT_REPS;
            lastKg[i] = Exercises.DEFAULT_KG[i];
        }
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
    }

    function start() as Void {
        var session = ActivityRecording.createSession({
            :name => "BodyBoulder",
            :sport => Activity.SPORT_TRAINING,
            :subSport => Activity.SUB_SPORT_STRENGTH_TRAINING
        });
        _exerciseField = session.createField("muscle", 0, FitContributor.DATA_TYPE_STRING,
            { :mesgType => FitContributor.MESG_TYPE_LAP, :count => 16 });
        _repsField = session.createField("reps", 1, FitContributor.DATA_TYPE_UINT16,
            { :mesgType => FitContributor.MESG_TYPE_LAP, :units => "reps" });
        _kgField = session.createField("weight", 2, FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_LAP, :units => "kg" });
        _setsField = session.createField("total_sets", 3, FitContributor.DATA_TYPE_UINT16,
            { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "sets" });
        _volumeField = session.createField("volume", 4, FitContributor.DATA_TYPE_FLOAT,
            { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "kg" });
        session.start();
        _session = session;
        enterRest();
        bigBuzz();
    }

    function exerciseName() as String {
        return Exercises.NAMES[exerciseIndex];
    }

    function isCardio() as Boolean {
        return exerciseName().equals(Exercises.CARDIO);
    }

    // "10 x 30.0 kg", "10 reps", or "timer only" for cardio.
    function setLabel(index as Number) as String {
        if (Exercises.NAMES[index].equals(Exercises.CARDIO)) {
            return "timer only";
        }
        var kg = lastKg[index];
        var reps = lastReps[index].toString();
        return kg > 0 ? reps + " x " + kg.format("%.1f") + " kg" : reps + " reps";
    }

    function selectExercise(index as Number) as Void {
        if (index != exerciseIndex) {
            exerciseIndex = index;
            setsThisExercise = 0;
        }
    }

    function shiftExercise(delta as Number) as Void {
        var n = Exercises.NAMES.size();
        selectExercise((exerciseIndex + delta + n) % n);
    }

    // Closes the rest lap and starts timing a set of `reps` x `kg`.
    function beginSet(reps as Number, kg as Float) as Void {
        var session = _session;
        if (session == null) {
            return;
        }
        lastReps[exerciseIndex] = reps;
        lastKg[exerciseIndex] = kg;
        session.addLap();
        setField(_exerciseField, exerciseName());
        setField(_repsField, reps);
        setField(_kgField, kg);
        enterPhase(STATE_LIFT);
        buzz();
    }

    // Closes the set lap and starts timing the rest.
    function endSet() as Void {
        var session = _session;
        if (session == null) {
            return;
        }
        setsThisExercise += 1;
        totalSets += 1;
        totalVolumeKg += lastReps[exerciseIndex] * lastKg[exerciseIndex];
        setField(_setsField, totalSets);
        setField(_volumeField, totalVolumeKg);
        session.addLap();
        enterRest();
    }

    function phaseSeconds() as Number {
        return (System.getTimer() - _phaseStart) / 1000;
    }

    // Minimum duration of the current phase; the watch buzzes once when it is reached.
    function phaseTargetSeconds() as Number {
        return state == STATE_LIFT ? Exercises.MIN_SET_SECONDS : Exercises.MIN_REST_SECONDS;
    }

    // Called once per second by the view.
    function tick() as Void {
        if ((state == STATE_LIFT || state == STATE_REST) && !_buzzed && phaseSeconds() >= phaseTargetSeconds()) {
            _buzzed = true;
            buzz();
        }
    }

    function save() as Void {
        if (state == STATE_LIFT) {
            endSet();
        }
        var session = _session;
        if (session != null) {
            session.stop();
            session.save();
            _session = null;
            bigBuzz();
        }
        state = STATE_DONE;
    }

    function discard() as Void {
        var session = _session;
        if (session != null) {
            session.stop();
            session.discard();
            _session = null;
        }
        state = STATE_DONE;
    }

    function saveIfRecording() as Void {
        if (_session != null) {
            save();
        }
    }

    private function enterRest() as Void {
        setField(_exerciseField, "Rest");
        setField(_repsField, 0);
        setField(_kgField, 0.0);
        enterPhase(STATE_REST);
    }

    private function enterPhase(next as WorkoutState) as Void {
        state = next;
        _phaseStart = System.getTimer();
        _buzzed = false;
    }

    // Small tap for in-workout cues.
    private function buzz() as Void {
        pulse([new Attention.VibeProfile(50, 150)]);
    }

    // Strong double pulse that marks the start and end of the session.
    private function bigBuzz() as Void {
        pulse([new Attention.VibeProfile(100, 400),
                 new Attention.VibeProfile(0, 200),
                 new Attention.VibeProfile(100, 400)]);
    }

    private function pulse(pattern as Array<Attention.VibeProfile>) as Void {
        if (Attention has :vibrate) {
            Attention.vibrate(pattern);
        }
    }

    private function setField(field as FitContributor.Field?, value as Numeric or String) as Void {
        if (field != null) {
            field.setData(value);
        }
    }
}
