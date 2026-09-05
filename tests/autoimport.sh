#!/usr/bin/env bash
# Auto-import / completion smoke test for every configured language.
#
# Drives a real Neovim in a pty (headless alone is not enough: cmp only fires on
# genuine TextChangedI events), types a symbol that is not yet imported, confirms
# the completion, then asserts the import statement actually landed in the buffer.
# That end-to-end path — server attached, completion offered, additionalTextEdits
# applied — is the thing that silently breaks, so it is the thing worth asserting.
#
#   ./tests/autoimport.sh            # run everything available
#   ./tests/autoimport.sh vue go     # run only the named languages
#
# Languages whose toolchain is missing are reported SKIP, never FAIL.

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROBE="$REPO/tests/probe.lua"
WORK="${TMPDIR:-/tmp}/nvim-autoimport-test.$$"
mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT

pass=0; fail=0; skip=0
RESULTS=()

have() { command -v "$1" >/dev/null 2>&1; }

# macOS ships no `timeout` (it is GNU coreutils; Homebrew installs it as
# `gtimeout`). Fall back to running the command unwrapped rather than failing
# every check with "command not found".
if have timeout; then   TIMEOUT() { timeout "$@"; }
elif have gtimeout; then TIMEOUT() { gtimeout "$@"; }
else                     TIMEOUT() { shift; "$@"; }
fi

# `script` differs between util-linux and BSD/macOS; both are used to get a pty.
run_nvim() {
  local dir="$1" file="$2"
  if [[ "$(uname)" == "Darwin" ]]; then
    ( cd "$dir" && script -q /dev/null \
        nvim -c "edit $file" -c "luafile $PROBE" ) >/dev/null 2>&1
  else
    ( cd "$dir" && script -qec "nvim -c 'edit $file' -c 'luafile $PROBE'" /dev/null ) \
        >/dev/null 2>&1
  fi
}

# name dir file line type pick expect wait
check() {
  local name="$1" dir="$2" file="$3"
  local log="$WORK/$name.log"
  rm -f "$log"
  PROBE_LOG="$log" PROBE_LINE="$4" PROBE_TYPE="$5" PROBE_PICK="$6" \
    PROBE_EXPECT="$7" PROBE_WAIT="$8" \
    TIMEOUT 300 bash -c "$(declare -f run_nvim); PROBE='$PROBE'; run_nvim '$dir' '$file'"

  if grep -q "RESULT  : PASS" "$log" 2>/dev/null; then
    RESULTS+=("PASS  $name"); pass=$((pass + 1))
  else
    local why
    why="$(grep 'RESULT' "$log" 2>/dev/null | head -1 | sed 's/RESULT  : //')"
    RESULTS+=("FAIL  $name  ${why:-no result (timeout?)}"); fail=$((fail + 1))
    [[ -s "$log" ]] && sed 's/^/        /' "$log" >&2
  fi
}

skip_lang() { RESULTS+=("SKIP  $1  ($2)"); skip=$((skip + 1)); }

