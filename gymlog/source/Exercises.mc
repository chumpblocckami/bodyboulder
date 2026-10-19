import Toybox.Lang;

// DEFAULT_KG[i] is the starting weight for NAMES[i]; keep both arrays the same length.
module Exercises {
    // Timed only: no reps or weight are asked for or logged.
    const CARDIO = "Cardio";

    const NAMES = [
        CARDIO,
        "Bench press",
        "Biceps curl",
        "Lateral raise",
        "Ab crunch",
        "Squat",
        "Deadlift",
        "Lat pulldown",
        "Chest fly",
        "Row",
        "Triceps ext",
        "Push-up",

    ] as Array<String>;

    const DEFAULT_KG = [
        0.0, 30.0, 20.0, 16.0, 50.0, 50.0, 30.0, 50.0, 40.0, 25.0, 25.0, 0.0,
    ] as Array<Float>;

    const DEFAULT_REPS = 10;
    const MIN_SET_SECONDS = 60;
    const MIN_REST_SECONDS = 90;
}
