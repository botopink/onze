#!/usr/bin/env bash
# runner-standalone.sh — the pre-commit gate of a botopink library.
#
# Sourced by scripts/git-hooks/pre-commit. It is the only runner: it needs
# nothing outside this repository (standalone clone, meta checkout, worktree,
# bpmp packing). Stages: conflict markers in staged files, a staged
# `*.snap.new` / `*.snap.md.new` (a snapshot mismatch's scratch file, never
# committed), the compiler binary (absent → the gate fails, it never skips),
# `botopink test` (per member under modules/*/ on every target its manifest
# declares — the root botopink.json is a workspace, decision 75: the umbrella
# compiles nothing and `botopink test` there is a refusal — else over the
# package's own src/ + test/), then `botopink build` of every example on every
# target its manifest declares (runExamplesGate — CI calls it too). Nothing is
# allow-listed: an example that does not build fails the gate (decision 67).
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }
pass() { echo -e "${GREEN}✓ $1${NC}"; }

locateBotopink() {
    if [ -n "${BOTOPINK_BIN:-}" ] && [ -x "$BOTOPINK_BIN" ]; then
        echo "$BOTOPINK_BIN"; return 0
    fi
    local cur; cur=$(pwd)
    while [ "$cur" != "/" ]; do
        local cand="$cur/repository/botopink-lang/zig-out/bin/botopink"
        [ -x "$cand" ] && { echo "$cand"; return 0; }
        cand="$cur/zig-out/bin/botopink"
        [ -x "$cand" ] && [ -f "$cur/build.zig" ] && { echo "$cand"; return 0; }
        cur=$(dirname "$cur")
    done
    command -v botopink >/dev/null 2>&1 && { command -v botopink; return 0; }
    return 1
}

runStandaloneGate() {
    local root
    root=$(git rev-parse --show-toplevel)
    cd "$root"

    # 1. conflict markers in staged files (regular files only — gitlinks skipped).
    local lt7 eq7 gt7
    lt7=$(printf '<%.0s' {1..7})
    eq7=$(printf '=%.0s' {1..7})
    gt7=$(printf '>%.0s' {1..7})
    local marker_re="${lt7} |${eq7}\$|${gt7} "
    local staged
    staged=$(git diff --cached --name-only --diff-filter=ACM)
    if [ -n "$staged" ]; then
        local hits=""
        while IFS= read -r f; do
            [ -z "$f" ] && continue
            [ -f "$f" ] || continue
            if grep -nE "$marker_re" "$f" 2>/dev/null | head -1 | grep -q .; then
                hits="$hits $f"
            fi
        done <<< "$staged"
        if [ -n "$hits" ]; then
            echo "  Conflict markers in:$hits"
            fail "Conflict markers found in staged files"
        fi
        pass "No conflict markers"
    fi

    # 2. a staged snapshot scratch file. A mismatch writes `<slug>.snap.new`
    #    (`.snap.md.new` for markdown snapshots) next to the snapshot; the
    #    snapshot is re-recorded on purpose or the code is fixed — the scratch
    #    file is never committed.
    local snaps
    snaps=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.snap(\.md)?\.new$' || true)
    if [ -n "$snaps" ]; then
        echo "$snaps" | sed 's/^/  /'
        fail "Staged *.snap.new / *.snap.md.new — re-record the snapshot or fix the code, never commit the scratch file"
    fi
    pass "No staged *.snap.new"

    # 3. the compiler. Absent is a failure, never a skipped gate.
    local bin
    if ! bin=$(locateBotopink); then
        echo "  botopink binary not found: set BOTOPINK_BIN to a built compiler, or build one"
        echo "  (cd repository/botopink-lang && zig build) so an ancestor zig-out/bin/botopink exists,"
        echo "  or put botopink on \$PATH"
        fail "botopink binary not found — the .bp gate cannot run"
    fi
    # The suites that build fixtures (onze-cli's build/create/generate/start
    # tests) read BOTOPINK_BIN: they compile with the compiler that runs them.
    export BOTOPINK_BIN="$bin"

    # 4. botopink test.
    if grep -q '"workspaces"' "$root/botopink.json" 2>/dev/null; then
        # A workspace: one `botopink test` per library member (modules/*/ with a
        # botopink.json) per target its manifest declares. The examples are
        # applications and are built by stage 5.
        local member found="" target
        for member in "$root"/modules/*/; do
            [ -f "$member/botopink.json" ] || continue
            found=1
            for target in $(manifestTargets "$member/botopink.json"); do
                echo -n "  Testing modules/$(basename "$member") · $target (botopink test)... "
                if ( cd "$member" && "$bin" test --target "$target" ) >/dev/null 2>&1; then
                    echo -e "${GREEN}✓${NC}"
                else
                    echo -e "${RED}✗${NC}"
                    echo
                    echo "  Re-run for failure output:  ( cd $member && $bin test --target $target )"
                    fail "$(basename "$member") · $target: botopink test failed"
                fi
            done
        done
        [ -n "$found" ] || fail "botopink.json is a workspace but no modules/*/ holds a botopink.json"
    else
        if [ -z "$(find src test 2>/dev/null -name '*.bp' ! -name '*.d.bp' | head -1)" ]; then
            echo "  (no .bp sources under src/ or test/ — nothing to test)"
            return 0
        fi
        local target
        for target in $(manifestTargets "$root/botopink.json"); do
            echo -n "  Testing $(basename "$root") · $target (botopink test)... "
            if ( cd "$root" && "$bin" test --target "$target" ) >/dev/null 2>&1; then
                echo -e "${GREEN}✓${NC}"
            else
                echo -e "${RED}✗${NC}"
                echo
                echo "  Re-run for failure output:  ( cd $root && $bin test --target $target )"
                fail "$(basename "$root") · $target: botopink test failed"
            fi
        done
    fi

    # 5. every example builds.
    runExamplesGate "$bin"
}