SELECTED=("$@")
wanted() {
  [[ ${#SELECTED[@]} -eq 0 ]] && return 0
  local want
  for want in "${SELECTED[@]}"; do [[ "$want" == "$1" ]] && return 0; done
  return 1
}

# ---------------------------------------------------------------- typescript --
setup_ts() {
  mkdir -p "$WORK/ts/src"
  echo '{ "name": "t", "version": "1.0.0", "type": "module" }' > "$WORK/ts/package.json"
  echo '{ "compilerOptions": { "target": "ES2022", "module": "ESNext", "moduleResolution": "bundler", "strict": true, "jsx": "preserve" }, "include": ["src"] }' > "$WORK/ts/tsconfig.json"
  printf 'export function myUniqueHelper(x: number): number {\n  return x * 2;\n}\n' > "$WORK/ts/src/helpers.ts"
  printf 'const value = 1;\n\n' > "$WORK/ts/src/main.ts"
}

# ----------------------------------------------------------------------- vue --
setup_vue() {
  mkdir -p "$WORK/vue/src"
  echo '{ "name": "v", "version": "1.0.0", "type": "module", "dependencies": { "vue": "^3.5.0" } }' > "$WORK/vue/package.json"
  echo '{ "compilerOptions": { "target": "ES2022", "module": "ESNext", "moduleResolution": "bundler", "strict": true, "jsx": "preserve", "types": [] }, "include": ["src/**/*.ts", "src/**/*.vue"] }' > "$WORK/vue/tsconfig.json"
  printf 'export function myUniqueHelper(x: number): number {\n  return x * 2;\n}\n' > "$WORK/vue/src/helpers.ts"
  printf '<script setup lang="ts">\nconst value = 1;\n\n</script>\n\n<template>\n  <div>{{ value }}</div>\n</template>\n' > "$WORK/vue/src/App.vue"
  ( cd "$WORK/vue" && npm install --silent --no-audit --no-fund ) >/dev/null 2>&1
}

# ------------------------------------------------------------------------ go --
setup_go() {
  mkdir -p "$WORK/go"
  printf 'module example.com/t\n\ngo 1.21\n' > "$WORK/go/go.mod"
  printf 'package main\n\nfunc main() {\n\n}\n' > "$WORK/go/main.go"
}

# -------------------------------------------------------------------- python --
setup_py() {
  mkdir -p "$WORK/py"
  printf '[project]\nname = "t"\nversion = "0.1.0"\n' > "$WORK/py/pyproject.toml"
  printf 'value = 1\n\n' > "$WORK/py/main.py"
}

# ---------------------------------------------------------------------- java --
setup_java() {
  mkdir -p "$WORK/java/src/main/java/com/example"
  cat > "$WORK/java/pom.xml" <<'POM'
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId><artifactId>t</artifactId><version>1.0</version>
  <properties><maven.compiler.source>21</maven.compiler.source><maven.compiler.target>21</maven.compiler.target></properties>
</project>
POM
  printf 'package com.example;\n\npublic class App {\n    public void run() {\n\n    }\n}\n' \
    > "$WORK/java/src/main/java/com/example/App.java"
}

# -------------------------------------------------------------------- csharp --
setup_cs() {
  mkdir -p "$WORK/cs"
  ( cd "$WORK/cs" && dotnet new console --name App -o . ) >/dev/null 2>&1
  printf 'namespace App;\n\npublic class Worker\n{\n    public void Run()\n    {\n\n    }\n}\n' \
    > "$WORK/cs/Program.cs"
}

echo "auto-import checks (each drives a real nvim; jdtls in particular is slow)"
echo

if wanted ts; then
  if have node; then setup_ts
    check ts "$WORK/ts" "src/main.ts" 2 "myUniqueHelp" "myUniqueHelper" 'from "./helpers"' 15000
  else skip_lang ts "node not installed"; fi
fi

if wanted vue; then
  if have node && have npm; then setup_vue
    check vue "$WORK/vue" "src/App.vue" 3 "myUniqueHelp" "myUniqueHelper" "from './helpers'" 25000
  else skip_lang vue "node/npm not installed"; fi
fi

if wanted go; then
  if have go; then setup_go
    check go "$WORK/go" "main.go" 3 "fmt.Print" "Println" '"fmt"' 15000
  else skip_lang go "go not installed"; fi
fi

if wanted py; then
  setup_py
  check py "$WORK/py" "main.py" 2 "Path" "Path" "from pathlib import Path" 25000
fi

if wanted java; then
  if have java; then setup_java
    check java "$WORK/java" "src/main/java/com/example/App.java" 5 "List" "List" "import java.util.List" 35000
  else skip_lang java "no JDK on PATH"; fi
fi

if wanted cs; then
  if have dotnet; then setup_cs
    check cs "$WORK/cs" "Program.cs" 7 "StringBuil" "StringBuilder" "using System.Text;" 55000
  else skip_lang cs "no .NET SDK on PATH"; fi
fi

echo
[[ ${#RESULTS[@]} -gt 0 ]] && printf '%s\n' "${RESULTS[@]}"
echo
echo "pass=$pass fail=$fail skip=$skip"
[[ $fail -eq 0 ]]
