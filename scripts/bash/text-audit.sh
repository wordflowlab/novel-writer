#!/usr/bin/env bash
# 文本人味自查（离线）：连接词/空话密度、句长统计、抽象词密度

set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

PROJECT_ROOT=$(get_project_root)

FILE_PATH="$1"
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  echo "用法: scripts/bash/text-audit.sh <file>"
  exit 1
fi

# 选择配置：优先项目 spec/knowledge，其次 .specify/templates/knowledge
CFG_PROJECT="$PROJECT_ROOT/spec/knowledge/audit-config.json"
CFG_TEMPLATE="$PROJECT_ROOT/.specify/templates/knowledge/audit-config.json"
if [ -f "$CFG_PROJECT" ]; then
  CFG="$CFG_PROJECT"
elif [ -f "$CFG_TEMPLATE" ]; then
  CFG="$CFG_TEMPLATE"
else
  CFG=""
fi

python3 - "$FILE_PATH" "$CFG" << 'PY'
import json, re, sys, os, math

path = sys.argv[1]
cfg_path = sys.argv[2] if len(sys.argv) > 2 else ''

text = open(path, 'r', encoding='utf-8', errors='ignore').read()

default_cfg = {
  "connector_phrases": ["首先","其次","再次","然后","然而","总而言之","综上所述","在某种程度","众所周知","在当下","随着"],
  "empty_phrases": ["广泛关注","引发热议","影响深远","具有重要意义","有效提升","具有一定的指导意义","值得我们思考"],
  "cliche_pairs": [],
  "sentence_length": {"max_run_long":4, "max_run_short":5, "short_threshold":12, "long_threshold":35},
  "abstract_nouns": ["价值","意义","认知","体系","模式","路径","方法论","趋势"],
  "min_concrete_details": 3
}

cfg = default_cfg
if cfg_path and os.path.exists(cfg_path):
  try:
    with open(cfg_path, 'r', encoding='utf-8') as f:
      loaded = json.load(f)
      cfg.update(loaded)
  except Exception:
    pass

def count_occurrences(text, phrases):
  res = {}
  for p in phrases:
    if not p: continue
    res[p] = len(re.findall(re.escape(p), text))
  return res

def split_sentences(t):
  parts = re.split(r'[。！？!?\n]+', t)
  return [s.strip() for s in parts if s.strip()]

def sentence_lengths(sents):
  lens = [len(s) for s in sents]
  if not lens:
    return lens, 0, 0
  avg = sum(lens)/len(lens)
  var = sum((x-avg)**2 for x in lens)/len(lens)
  return lens, avg, math.sqrt(var)

def runs(lens, short_th, long_th):
  run_short = 0; run_long = 0
  max_run_short = 0; max_run_long = 0
  marks = []
  for i, L in enumerate(lens):
    if L <= short_th:
      run_short += 1; max_run_short = max(max_run_short, run_short); run_long = 0
    elif L >= long_th:
      run_long += 1; max_run_long = max(max_run_long, run_long); run_short = 0
    else:
      run_short = 0; run_long = 0
  return max_run_short, max_run_long

def abstract_density(sent, abstract_words):
  cnt = sum(len(re.findall(re.escape(w), sent)) for w in abstract_words)
  return cnt

connectors = count_occurrences(text, cfg["connector_phrases"])
empties = count_occurrences(text, cfg["empty_phrases"])
sents = split_sentences(text)
lens, avg, std = sentence_lengths(sents)
mx_run_short, mx_run_long = runs(lens, cfg["sentence_length"]["short_threshold"], cfg["sentence_length"]["long_threshold"])

abstract_scores = [(i, abstract_density(s, cfg["abstract_nouns"])) for i, s in enumerate(sents)]
abstract_scores.sort(key=lambda x: x[1], reverse=True)
abstract_top = [ (i, sents[i]) for i,score in abstract_scores[:5] if score>=2 ]

total_chars = len(text)
def ratio(count):
  return (count / max(1,total_chars)) * 1000

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📊 离线文本人味自查报告")
print(f"文件: {os.path.basename(path)}  字符数: {total_chars}")
print("")
print("连接词密度（每千字出现次数）")
total_conn = sum(connectors.values())
print(f"  总计: {total_conn}  | 比率: {ratio(total_conn):.2f}")
for k,v in sorted(connectors.items(), key=lambda x: -x[1])[:10]:
  if v>0: print(f"  - {k}: {v}")

print("")
print("空话/套话计数")
total_emp = sum(empties.values())
print(f"  总计: {total_emp}  | 比率: {ratio(total_emp):.2f}")
for k,v in sorted(empties.items(), key=lambda x: -x[1])[:10]:
  if v>0: print(f"  - {k}: {v}")

print("")
print("句长统计")
print(f"  句子数: {len(lens)}  | 平均: {avg:.1f}  | 标准差: {std:.1f}")
print(f"  连续短句最大: {mx_run_short} (阈值 {cfg['sentence_length']['max_run_short']})")
print(f"  连续长句最大: {mx_run_long} (阈值 {cfg['sentence_length']['max_run_long']})")

print("")
print("抽象过载（示例段，≥2 抽象词）")
if abstract_top:
  for idx, s in abstract_top:
    snippet = s[:80] + ("…" if len(s)>80 else "")
    print(f"  - 第{idx+1}句: {snippet}")
else:
  print("  无显著抽象过载片段")

print("")
print("建议")
print("  - 用具体动作/器物/气味替代空话与抽象名词")
print("  - 打断长长串句子；合并过多的短句以形成起伏")
print("  - 复查连接词是否可删除或自然过渡")
print("  - 写前先列3个生活细节作为锚点")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
PY