# manifestTargets <botopink.json>
#
# The targets a manifest declares, one per line — the lib-test runner's
# reading, so the hook runs exactly the cells CI runs: the member's `targets`
# list when it has one (a member may only restrict), else the workspace's
# `targets`, else every target `botopink test` runs (commonJS erlang). A
# member's `target` (the default of a bare `botopink build`) is not a
# restriction and is not read.
manifestTargets() {
    local file="$1"
    local listed
    listed=$(targetsListOf "$file")
    if [ -n "$listed" ]; then
        echo "$listed"; return 0
    fi
    local root
    root=$(git rev-parse --show-toplevel)
    listed=$(targetsListOf "$root/botopink.json")
    if [ -n "$listed" ]; then
        echo "$listed"; return 0
    fi
    printf 'commonJS\nerlang\n'
}

# targetsListOf <botopink.json> — the `targets` array's entries, one per line;
# empty when the manifest has none.
targetsListOf() {
    [ -f "$1" ] || return 0
    tr -d '\n\r' < "$1" | sed -n 's/.*"targets"[[:space:]]*:[[:space:]]*\[\([^]]*\)\].*/\1/p' | tr -d '" ' | tr ',' '\n' | sed '/^$/d'
}

# runExamplesGate <botopink-bin> [<target>]
#
# Builds every `examples/*/` that has a `botopink.json` on every target its
# manifest declares (into a throwaway --out) — or, with `<target>`, on that
# one target for the examples that declare it (a CI row builds its own
# target). There is no allow list: an example that does not build fails the
# gate.
runExamplesGate() {
    local bin="$1"
    local only="${2:-}"
    local root
    root=$(git rev-parse --show-toplevel)
    local dir name rel out target bad=""
    for dir in "$root"/examples/*/; do
        [ -f "$dir/botopink.json" ] || continue
        name=$(basename "$dir")
        rel="examples/$name"
        for target in $(manifestTargets "$dir/botopink.json"); do
            [ -z "$only" ] || [ "$target" = "$only" ] || continue
            out=$(mktemp -d)
            echo -n "  Building $rel · $target (botopink build)... "
            if ( cd "$dir" && "$bin" build --target "$target" --out "$out" ) >/dev/null 2>&1; then
                echo -e "${GREEN}✓${NC}"
            else
                echo -e "${RED}✗${NC}"
                bad="$bad\n  $rel · $target does not build — re-run: ( cd $dir && $bin build --target $target --out \$(mktemp -d) )"
            fi
            rm -rf "$out"
        done
    done
    if [ -n "$bad" ]; then
        echo -e "$bad"
        fail "$(basename "$root"): examples gate failed"
    fi
}
