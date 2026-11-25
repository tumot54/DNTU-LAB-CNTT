# DNTU Lab - Hướng dẫn thiết lập môi trường Local

Tài liệu dành cho thành viên phát triển dự án DNTU Lab trên Windows. Môi trường mặc định là **PostgreSQL chạy local trên máy từng thành viên**. Neon chỉ dùng khi cần kiểm thử tích hợp và phải được cấp quyền/Connection String riêng.

> Tài liệu này bổ sung cho `Database/README_PostgreSQL_Deploy.txt`; không thay thế tài liệu triển khai Database đó.

## 1. Kiến trúc chạy local

- Backend: ASP.NET Core Web API, target framework `net8.0`.
- ORM: Entity Framework Core; PostgreSQL provider `Npgsql.EntityFrameworkCore.PostgreSQL`.
- Frontend: file tĩnh nằm trong `DntuLab.API/wwwroot/`; ASP.NET Core phục vụ trực tiếp frontend.
- URL local theo `Properties/launchSettings.json`: `http://localhost:5266`.
- Swagger: `http://localhost:5266/swagger`.
- Không cần chạy một frontend server riêng cho cấu trúc hiện tại.

## 2. Phần mềm cần có

Cài đặt và kiểm tra:

1. Git for Windows.
2. .NET 8 SDK (project target `net8.0`). Kiểm tra bằng `dotnet --list-sdks`; danh sách cần có một SDK phiên bản `8.0.xxx`.
3. PostgreSQL (cài PostgreSQL Server và pgAdmin nếu muốn quản lý bằng giao diện).
4. Visual Studio 2022 có workload ASP.NET and web development, hoặc VS Code/editor tương đương.

Kiểm tra trong CMD hoặc PowerShell:

```powershell
git --version
dotnet --list-sdks
dotnet --info
psql --version
```

Nếu máy có nhiều .NET SDK, vẫn cần bảo đảm SDK 8 được cài. Không lấy việc `dotnet --version` trả về 10.x làm bằng chứng rằng SDK 8 đã có.

## 3. Clone repository và tạo branch cá nhân

Thay URL/branch theo quyền và phân công của nhóm. Ví dụ:

```powershell
git clone https://github.com/tumot54/DNTU-LAB-CNTT.git
cd DNTU-LAB-CNTT
git fetch origin
git switch -c dev-ten-cua-ban origin/main
```

Nếu branch cá nhân đã tồn tại trên remote:

```powershell
git clone -b dev-ten-cua-ban https://github.com/tumot54/DNTU-LAB-CNTT.git
cd DNTU-LAB-CNTT
```

Không làm việc trực tiếp trên `main`. Trước khi bắt đầu task mới, cập nhật branch theo quy trình Git mà nhóm thống nhất.

## 4. Tạo PostgreSQL database local

Tạo database riêng trên máy thành viên, ví dụ tên `DntuLab`. Có thể tạo bằng pgAdmin hoặc SQL:

```sql
CREATE DATABASE "DntuLab";
```

Ghi lại host, port, username và password PostgreSQL local. Cấu hình mẫu bên dưới giả định PostgreSQL chạy tại `localhost:5432`; nếu máy dùng giá trị khác thì thay lại cho đúng.

**Không dùng Connection String Neon Production cho bước setup local.** Không chia sẻ password, Connection String hoặc JWT secret qua Git, ảnh chụp màn hình hay chat nhóm.

## 5. Cấu hình ứng dụng (2 file)

Project dùng hai file cấu hình:

- `DntuLab.API/appsettings.json`: cấu hình mặc định được commit lên Git.
- `DntuLab.API/appsettings.Development.json`: cấu hình Development riêng trên máy; file này được `.gitignore` bỏ qua.

