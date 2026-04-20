#!/usr/bin/env python3
import json, subprocess, sys, os

SKILL_DIR = "/Applications/SnowWork.app/Contents/Resources/app/resources/snowflake/skills/cortex-code-skills/cortex-agent"
OUTDIR = "/Users/eescobar/Desktop/Customers/Shake_Shack/Marketing_Agent/demo_test"
CONN = "SFSENORTHAMERICA_EESCOBAR"

with open(f"{OUTDIR}/csuite_questions.json") as f:
    questions = json.load(f)

qkey = sys.argv[1]
question = questions[qkey]
outfile = f"{OUTDIR}/csuite_{qkey}.json"

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
if result.returncode != 0:
    print(f"FAILED (rc={result.returncode})")
    print(f"stderr: {result.stderr[-500:]}")
    sys.exit(1)

if not os.path.exists(outfile):
    print("NO OUTPUT FILE")
    print(f"stdout tail: {result.stdout[-500:]}")
    sys.exit(1)

with open(outfile) as f:
    data = json.load(f)

tools_used = set()
for item in data.get('content', []):
    if item.get('type') == 'tool_use':
        tools_used.add(item.get('tool_use', {}).get('name', '?'))
    if item.get('type') == 'tool_result':
        tools_used.add(item.get('tool_result', {}).get('name', '?'))

print(f"OK - Tools used: {tools_used}")
for item in data.get('content', []):
    if item.get('type') == 'text':
        print(f"\n--- RESPONSE ---\n{item['text'][:2000]}")
        break
