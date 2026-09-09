# Tầng B — convention cho stack ServiceLocator

**Chỉ áp dụng khi dự án đã có sẵn** `ServiceLocator`, `IService`, `BaseDataService`, `EventDispatcher`.
Kiểm tra bằng `grep -rl "class ServiceLocator" Assets/` trước khi theo file này. Dự án không có → bỏ qua, đừng dựng kiến trúc này lên.

Nguồn chuẩn: `Roadside/Assets/_Assets/Scripts/_GameCore/Services/`.

## B1. Chọn base class

- Service **có state cần lưu** → kế thừa `BaseDataService` (có sẵn `storageService` + `dataKey`), implement `Initialize()` + `SaveData()`.
- Service **stateless** → implement thẳng `IService`, chỉ có `Initialize()`.
- Cần tick theo frame → thêm `ITickable`, viết `Tick(float deltaTime)`. **Không** dùng `MonoBehaviour.Update` trong service.
- Cần chạy sau khi mọi service đã Initialize → `IStartable`.

## B2. Vòng đời — chỗ hay làm sai nhất

```csharp
public class IncomeService : BaseDataService, ITickable
{
    private MapLocationService mapLocationService;   // dependency
    private SkillService skillService;

    private MapStationDataBlueprint mapStationDataBlueprint;   // static data

    private List<IncomeGlobalBonusData> incomeGlobalBonus = new();   // state

    public IncomeService()
    {
        // Constructor CHỈ đăng ký listener
        EventDispatcher.AddListener<ApplicationPauseStateChanged>(OnApplicationPauseStateChanged);
    }

    public override void Initialize()
    {
        // Resolve ở đây, KHÔNG resolve trong constructor (tránh phụ thuộc thứ tự đăng ký)
        mapLocationService = ServiceLocator.Resolve<MapLocationService>();
        mapStationDataBlueprint = ServiceLocator.Resolve<MapStationDataBlueprint>();

        incomeGlobalBonus = storageService.LoadData<List<IncomeGlobalBonusData>>(dataKey, out _);
    }

    public override void SaveData()
    {
        storageService.SaveData(dataKey, incomeGlobalBonus);
    }
}
```

## B3. Save

- `dataKey` do `BaseDataService` sinh = tên class. **Không tự đặt key string, không hardcode key.**
- Đọc/ghi save **chỉ qua `storageService.LoadData/SaveData`** — không gọi `PlayerPrefs` / `FastPlayerPrefs` trực tiếp ngoài lớp storage.
- `LoadData<T>(dataKey, out var isNew)` — dùng `isNew` để set giá trị mặc định cho người chơi mới. Không cần thì `out _`.
- **Không lưu giá trị dẫn xuất** — cái gì suy được từ field khác thì tính lúc đọc, đừng ghi vào save.

## B4. Event

- Đổi state có ảnh hưởng UI → `EventDispatcher.Raise(new XxxEvent(...));` ngay sau khi đổi, **trước** `return true`.
- Đăng ký listener trong constructor; handler `private void OnXxx(XxxEvent e)` đặt **cuối class**.
- Service **không giữ tham chiếu tới View**; View lắng nghe event.

## B5. Lookup

```csharp
private readonly Dictionary<int, MapData> mapDataLookup = new();

private void BuildMapDataLookup()
{
    mapDataLookup.Clear();

    foreach (var data in maps)
    {
        mapDataLookup[data.mapId] = data;
    }
}
```

- Field lookup luôn `readonly ... = new()`, rebuild bằng `BuildXxxLookup()` (Clear rồi nạp lại) sau mỗi lần list nguồn thay đổi.
- Tra bằng `GetValueOrDefault(...)`.

## B6. Static data (BlueprintFlow)

- Số liệu cân bằng game **đọc từ blueprint/bảng**, **không hardcode hằng số trong code**.
- Tra bằng `TryGetValue` / `TryGetXxx(..., out var record)`; tra không ra thì trả default an toàn + `Debug.LogError` nếu đó là data lẽ ra phải có.

## B7. Kiểu số

- Tiền / income / cost lớn → **`BigDouble`** (BreakInfinity). So sánh với `BigDouble.Zero`, không so với `0` trần.
- Currency premium đếm được → `int`. Thời gian → `float` (giây) hoặc `long` (millis).
- Hệ số / multiplier → `float`, giá trị trung tính là `1f`.
