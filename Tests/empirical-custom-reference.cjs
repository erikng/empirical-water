// Exercise the saved website's Custom branch with independent concentrate profiles.
// Only the input adapter is new; the numerical body comes from the saved source.
const fs = require('node:fs');
const path = require('node:path');
const referencePath = path.join(__dirname, '../Reference/EmpiricalWater/calculator.cjs');
const source = fs.readFileSync(referencePath, 'utf8');
const { PROFILES, BOOSTER, GALLON_TO_ML } = require(referencePath);
const start = source.indexOf('  function syncCustomZero()');
const end = source.indexOf('\n}\nmodule.exports');
if (start < 0 || end <= start) throw new Error('Upstream Custom arithmetic could not be located');
const calculate = new Function('hardnessProfile', 'bufferProfile', 'BOOSTER',
  'customHardnessMl', 'customBufferMl', 'customBoosterMl', 'customTotalMl', 'measure',
  'var mode = "Custom", customZeroTdsMl = 0, LITER_TO_ML = 1000;\n' + source.slice(start, end));

const cases = [];
const volumes = { milliliter: [100, 333, 1000], liter: [1, 1.25, 20], gallon: [1, 1.5, 5] };
for (const hp of PROFILES) {
  for (const bp of PROFILES) {
    for (const [hardness, buffer, booster] of [[50, 0.3, 0], [20.25, 0.55, 0.15], [100, 2, 15], [0, 0, 0]]) {
      for (const [unit, values] of Object.entries(volumes)) {
        for (const volume of values) {
          const liters = unit === 'gallon' ? volume * GALLON_TO_ML / 1000 : unit === 'liter' ? volume : volume / 1000;
          const amounts = ['mL', 'grams'].map(measure => calculate(hp, bp, BOOSTER,
            hardness * liters, buffer * liters, booster * liters, liters * 1000, measure));
          for (let mask = 0; mask < 16; mask++) {
            cases.push({ hardnessWater: hp.key, bufferWater: bp.key, hardness, buffer, booster, unit, volume, mask,
              amounts: ['hardness', 'buffer', 'booster', 'zero'].map((key, i) => amounts[mask & (1 << i) ? 0 : 1][key]),
              gh: amounts[0].gh, kh: amounts[0].kh, tds: amounts[0].tds });
          }
        }
      }
    }
  }
}
process.stdout.write(JSON.stringify(cases));