Mở `DntuLab.API/appsettings.Development.json`. Nếu chưa có, tạo file mới và đặt nội dung sau, thay các giá trị viết hoa bằng thông tin local của máy:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=DntuLab;Username=postgres;Password=YOUR_LOCAL_POSTGRES_PASSWORD"
  },
  "Jwt": {
    "Key": "REPLACE_WITH_A_PRIVATE_RANDOM_KEY_AT_LEAST_32_CHARACTERS",
    "Issuer": "DntuLab.API",
    "Audience": "DntuLab.Client",
    "ExpiresMinutes": 60
  },
  "Database": {
    "SeedOnStartup": false
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

Lưu ý:

- `Jwt:Key` không được để trống. Dùng secret riêng của máy, đủ dài (ít nhất 32 ký tự); không dùng chuỗi ví dụ ở trên nguyên văn.
- Giữ `Issuer` là `DntuLab.API`, `Audience` là `DntuLab.Client` để khớp cấu hình hiện tại.
- `Database:SeedOnStartup` để `false` theo mặc định. Chỉ bật khi thực sự muốn chạy seeder khởi động trên database local.
- Không commit `appsettings.Development.json`. Kiểm tra bằng `git check-ignore -v DntuLab.API/appsettings.Development.json`.

## 6. Cài công cụ EF Core và khôi phục packages

Mở PowerShell tại thư mục chứa `DntuLab.API.csproj`:

```powershell
cd DntuLab.API
dotnet tool install --global dotnet-ef --version 8.0.11
```

Nếu đã cài `dotnet-ef`, kiểm tra:

```powershell
dotnet ef --version
```

Nếu phiên bản global hiện tại khác 8.0.11, có thể cập nhật:

```powershell
dotnet tool update --global dotnet-ef --version 8.0.11
```

Khôi phục package và build:

```powershell
dotnet restore
dotnet build
```

Project đang tham chiếu `Microsoft.EntityFrameworkCore.Design` và `Npgsql.EntityFrameworkCore.PostgreSQL` phiên bản `8.0.11`; dùng `dotnet-ef` 8.0.11 để đồng bộ công cụ với dependency EF Core của project.

## 7. Tạo schema bằng EF Core migrations

Đảm bảo đang đứng tại `DntuLab.API` và `appsettings.Development.json` trỏ đến database local đúng.

```powershell
dotnet ef database update
```

Lệnh trên áp dụng các migration hiện có vào database được cấu hình. Không chạy lệnh này khi Connection String đang trỏ đến Neon Production.

**Cảnh báo migration:** migration `20261123135000_RemoveTemporaryIncidentNotes` có thao tác xóa bảng `GhiNhanTam`. Nếu database đã có dữ liệu cũ cần giữ, hãy backup và đọc `Database/README_PostgreSQL_Deploy.txt` trước khi cập nhật. Down migration không khôi phục dữ liệu đã bị xóa.

## 8. Seed dữ liệu demo

Có hai cách được hỗ trợ trong source hiện tại:

### Cách A - Seed khi ứng dụng khởi động

Trong `appsettings.Development.json`, đặt:

```json
"Database": {
  "SeedOnStartup": true
}
```

Sau đó khởi động ứng dụng. Seeder hiện tại kiểm tra tài khoản tồn tại trước khi thêm, và chỉ chạy khi `SeedOnStartup` là `true`. Khi seed xong, nên đặt lại `false` nếu không muốn seeder chạy ở các lần khởi động sau.

Các tài khoản demo được khai báo trong `Program.cs`:

| Username | Password demo | Vai trò |
|---|---|---|
| `gv01` | `Gv@123456` | Giảng viên |
| `gv02` | `Gv@123456` | Giảng viên |
| `ktv01` | `Ktv@123456` | Kỹ thuật viên |
| `ql01` | `Ql@123456` | Quản lý LAB |

Chỉ dùng các tài khoản/mật khẩu này trên database local phục vụ phát triển. Không bật seeder khi kết nối Neon Production.

### Cách B - Dùng bộ SQL seed

Nếu cần tạo đầy đủ danh mục, lịch và dữ liệu demo theo kịch bản của nhóm, làm theo đúng thứ tự và điều kiện trong `Database/README_PostgreSQL_Deploy.txt`. Không tự ý chạy script cũ hoặc script reset.

## 9. Chạy Backend và mở giao diện

Từ thư mục `DntuLab.API`:

```powershell
dotnet run
```

Theo `launchSettings.json`, môi trường là `Development` và URL là:

- Ứng dụng: `http://localhost:5266`
- Swagger: `http://localhost:5266/swagger`

Frontend được phục vụ từ `wwwroot`; mở `http://localhost:5266` để vào giao diện. Không cần chạy `npm install` hoặc `npm run dev` cho frontend tĩnh hiện tại.

## 10. Kiểm tra sau khi chạy

- [ ] Backend khởi động không báo thiếu `ConnectionStrings:DefaultConnection`.
- [ ] Backend khởi động không báo thiếu `Jwt:Key`.
- [ ] Mở được Swagger tại `/swagger`.
- [ ] Mở được giao diện tại `/`.
- [ ] Đăng nhập được bằng tài khoản demo nếu đã seed.
- [ ] Các API đọc/ghi hoạt động với database local.

## 11. Quy tắc sử dụng Neon khi kiểm thử tích hợp

- Mặc định mỗi thành viên phát triển trên PostgreSQL local riêng.
- Chỉ kết nối Neon khi cần kiểm thử tích hợp hoặc xác minh vấn đề trên môi trường dùng chung.
- Dùng Connection String do người quản lý môi trường cung cấp; không lưu vào Git hoặc gửi công khai.
- Ưu tiên Neon branch/database kiểm thử riêng nếu cần thử migration hoặc dữ liệu phá hủy.
- Không tự ý chạy `dotnet ef database update`, SQL seed, script sửa schema hoặc script xóa dữ liệu trên Neon Production.
- Trước mọi thay đổi schema trên môi trường dùng chung, thống nhất với người quản lý database và có phương án backup/rollback.

## 12. Lỗi thường gặp

| Hiện tượng | Hướng xử lý |
|---|---|
| Thiếu `ConnectionStrings:DefaultConnection` | Kiểm tra tên key và file `appsettings.Development.json`; bảo đảm JSON hợp lệ và Connection String đúng. |
| Thiếu `Jwt:Key` | Điền secret riêng đủ dài vào `Jwt:Key`. |
| Không kết nối được PostgreSQL | Kiểm tra PostgreSQL service, host, port, database, username và password. |
| `dotnet ef` không tìm thấy | Cài/cập nhật `dotnet-ef` 8.0.11 và mở terminal mới nếu PATH chưa cập nhật. |
| Build lỗi sau khi clone | Chạy `dotnet restore`, sau đó `dotnet build`; đọc lỗi đầu tiên có ý nghĩa trong output. |
| Port 5266 đang được sử dụng | Đóng tiến trình đang giữ port hoặc phối hợp đổi `applicationUrl` và các cấu hình URL liên quan; không tự đổi riêng một nơi. |
| Đăng nhập không được | Kiểm tra đã seed tài khoản chưa, API có kết nối đúng database không và xem lỗi trong terminal/Swagger. |

## 13. An toàn dữ liệu và Git

- Không commit `appsettings.Development.json`, password, JWT key, Connection String hoặc file secret.
- Không chạy `00_ResetDatabase_PostgreSQL.sql` trên database có dữ liệu cần giữ.
- Không dùng Neon Production làm database phát triển thường ngày.
- Không push trực tiếp lên `main`; làm việc trên branch cá nhân và tạo Pull Request theo quy trình nhóm.
- Khi gặp migration có thao tác DROP/DELETE/ALTER, đọc nội dung migration và thống nhất trước khi áp dụng lên database dùng chung.
