---
description: Cài .editorconfig chuẩn Skybow vào dự án hiện tại và kiểm tra code C# có lệch convention không
---

Cài code style Skybow vào dự án đang mở.

1. Kiểm tra root repo hiện tại đã có `.editorconfig` chưa.
   - Chưa có → copy `${CLAUDE_PLUGIN_ROOT}/templates/.editorconfig` vào root repo.
   - Đã có → **KHÔNG ghi đè**. So sánh hai file, báo cho user những rule khác nhau và hỏi có merge không.
2. Đọc skill `csharp-code-style` (`${CLAUDE_PLUGIN_ROOT}/skills/csharp-code-style/SKILL.md`).
3. Kiểm tra dự án có stack ServiceLocator không: `grep -rl "class ServiceLocator" --include=*.cs .`
   - Có → đọc thêm `references/servicelocator-stack.md` và báo là tầng B được áp dụng.
   - Không → báo chỉ áp tầng A (generic C#).
4. Nếu dự án đã có code C#: quét nhanh 3 điểm hay lệch nhất rồi **chỉ báo cáo, không tự sửa**:
   - private field có prefix `_`
   - `namespace` dùng không nhất quán trong cùng module, hoặc file-scoped `namespace X;` (Skybow dùng namespace block)
   - `if` thân 1 câu lệnh nhưng viết cùng dòng với `if`
5. Báo cáo bằng tiếng Việt: đã copy gì, tầng nào áp dụng, các chỗ lệch tìm được. **Không sửa code trừ khi user yêu cầu.**
