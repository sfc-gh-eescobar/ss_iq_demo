#!/usr/bin/env python3
import json, subprocess, sys, os

SKILL_DIR = "/Applications/SnowWork.app/Contents/Resources/app/resources/snowflake/skills/cortex-code-skills/cortex-agent"
OUTDIR = "/Users/eescobar/Desktop/Customers/Shake_Shack/Marketing_Agent/demo_test"
CONN = "SFSENORTHAMERICA_EESCOBAR"

with open(f"{OUTDIR}/questions.json") as f:
    questions = json.load(f)

qkey = sys.argv[1]
question = questions[qkey]
outfile = f"{OUTDIR}/{qkey}.json"

cmd = [
    "uv", "run", "--project", SKILL_DIR,
    "python", f"{SKILL_DIR}/scripts/chat_with_agent.py",
    "--agent-name", "SHAKE_SHACK_IQ_AGENT",
    "--database", "DEMO_DB",
    "--schema", "SHAKE_SHACK",
    "--connection", CONN,
    "--question", question,
    "--output-file", outfile,
]

print(f"Testing {qkey}: {question[:80]}...")
result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
print(f"stdout: {result.stdout[-200:]}" if result.stdout else "No stdout")
print(f"stderr: {result.stderr[-200:]}" if result.stderr else "No stderr")
print(f"Return code: {result.returncode}")
print(f"File exists: {os.path.exists(outfile)}")
if os.path.exists(outfile):
    with open(outfile) as f:
        data = json.load(f)
    for item in data.get('content', []):
        if item.get('type') == 'text':
            print(f"\n--- TEXT ---\n{item['text'][:1500]}")
