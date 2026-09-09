#!/usr/bin/env bash
# SessionStart hook: chỉ nhắc convention khi dự án hiện tại thật sự có code C#.
# stdout của SessionStart được Claude Code nạp thẳng vào context.
set -u

INPUT=$(cat 2>/dev/null || true)

CWD=$(printf '%s' "$INPUT" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$CWD" ] && CWD=$(pwd)
[ -d "$CWD" ] || exit 0

# Có file .cs nào không (bỏ qua Library/Temp/obj của Unity)
HAS_CS=$(find "$CWD" -name '*.cs' -not -path '*/Library/*' -not -path '*/Temp/*' -not -path '*/obj/*' -not -path '*/.git/*' -print -quit 2>/dev/null)
[ -z "$HAS_CS" ] && exit 0

HAS_EC=""
[ -f "$CWD/.editorconfig" ] && HAS_EC=" | .editorconfig: có"
[ -z "$HAS_EC" ] && HAS_EC=" | .editorconfig: CHƯA CÓ, gợi ý chạy /setup-csharp-style"

cat <<EOF
[Skybow C# code style] Dự án này có code C#$HAS_EC
Trước khi viết/sửa file .cs, đọc skill "csharp-code-style" (plugin skybow-csharp-style). Tóm tắt bắt buộc:
- 4 space, brace Allman, CRLF, KHÔNG namespace, tên file = tên class.
- private field camelCase KHÔNG prefix "_"; public PascalCase; interface prefix I; local dùng var.
- Guard clause: if thân 1 câu lệnh -> không braces, xuống dòng; loop LUÔN có braces; 1 dòng trắng giữa khai báo var và if kiểm tra nó; không else sau return.
- Thứ tự thành viên: property -> event -> private field -> ctor (chỉ đăng ký listener) -> Initialize -> SaveData -> Tick -> public API -> private helper.
- Việc có thể fail: bool TryXxx(..., out string msg). Getter fail-safe, trả default, không throw.
- Không XML doc ///; comment giải thích "vì sao"; // TODO: cho việc chưa làm.
Sửa file cũ thì theo style của chính file đó, không reformat hàng loạt.
EOF
exit 0
