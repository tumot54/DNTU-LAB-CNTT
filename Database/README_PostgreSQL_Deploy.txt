# DNTU Lab - PostgreSQL Deploy Pack (23/11/2026)

## Pham vi cap nhat

Bo SQL nay duoc dong bo theo cac quyet dinh moi nhat:
- Ma phong chinh xac la `AIBOT`, khong phai `AILAB`.
- Danh muc 9 phong: `AIHUB`, `AIBOT`, `F507`-`F509`, `G201`-`G204`.
- Suc chua: AIHUB 30; AIBOT 80; F507-F509 40/phong; G201-G204 65/phong.
- F507-F509 van co 50 PC/phong. Suc chua phong khong phai so luong PC.
- G201-G204: TV, WIFI, tu sac laptop (3 thiet bi/phong).
- AIHUB va AIBOT moi phong co AI-KIT01..AI-KIT03. MaThietBi co the trung giua hai phong.
- `ThietBi.Id` la PK; UNIQUE `(MaPhong, MaThietBi)`.
- `TicketSuCo.ThietBiId` la FK den `ThietBi.Id`.
- Khong tao `GhiNhanTam` / GN00x trong luong moi.
- Khong co lenh reset database, DROP phong, DELETE du lieu.

## Luu y ve Cum phong AI

Backend FIX hien tai khai bao CHECK constraint:
`CK_Phong_Cum IN ('F', 'G', 'AIBOT')`.

Vi vay ca AIHUB va AIBOT duoc seed voi `Cum = 'AIBOT'` de khop schema hien tai. Neu muon AIHUB co `Cum = 'AI'`, can sua Domain/Constants.cs + LabDbContext + tao migration moi truoc; khong duoc chi sua SQL.

## Thu tu chay

1. Sao luu PostgreSQL truoc khi ap dung migration.
2. Mo PowerShell tai thu muc co `DntuLab.API.csproj`, chay `01_CreateSchema_PostgreSQL.ps1`.
   - Script chay `dotnet ef database update`.
   - Migration `20261123135000_RemoveTemporaryIncidentNotes` se DROP bang `GhiNhanTam`.
   - Neu can giu du lieu GN cu, phai export/sao luu bang truoc. Down migration khong khoi phuc duoc du lieu.
3. Chay `01A_Rename_AILAB_to_AIBOT.sql` trong pgAdmin/psql.
   - Neu chi co AILAB: cap nhat FK va doi ma phong.
   - Neu chi co AIBOT: khong doi gi.
   - Neu ca AILAB va AIBOT: script dung va rollback; can doi chieu thu cong, khong tu dong tron du lieu.
4. Chay `02_SeedData_PostgreSQL.sql`.
5. Chay `03_SeedAccounts_PostgreSQL.sql` (chi INSERT tai khoan demo neu chua co; khong reset mat khau tai khoan cu).
6. Chay `04_SeedLichDay_PostgreSQL.sql`.
   - Neu 168 lich da ton tai, script bo qua lich trung theo Ngay/Ca/GiangVienId.
   - Neu xung dot phong/giang vien, script bao loi va rollback block.
7. Chay `05_Verify_PostgreSQL.sql` (chi SELECT).
8. Neu can du lieu Ticket/YeuCau demo, chay `06_SeedTickets_YeuCau_PostgreSQL.sql`.
   - Script dung `ThietBiId` va cap `(MaPhong, MaThietBi)`.
   - Khong tao GN00x.
   - Chi seed yeu cau doi phong trong F/G; khong dung AIHUB/AIBOT.

## Khong lam

- KHONG chay `00_ResetDatabase_PostgreSQL.sql`.
- KHONG chay seed cu chua duoc cap nhat.
- KHONG xoa G205-G209 tu dong. Verify se liet ke neu co; can kiem tra FK va du lieu truoc khi xoa phong cu.
- KHONG chay `06_SeedTickets...` tren production neu khong muon co Ticket demo.
- Khong gui ConnectionString, password, JWT key hoac secret vao file SQL/Git.

## Ket qua du kien tren database demo rong

- 9 phong.
- 168 thiet bi: 150 PC + 12 thiet bi cum G + 6 KIT AI.
- 4 tai khoan demo (neu chua ton tai).
- 168 lich (42 ngay x 4 ca) neu chua co lich.
- 7 Ticket demo neu chua co Ticket dang mo cho cac thiet bi mau.
- Toi da 4 YeuCauDoiPhong demo neu co lich F/G phu hop trong 24-30/11/2026.

So lieu tren la muc du kien tren database demo rong; database da co du lieu se co tong so khac. Tat ca seed deu tranh xoa du lieu hien co.
