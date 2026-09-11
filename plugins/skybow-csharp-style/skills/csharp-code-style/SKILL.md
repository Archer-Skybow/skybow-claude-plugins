---
name: csharp-code-style
description: Coding convention và code format C# của studio Skybow cho dự án Unity. ĐỌC TRƯỚC KHI viết dòng C# đầu tiên - khi tạo mới hoặc sửa file .cs, viết service/manager/data class, review code C#, hoặc khi được hỏi "code theo format nào", "convention của dự án", "style guide". Gồm layout file, quy tắc đặt tên, guard clause, thứ tự thành viên trong class, pattern TryXxx(out msg), và .editorconfig chuẩn.
---

# Skybow C# Code Style

Convention dùng chung cho mọi dự án Unity của Skybow. Rút ra từ `Roadside/Assets/_Assets/Scripts/_GameCore/Services/`.

**Hai tầng — đọc đúng tầng:**

- **Tầng A (file này)** — generic C#/Unity, áp cho **mọi** dự án Skybow.
- **Tầng B** — `references/servicelocator-stack.md`, chỉ áp khi dự án có sẵn `ServiceLocator` / `BaseDataService` / `EventDispatcher` / `BlueprintFlow` / `BigDouble`. **Kiểm tra dự án có các lớp đó rồi mới đọc**; dự án không có thì bỏ qua hoàn toàn, đừng ép kiến trúc đó vào.

Khi sửa file cũ: theo style của **chính file đó**, đừng reformat hàng loạt.

---

## A1. Layout file

- Indent **4 space**, brace **Allman** (mở ngoặc xuống dòng riêng). Line ending **CRLF**.
- **`namespace` — dùng được khi cần.** Mặc định code Skybow ở global namespace, nhưng khi cần tách module / tránh trùng tên (library dùng chung, package, tool editor) thì cứ dùng `namespace`. Đã dùng thì **nhất quán trong cả module**, không nửa trong nửa ngoài. Style: `namespace` block Allman (không dùng file-scoped `namespace X;`), `using` đặt **ngoài** namespace.
- `using` gom ở đầu file, thứ tự: `System.*` → third-party → `UnityEngine*`. Không để `using` thừa.
- 1 file = 1 class chính, **tên file = tên class**. Ngoại lệ: file gom nhiều model nhỏ cùng chủ đề (`SkillModels.cs`).
- File dài chia bằng `#region TÊN VIẾT HOA` … `#endregion` (`#region PRIVATE METHODS`, `#region UNITY LIFECYCLE`), có dòng trắng trước và sau. File < ~100 dòng thì không cần region.

## A2. Đặt tên

| Loại | Quy ước | Ví dụ |
|---|---|---|
| Class / method / property / public field | `PascalCase` | `EconomyService`, `TrySpendCash` |
| **Private / protected field** | **`camelCase`, KHÔNG prefix `_`** | `economyService`, `incomeGlobalBonus` |
| Local variable | luôn `var` khi kiểu hiện rõ | `var stationData = ...` |
| Interface | prefix `I` | `IService`, `IStorageService` |
| Field cache một service | = tên class viết camelCase | `playerDataService` |
| Hậu tố vai trò | `XxxService` · `XxxData` (runtime, serialize) · `XxxBlueprint` / `XxxRecord` (static data) · `XxxSO` (ScriptableObject) · `XxxEvent` | |

⚠️ Field của class **đang serialize vào save** thì **không đổi tên** dù lệch convention — đổi là mất save. Thêm field mới vào class nào thì theo đúng kiểu chữ của class đó.

## A3. Guard clause & dòng trắng — đặc trưng dễ nhận nhất

```csharp
public BigDouble GetStationIncome(int mapId, int locationId, int stationId)
{
    var stationData = mapLocationService.GetStationData(mapId, locationId, stationId);

    if (stationData == null)
        return BigDouble.Zero;

    if (!blueprint.TryGetStationData(mapId, locationId, stationId, out var record))
        return BigDouble.Zero;

    var baseIncome = record.BaseIncome;
    ...
}
```

- Thân `if` **1 câu lệnh → KHÔNG braces**, viết xuống dòng (không viết cùng dòng với `if`).
- Thân `if` **từ 2 câu lệnh → có braces**.
- `foreach` / `for` / `while` **luôn có braces**, kể cả 1 câu lệnh.
- **Một dòng trắng** giữa khai báo `var` và `if` kiểm tra nó; giữa các khối guard; trước `return` cuối hàm dài.
- Guard trước, happy-path sau. Không lồng `if` sâu, **không `else` khi guard đã `return`**.
- `switch`: có dòng trắng trước `break;`.

## A4. Thứ tự thành viên trong class

1. `public` property (expression-bodied, trỏ thẳng vào data): `public BigDouble Cash => economyData.Cash;`
2. `public Action` / event
3. `private` field, nhóm cách nhau **1 dòng trắng**: dependency → static data → state/lookup
4. Constructor — **chỉ đăng ký listener**, không resolve dependency, không load data
5. `Initialize()` — resolve dependency, load data, build lookup
6. `SaveData()`
7. `Tick(float deltaTime)`
8. Public API
9. Private helper + event handler `OnXxx` — **cuối class**

## A5. Pattern trả kết quả

- Hành động có thể thất bại và **cần biết lý do** → `bool TryXxx(..., out string msg)`:

```csharp
public bool TryUpgradeStation(int mapId, int locationId, int stationId, out string msg)
{
    msg = string.Empty;

    // Check if station exists
    var stationData = GetStationData(mapId, locationId, stationId);

    if (stationData == null)
    {
        msg = "Station not found";
        return false;
    }

    // ... từng bước check, mỗi bước 1 comment `// Check ...`

    return true;
}
```

- Không cần lý do → `bool TryXxx(...)` gọn.
- **Getter luôn fail-safe**: không throw, không log lỗi, trả default — `0` / `1f` (multiplier) / `null` / `Zero` / `PositiveInfinity` (cost tra không ra).
- Tra bảng/dictionary bằng `TryGetValue(..., out var x)` hoặc `GetValueOrDefault(...)`, **không** `ContainsKey` rồi index lại.

## A6. Comment & log

- **Không dùng XML doc `///`**. Comment `//` ngắn, đặt trên dòng cần giải thích.
- Comment giải thích **"vì sao"**, không mô tả lại code. Quyết định thiết kế thì **trích nguồn spec** (vd `// 1.6 Map 2.md ## C`).
- Việc chưa làm → `// TODO: ...`.
- Log: `Debug.Log($"...")` string interpolation. `Debug.LogError` cho trạng thái data sai (thiếu record, count mismatch).
- **Không comment-out log lỗi ở đường đọc save** — mất tiến độ của người chơi phải nhìn thấy được.

## A7. `.editorconfig`

Phần format máy enforce được nằm ở `templates/.editorconfig` của plugin này (Rider/VS/`dotnet format` đọc trực tiếp).
Dự án chưa có file đó → dùng lệnh `/setup-csharp-style` để copy vào root repo.
