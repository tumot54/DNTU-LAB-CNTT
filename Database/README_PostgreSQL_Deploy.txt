# DNTU Lab - PostgreSQL Deploy Pack (AIBOT)

## Pham vi va quy uoc

- Ma phong AI chuan la `AIHUB` va `AIBOT`; `AILAB` chi la ma cu de nhan dien/chuyen doi.
- Danh muc 9 phong: `AIHUB`, `AIBOT`, `F507`-`F509`, `G201`-`G204`.
- Suc chua: AIHUB 30; AIBOT 80; F507-F509 40/phong; G201-G204 65/phong.
- F507-F509 van co 50 PC/phong. Suc chua phong khong phai so luong PC.
- G201-G204: TV, WIFI, tu sac laptop (3 thiet bi/phong).
- AIHUB va AIBOT moi phong co AI-KIT01..AI-KIT03. MaThietBi co the trung giua hai phong.
- `ThietBi.Id` la PK; UNIQUE `(MaPhong, MaThietBi)`.
- `TicketSuCo.ThietBiId` la FK den `ThietBi.Id`.
- Khong tao `GhiNhanTam` / GN00x trong luong Ticket moi.
- Khong co lenh reset database.

## Quy uoc Cum AI

Database hien tai da duoc kiem tra truc tiep: CHECK constraint cua `Phong.Cum` cho phep `F`, `G`, `AI`.
Vi vay ca `AIHUB` va `AIBOT` dung `Cum = 'AI'`. Khong tu doi gia tri `Cum` thanh `AIBOT` chi vi ma phong la AIBOT.
Neu backend co CHECK/constant khac, can dong bo code va tao migration rieng; khong sua rieng SQL de lam lech schema.

## Thu tu chay tren database moi hoac database cu

1. Sao luu PostgreSQL truoc khi ap dung migration.
2. Mo PowerShell tai thu muc co `DntuLab.API.csproj`, chay `01_CreateSchema_PostgreSQL.ps1`.
   - Script chay `dotnet ef database update`.
   - Migration `20261123135000_RemoveTemporaryIncidentNotes` se DROP bang `GhiNhanTam`.
   - Neu can giu du lieu GN cu, phai export/sao luu bang truoc. Down migration khong khoi phuc duoc du lieu.
3. Chay `01A_Rename_AILAB_to_AIBOT.sql` trong pgAdmin/psql.
   - Neu chi co AILAB: tao AIBOT, chuyen cac FK, sau do bo dong Phong mang ma cu AILAB.
   - Neu chi co AIBOT: khong doi gi.
   - Neu chua co ca hai: bo qua; buoc 02 se tao AIBOT.
   - Neu ca AILAB va AIBOT: script dung va rollback; can doi chieu thu cong, khong tu dong tron du lieu.
   - Script giu nguyen `ThietBi.Id`, Ticket, va `LichDay.Id`.
4. Chay `02_SeedData_PostgreSQL.sql`.
   - Seed danh muc AIBOT, khong tao AILAB.
   - Seed thiet bi theo cap `(MaPhong, MaThietBi)` va khong xoa du lieu cu.
5. Chay `03_SeedAccounts_PostgreSQL.sql` (chi INSERT tai khoan demo neu chua co; khong reset mat khau tai khoan cu).
6. Chay `04_SeedLichDay_PostgreSQL.sql`.
   - Chi su dung phong AI `AIBOT`, khong su dung `AILAB`.
   - Neu lich da ton tai, script bo qua lich trung theo Ngay/Ca/GiangVienId.
   - Neu xung dot phong/giang vien, script bao loi.
7. Chay `05_Verify_PostgreSQL.sql` (chi SELECT).
   - Danh muc mong doi co AIBOT, khong co AILAB.
   - Truy van phat hien ma phong cu se hien 0 dong neu da dong bo.
8. Neu can du lieu Ticket/YeuCau demo, chay `06_SeedTickets_YeuCau_PostgreSQL.sql`.
   - Script dung `ThietBiId` va cap `(MaPhong, MaThietBi)`.
   - Su dung `AIBOT/AI-KIT01`.
   - Khong tao GN00x.
   - Chi seed yeu cau doi phong trong F/G; khong dung AIHUB/AIBOT.

## Khong lam

- KHONG chay `00_ResetDatabase_PostgreSQL.sql`.
- KHONG chay seed cu chua duoc cap nhat.
- KHONG tu dong xoa G205-G209. Verify se liet ke neu co; can kiem tra FK va du lieu truoc khi xu ly.
- KHONG chay `06_SeedTickets...` tren production neu khong muon co Ticket demo.
- Khong gui ConnectionString, password, JWT key hoac secret vao file SQL/Git.

## Ket qua du kien tren database demo rong

- 9 phong.
- 168 thiet bi: 150 PC + 12 thiet bi cum G + 6 KIT AI.
- 4 tai khoan demo (neu chua ton tai).
- 168 lich (42 ngay x 4 ca) neu chua co lich.
- 7 Ticket demo neu chua co Ticket dang mo cho cac thiet bi mau.
- Toi da 4 YeuCauDoiPhong demo neu co lich F/G phu hop trong 24-30/11/2026.

So lieu tren la muc du kien tren database demo rong; database da co du lieu se co tong so khac.
Tat ca seed deu tranh xoa du lieu hien co.
