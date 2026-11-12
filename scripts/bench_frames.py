"""Summarize a trimmed, single-stream PresentMon capture."""
import argparse
import csv
import hashlib
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


def compare(before, after, target_fps):
    if len(before) < 3 or len(before) != len(after):
        raise ValueError("provide at least three captures per condition, with equal counts")

    captures = {"before": [], "after": []}
    seen = set()
    application = None
    for condition, paths in (("before", before), ("after", after)):
        for path in paths:
            with path.open("rb") as capture:
                checksum = hashlib.sha256()
                for chunk in iter(lambda: capture.read(1024 * 1024), b""):
                    checksum.update(chunk)
                digest = checksum.hexdigest()
            if digest in seen:
                raise ValueError(f"capture reused: {path}")
            seen.add(digest)

            result = summarize(path, target_fps)
            if application is None:
                application = result["application"]
            if result["application"].casefold() != application.casefold():
                raise ValueError(f"different application in {path}")
            captures[condition].append(result)

    metrics = ("fps_average", "fps_1pct_low", "frametime_p99_ms", "slow_frames_pct")
    summary = {}
    for condition, results in captures.items():
        summary[condition] = {}
        for metric in metrics:
            values = [result[metric] for result in results]
            summary[condition][metric] = {
                "median": statistics.median(values),
                "min": min(values),
                "max": max(values),
            }

    return {
        "application": application,
        "runs_per_condition": len(before),
        "target_fps": target_fps,
        "summary": summary,
        "delta_median_after_minus_before": {
            metric: summary["after"][metric]["median"] - summary["before"][metric]["median"]
            for metric in metrics
        },
        "captures": captures,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("capture", type=Path, nargs="?")
    parser.add_argument("--before", type=Path, nargs="+")
    parser.add_argument("--after", type=Path, nargs="+")
    parser.add_argument("--target-fps", type=float, required=True)
    args = parser.parse_args()
    if args.capture and (args.before or args.after):
        parser.error("choose one capture or a before/after comparison")
    if not args.capture and not (args.before and args.after):
        parser.error("provide a capture or both --before and --after")
    try:
        if args.capture:
            result = summarize(args.capture, args.target_fps)
        else:
            result = compare(args.before, args.after, args.target_fps)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    print(json.dumps(result, indent=2))



if __name__ == "__main__":
    main()
