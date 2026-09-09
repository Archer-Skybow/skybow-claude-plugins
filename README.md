# Skybow Claude Plugins

Marketplace plugin dùng chung cho Claude Code của studio Skybow.

## Cài đặt (mỗi máy làm 1 lần)

Cài từ CMD/Powershell hoặc WSL

```bash
# 1. Thêm marketplace (đổi URL thành repo GitLab thật sau khi push)
claude plugin marketplace add https://github.com/Archer-Skybow/skybow-claude-plugins.git

# 2. Cài plugin
claude plugin install skybow-csharp-style@skybow-claude-plugins
```

Hoặc trong phiên Claude Code đang chạy:

```
/plugin marketplace add https://github.com/Archer-Skybow/skybow-claude-plugins.git
/plugin install skybow-csharp-style@skybow-claude-plugins
```

Kiểm tra: `claude plugin list`

## Plugin

### `skybow-csharp-style`

Coding convention + code format C# cho dự án Unity của Skybow, rút ra từ `Roadside/_GameCore/Services`.

| Thành phần | Tác dụng |
|---|---|
| Skill `csharp-code-style` | Convention 2 tầng — tầng A generic C#, tầng B chỉ áp khi dự án có stack ServiceLocator |
| `templates/.editorconfig` | Phần format Rider/VS/`dotnet format` tự enforce, áp cho cả người lẫn AI |
| Command `/setup-csharp-style` | Copy `.editorconfig` vào dự án + quét chỗ lệch convention (chỉ báo, không tự sửa) |
| Hook `SessionStart` | Nhắc convention đầu phiên, **chỉ khi** dự án thật sự có file `.cs` |

## Sửa convention

Sửa trong repo này rồi commit + push. Máy khác cập nhật bằng:

```bash
claude plugin marketplace update skybow-claude-plugins
```

Đừng sửa lệch từng dự án — dự án chỉ nên có `.editorconfig` copy từ `templates/`.
