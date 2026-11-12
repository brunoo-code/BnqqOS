"""Summarize a trimmed, single-stream PresentMon capture."""
import argparse
import csv
import json
import math
import statistics
from pathlib import Path


def summarize(path, target_fps):
    if not math.isfinite(target_fps) or target_fps <= 0:
        raise ValueError("target FPS must be finite and positive")
    identity = ("Application", "ProcessID", "SwapChainAddress")
    metric = "MsBetweenPresents"
    frames = []
    stream = None
    with path.open(encoding="utf-8-sig", newline="") as source:
        rows = csv.DictReader(source)
        if not set((*identity, metric)).issubset(rows.fieldnames or []):
            raise ValueError("expected a raw PresentMon CSV with stream IDs and MsBetweenPresents")
        for index, row in enumerate(rows, start=2):
            key = tuple(row[name] for name in identity)
            if not all(key) or (stream is not None and key != stream):
                raise ValueError(f"row {index}: expected one identified presentation stream")
            stream = key
            try:
                ms = float(row[metric])
            except (TypeError, ValueError):
                raise ValueError(f"row {index}: invalid frame interval") from None
            if not math.isfinite(ms) or ms <= 0:
                raise ValueError(f"row {index}: expected a finite, positive frame interval")
            frames.append(ms)
    n = len(frames)
    if n < 100:
        raise ValueError("at least 100 intervals are required for the 1% low")
    frames.sort()
    tail_size = (n + 99) // 100
    threshold_ms = 2000 / target_fps
    slow = sum(ms > threshold_ms for ms in frames)
    return {
        "application": stream[0],
        "samples": n,
        "fps_average": 1000 / statistics.mean(frames),
        "fps_1pct_low": 1000 / statistics.mean(frames[-tail_size:]),
        "frametime_p99_ms": frames[(99 * n + 99) // 100 - 1],
        "slow_frame_threshold_ms": threshold_ms,
        "slow_frames": slow,
        "slow_frames_pct": 100 * slow / n,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("capture", type=Path)
    parser.add_argument("--target-fps", type=float, required=True)
    args = parser.parse_args()
    try:
        result = summarize(args.capture, args.target_fps)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
