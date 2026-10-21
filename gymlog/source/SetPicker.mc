import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

const MAX_REPS = 50;
const MAX_KG = 200;
const KG_STEP = 5;

// Reps and kilograms for the set about to start, preset to the last set of this muscle group.
function openSetPicker(workout as Workout) as Void {
    var i = workout.exerciseIndex;
    var reps = new RangeFactory(1, MAX_REPS, 1, " reps");
    var kg = new RangeFactory(0, MAX_KG, KG_STEP, " kg");
    var picker = new WatchUi.Picker({
        :title => new WatchUi.Text({
            :text => workout.exerciseName(),
            :font => Graphics.FONT_SMALL,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
            :color => LIME
        }),
        :pattern => [reps, kg],
        :defaults => [reps.indexOf(workout.lastReps[i]), kg.indexOf(workout.lastKg[i].toNumber())]
    });
    WatchUi.pushView(picker, new SetPickerDelegate(workout), WatchUi.SLIDE_UP);
}

// Values first, first + step, ... up to last.
class RangeFactory extends WatchUi.PickerFactory {
    private var _first as Number;
    private var _last as Number;
    private var _step as Number;
    private var _suffix as String;

    function initialize(first as Number, last as Number, step as Number, suffix as String) {
        PickerFactory.initialize();
        _first = first;
        _last = last;
        _step = step;
        _suffix = suffix;
    }

    function getSize() as Number {
        return (_last - _first) / _step + 1;
    }

    function getValue(index as Number) as Object? {
        return _first + index * _step;
    }

    // Index of the value nearest to `value`, clamped to the range.
    function indexOf(value as Number) as Number {
        if (value < _first) {
            return 0;
        }
        if (value > _last) {
            return getSize() - 1;
        }
        return (value - _first + _step / 2) / _step;
    }

    function getDrawable(index as Number, selected as Boolean) as WatchUi.Drawable? {
        return new WatchUi.Text({
            :text => (_first + index * _step) + _suffix,
            :color => selected ? Graphics.COLOR_WHITE : MUTED,
            :font => Graphics.FONT_MEDIUM,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_CENTER
        });
    }
}

class SetPickerDelegate extends WatchUi.PickerDelegate {
    private var _workout as Workout;

    function initialize(workout as Workout) {
        PickerDelegate.initialize();
        _workout = workout;
    }

    function onAccept(values as Array) as Boolean {
        var reps = values[0] as Number;
        var kg = values[1] as Number;
        _workout.beginSet(reps, kg.toFloat());
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
