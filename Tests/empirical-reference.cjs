// Exercise the saved upstream arithmetic, independently of the Swift port.
const { PROFILES, calculate } = require('../Reference/EmpiricalWater/calculator.cjs');
const cases = [];
const volumes = {
  milliliter: [100, 105, 333, 450, 995, 1000],
  liter: [1, 1.25, 2.5, 10, 20],
  gallon: [1, 1.5, 3, 4.5, 5],
};
const brews = {
  'Acidity++': 'acidity', Light: 'light_roast', Medium: 'medium_roast',
  Dark: 'dark_roast', Espresso: 'espresso', Tea: 'tea', Filter: 'filter',
};
for (const profile of PROFILES) {
  for (const roast of profile.roasts) {
    for (const [unit, values] of Object.entries(volumes)) {
      for (const volume of values) {
        for (const boosterPerLiter of [0, 0.5, 1, 15]) {
          const input = {
            profile: profile.key, roast: roast.label,
            unit: unit === 'gallon' ? 'Gallon' : 'Liter',
            volume: unit === 'milliliter' ? volume / 1000 : volume,
            boosterPerLiter,
          };
          const ml = calculate({ ...input, measure: 'mL' });
          const grams = calculate({ ...input, measure: 'grams' });
          // Every combination of the four existing per-ingredient preferences.
          for (let mask = 0; mask < 16; mask++) {
            cases.push({
              water: profile.key, brew: brews[roast.label], unit, volume,
              boosterPerLiter, mask,
              amounts: ['hardness', 'buffer', 'booster', 'zero'].map((key, i) =>
                (mask & (1 << i) ? ml : grams)[key]),
              gh: ml.gh, kh: ml.kh, tds: ml.tds,
            });
          }
        }
      }
    }
  }
}
process.stdout.write(JSON.stringify(cases));
