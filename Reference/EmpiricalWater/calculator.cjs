// Extracted from https://empiricalwater.com/pages/user-guide on 2026-09-12.
// Numeric constants and the render() arithmetic below are preserved verbatim.
// The adapter supplies render's inputs and returns its numeric outputs for tests.
// This file is a verification reference only; the app never executes JavaScript.
  var GALLON_TO_ML = 3785.41;
  var LITER_TO_ML  = 1000;

  var PROFILES = [
    {
      key: "glacial", name: "Glacial",
      ghPerMl: 34.62 / 50, khPerMl: 15.76 / 50, bufferKhPerMl: 27234 / 1000, bufferDensity: 1.022, hardnessTdsPerMl: 46.956 / 50, bufferTdsPerMl: 41365.369 / 1000,
      roasts: [
        { label: "Acidity++", hardnessPerLiter: 50,    bufferPerLiter: 0   },
        { label: "Light",     hardnessPerLiter: 50,    bufferPerLiter: 0.3 },
        { label: "Medium",    hardnessPerLiter: 50,    bufferPerLiter: 1.0 },
        { label: "Dark",      hardnessPerLiter: 50,    bufferPerLiter: 1.5 },
        { label: "Espresso",  hardnessPerLiter: 50,    bufferPerLiter: 1.5 },
        { label: "Tea",       hardnessPerLiter: 50,    bufferPerLiter: 0.5 },
      ]
    },
    {
      key: "spring", name: "Spring",
      ghPerMl: 65.21 / 100, khPerMl: 22.54 / 100, bufferKhPerMl: 41552.5 / 1000, bufferDensity: 1.032, hardnessTdsPerMl: 85.911 / 100, bufferTdsPerMl: 59962.448 / 1000,
      roasts: [
        { label: "Light",    hardnessPerLiter: 100,  bufferPerLiter: 0   },
        { label: "Medium",   hardnessPerLiter: 100,  bufferPerLiter: 1.0 },
        { label: "Dark",     hardnessPerLiter: 100,  bufferPerLiter: 1.5 },
        { label: "Espresso", hardnessPerLiter: 50,   bufferPerLiter: 2.0 },
        { label: "Tea",      hardnessPerLiter: 100,  bufferPerLiter: 1.0 },
      ]
    },
    {
      key: "aviary", name: "Aviary",
      ghPerMl: 58.4 / 20, khPerMl: 0, bufferKhPerMl: 27 / 0.5, bufferDensity: 1.049, hardnessTdsPerMl: 68.240 / 20, bufferTdsPerMl: 90727 / 1000,
      roasts: [
        { label: "Filter", hardnessPerLiter: 20, bufferPerLiter: 0.5 },
      ]
    }
  ];

  var BOOSTER = { ghPerMl: 10582.64 / 1000, khPerMl: 0, tdsPerMl: 11364.589 / 1000, density: 1.024 };


function calculate(input) {
  var profile = PROFILES.find(p => p.key === input.profile);
  var roast = profile.roasts.find(r => r.label === input.roast);
  var hardnessProfile = profile, bufferProfile = profile;
  var unit = input.unit, volume = input.volume, measure = input.measure;
  var mode = input.boosterPerLiter > 0 ? "Custom" : "Preset";
  var customTotalMl = unit === "Liter" ? volume * LITER_TO_ML : volume * GALLON_TO_ML;
  var customHardnessMl = customTotalMl / LITER_TO_ML * roast.hardnessPerLiter;
  var customBufferMl = customTotalMl / LITER_TO_ML * roast.bufferPerLiter;
  var customBoosterMl = customTotalMl / LITER_TO_ML * input.boosterPerLiter;
  var customZeroTdsMl = 0;
  function syncCustomZero() {
    customZeroTdsMl = Math.max(0, customTotalMl - customHardnessMl - customBufferMl - customBoosterMl);
  }
    var hardness, buffer, zero, totalMl, liters;
    if (mode === "Preset") {
      totalMl  = unit === "Liter" ? volume * LITER_TO_ML : volume * GALLON_TO_ML;
      liters   = totalMl / LITER_TO_ML;
      hardness = liters * roast.hardnessPerLiter;
      buffer   = liters * roast.bufferPerLiter;
      zero     = Math.max(0, totalMl - hardness - buffer);
    } else {
      hardness = customHardnessMl;
      buffer   = customBufferMl;
      syncCustomZero();
      zero     = customZeroTdsMl;
      totalMl  = customTotalMl;
      liters   = totalMl / LITER_TO_ML;
    }

    var effectiveHardnessPerLiter = liters > 0 ? hardness / liters : 0;
    var effectiveBufferPerLiter   = liters > 0 ? buffer  / liters : 0;
    var effectiveBoosterPerLiter  = liters > 0 && mode === "Custom" ? customBoosterMl / liters : 0;
    var bufferDisplay  = measure === "grams" ? buffer * bufferProfile.bufferDensity : buffer;
    var boosterDisplay = measure === "grams" ? customBoosterMl * BOOSTER.density : customBoosterMl;
    var u = measure;

    var gh  = effectiveHardnessPerLiter * hardnessProfile.ghPerMl + effectiveBoosterPerLiter * BOOSTER.ghPerMl;
    var kh  = effectiveHardnessPerLiter * hardnessProfile.khPerMl + effectiveBufferPerLiter * bufferProfile.bufferKhPerMl;
    var tds = effectiveHardnessPerLiter * hardnessProfile.hardnessTdsPerMl + effectiveBufferPerLiter * bufferProfile.bufferTdsPerMl + effectiveBoosterPerLiter * BOOSTER.tdsPerMl;


  return {hardness, buffer: bufferDisplay, booster: boosterDisplay, zero, gh, kh, tds};
}
module.exports = { PROFILES, BOOSTER, GALLON_TO_ML, LITER_TO_ML, calculate };
