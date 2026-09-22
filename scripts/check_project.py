"""Check Efinity project references without requiring the FPGA toolchain."""

from pathlib import Path
import json
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
NS = {"e": "http://www.efinixinc.com/enf_proj"}


def main():
    project = ET.parse(ROOT / "Ti60_Demo.xml").getroot()
    ET.parse(ROOT / "Ti60_Demo.peri.xml")
    references = {"Ti60_Demo.xml", "Ti60_Demo.peri.xml"}
    directories = set()
    for tag in ("design_file", "sdc_file"):
        references.update(n.attrib["name"] for n in project.findall(f".//e:{tag}", NS))
    for ip in project.findall(".//e:ip", NS):
        config = Path(ip.attrib["path"])
        references.add(config.as_posix())
        if (ROOT / config).is_file():
            json.loads((ROOT / config).read_text(encoding="utf-8-sig"))
        references.update((config.parent / n.attrib["name"]).as_posix()
                          for n in ip.findall("e:ip_src_file", NS))
    for param in project.findall(".//e:param", NS):
        if param.attrib.get("name") == "include":
            directories.add(param.attrib["value"])
        if param.attrib.get("name") == "profile" and param.attrib.get("value"):
            references.add(param.attrib["value"])
    errors = []
    for name in sorted(references):
        if not (ROOT / name).is_file():
            errors.append(f"Missing file: {name}")
    for name in sorted(directories):
        if not (ROOT / name).is_dir():
            errors.append(f"Missing include directory: {name}")
    if (ROOT / ".git").exists():
        tracked = set(subprocess.check_output(
            ["git", "ls-files", "-z"], cwd=ROOT).decode("utf-8").split("\0"))
        for name in sorted(references - tracked):
            errors.append(f"Referenced file is not tracked: {name}")
        ignored = subprocess.check_output(
            ["git", "ls-files", "-ci", "--exclude-standard", "-z"], cwd=ROOT)
        if ignored:
            errors.append("Generated/local files are still tracked by Git.")
    for error in errors:
        print(f"ERROR: {error}")
    print(f"Checked {len(references)} file references and {len(directories)} include directories.")
    print("File checks only; HDL compilation, simulation and hardware are not verified.")
    return 1 if errors else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, ET.ParseError, subprocess.CalledProcessError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
