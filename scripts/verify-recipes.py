#!/usr/bin/env python3
"""Compare production Swift calculations with the saved upstream JavaScript.

Requires Xcode and Node.js on macOS. Uses standard libraries, runs offline,
and tests the same calculator and state model used by the app.
"""
from pathlib import Path
import hashlib
import json
import platform
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Sources/empiricalwater"
WORK = ROOT / ".build/recipe-checks"
WORK.mkdir(parents=True, exist_ok=True)
reference = ROOT / "Reference/EmpiricalWater"
snapshot = json.loads((reference / "recipes.json").read_text())
actual_hash = hashlib.sha256((reference / "calculator.cjs").read_bytes()).hexdigest()
if actual_hash != snapshot["calculatorSHA256"]:
    raise SystemExit("Reference calculator changed without refreshing its provenance")

with (WORK / "expected.json").open("w") as output:
    subprocess.run(["node", str(ROOT / "Tests/empirical-reference.cjs")],
                   cwd=ROOT, stdout=output, check=True)

subprocess.run([
    "xcrun", "swiftc", "-swift-version", "6", "-warnings-as-errors",
    "-target", f"{platform.machine()}-apple-macos14.0",
    *[str(SOURCE / file) for file in
      ("Recipes.swift", "Units.swift", "RecipeCalculator.swift", "AppState.swift")],
    str(ROOT / "Tests/RecipeCalculationChecks.swift"), "-o", str(WORK / "checks"),
], cwd=ROOT, check=True)
subprocess.run([str(WORK / "checks"), str(WORK / "expected.json")], cwd=ROOT, check=True)
