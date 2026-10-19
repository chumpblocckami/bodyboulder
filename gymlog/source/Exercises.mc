import Toybox.Lang;

// DEFAULT_KG[i] is the starting weight for NAMES[i]; keep both arrays the same length.
// Names must stay short (about 14 characters) to fit the round screen with the set number.
module Exercises {
    // Timed only: no reps or weight are asked for or logged.
    const CARDIO = "Cardio";

    const NAMES = [
        CARDIO,
        // Chest
        "Bench press",
        "Incline bench",
        "Chest fly",
        "Push-up",
        "Dip",
        // Back
        "Lat pulldown",
        "Row",
        "Seated row",
        "Pull-up",
        "Deadlift",
        // Shoulders
        "Shoulder press",
        "Lateral raise",
        "Face pull",
        "Shrug",
        // Arms
        "Biceps curl",
        "Hammer curl",
        "Triceps ext",
        "Pushdown",
        // Legs
        "Squat",
        "Leg press",
        "Leg extension",
        "Leg curl",
        "Romanian DL",
        "Lunge",
        "Hip thrust",
        "Calf raise",
        // Core
        "Ab crunch",
    ] as Array<String>;

    const DEFAULT_KG = [
        0.0,
        30.0, 25.0, 40.0, 0.0, 0.0,
        50.0, 25.0, 40.0, 0.0, 30.0,
        20.0, 16.0, 15.0, 20.0,
        20.0, 12.0, 25.0, 20.0,
        50.0, 80.0, 30.0, 30.0, 30.0, 10.0, 40.0, 40.0,
        50.0,
    ] as Array<Float>;

    const DEFAULT_REPS = 10;
    const MIN_SET_SECONDS = 60;
    const MIN_REST_SECONDS = 90;
}
