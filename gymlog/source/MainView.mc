import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

const LIME = 0xD6F25C;
const MUTED = 0xB4BBA6;

class MainView extends WatchUi.View {
    private var _workout as Workout;
    private var _timer as Timer.Timer;

    function initialize(workout as Workout) {
        View.initialize();
        _workout = workout;
        _timer = new Timer.Timer();
    }

    function onShow() as Void {
        _timer.start(method(:onTick), 1000, true);
    }

    function onHide() as Void {
        _timer.stop();
    }

    function onTick() as Void {
        _workout.tick();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var cx = dc.getWidth() / 2;
        var h = dc.getHeight();

        switch (_workout.state) {
            case STATE_READY:
                drawCentered(dc, cx, h * 30 / 100, Graphics.FONT_MEDIUM, LIME, "BODYBOULDER");
                drawCentered(dc, cx, h * 52 / 100, Graphics.FONT_SMALL, Graphics.COLOR_WHITE, "Press START");
                drawCentered(dc, cx, h * 68 / 100, Graphics.FONT_XTINY, MUTED, "swipe to pick exercise");
                drawCentered(dc, cx, h * 80 / 100, Graphics.FONT_XTINY, MUTED, _workout.exerciseName());
                break;
            case STATE_LIFT:
                drawStatusBar(dc, cx, h);
                drawCentered(dc, cx, h * 27 / 100, Graphics.FONT_MEDIUM, LIME, _workout.exerciseName());
                drawCentered(dc, cx, h * 41 / 100, Graphics.FONT_SMALL, Graphics.COLOR_WHITE,
                    "Set " + (_workout.setsThisExercise + 1) + " - " + setText());
                drawPhaseClock(dc, cx, h * 62 / 100);
                drawCentered(dc, cx, h * 85 / 100, Graphics.FONT_XTINY, MUTED, "START = stop");
                break;
            case STATE_REST:
                drawStatusBar(dc, cx, h);
                drawCentered(dc, cx, h * 25 / 100, Graphics.FONT_SMALL, MUTED,
                    _workout.totalSets == 0 ? "GET READY" : "REST");
                drawPhaseClock(dc, cx, h * 45 / 100);
                drawCentered(dc, cx, h * 64 / 100, Graphics.FONT_XTINY, LIME,
                    "Next: " + _workout.exerciseName() + " #" + (_workout.setsThisExercise + 1));
                drawCentered(dc, cx, h * 73 / 100, Graphics.FONT_XTINY, MUTED, setText());
                drawCentered(dc, cx, h * 86 / 100, Graphics.FONT_XTINY, MUTED, "START = go");
                break;
            case STATE_DONE:
                drawCentered(dc, cx, h * 30 / 100, Graphics.FONT_MEDIUM, LIME, "Saved");
                drawCentered(dc, cx, h * 50 / 100, Graphics.FONT_SMALL, Graphics.COLOR_WHITE,
                    _workout.totalSets + " sets");
                drawCentered(dc, cx, h * 64 / 100, Graphics.FONT_SMALL, Graphics.COLOR_WHITE,
                    _workout.totalVolumeKg.format("%d") + " kg volume");
                drawCentered(dc, cx, h * 82 / 100, Graphics.FONT_XTINY, MUTED, "BACK to exit");
                break;
        }
    }

    private function drawStatusBar(dc as Graphics.Dc, cx as Number, h as Number) as Void {
        var info = Activity.getActivityInfo();
        var elapsed = "0:00";
        var hr = "--";
        if (info != null) {
            var t = info.timerTime;
            if (t != null) {
                elapsed = formatClock(t / 1000);
            }
            var bpm = info.currentHeartRate;
            if (bpm != null) {
                hr = bpm.toString();
            }
        }
        drawCentered(dc, cx, h * 13 / 100, Graphics.FONT_XTINY, MUTED,
            elapsed + "   " + hr + " bpm   " + _workout.totalSets + " sets");
    }

    // Count-up clock for the current set or rest; turns lime once the minimum is reached.
    private function drawPhaseClock(dc as Graphics.Dc, cx as Number, y as Number) as Void {
        var secs = _workout.phaseSeconds();
        drawCentered(dc, cx, y, Graphics.FONT_NUMBER_HOT,
            secs >= _workout.phaseTargetSeconds() ? LIME : Graphics.COLOR_WHITE, formatClock(secs));
    }

    private function setText() as String {
        return _workout.setLabel(_workout.exerciseIndex);
    }

    private function drawCentered(dc as Graphics.Dc, x as Number, y as Number, font as Graphics.FontType,
                                  color as Graphics.ColorType, text as String) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

function formatClock(seconds as Number) as String {
    var hours = seconds / 3600;
    var minutes = (seconds / 60) % 60;
    var secs = seconds % 60;
    if (hours > 0) {
        return hours + ":" + minutes.format("%02d") + ":" + secs.format("%02d");
    }
    return minutes + ":" + secs.format("%02d");
}
