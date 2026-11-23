-- DNTULAB PostgreSQL - VERIFY SAU MIGRATION VA SEED
-- Chi SELECT, khong thay doi du lieu.
-- Danh muc phong mong doi: AIHUB, AIBOT, F507-F509, G201-G204.
-- Khong con bang GhiNhanTam trong luong Ticket truc tiep.

-- 1. Dem cac bang nghiep vu chinh.
SELECT 'Phong' AS "Bang", COUNT(*) AS "SoDong" FROM public."Phong"
UNION ALL SELECT 'ThietBi', COUNT(*) FROM public."ThietBi"
UNION ALL SELECT 'NguoiDung', COUNT(*) FROM public."NguoiDung"
UNION ALL SELECT 'LichDay', COUNT(*) FROM public."LichDay"
UNION ALL SELECT 'TicketSuCo', COUNT(*) FROM public."TicketSuCo"
UNION ALL SELECT 'YeuCauDoiPhong', COUNT(*) FROM public."YeuCauDoiPhong"
ORDER BY 1;

-- 2. Danh muc 9 phong va suc chua mong doi.
WITH expected("MaPhong", "LoaiPhong", "Cum", "SucChua") AS (
    VALUES
        ('AIHUB', 'Lab AI', 'AIBOT', 30),
        ('AIBOT', 'Lab AI', 'AIBOT', 80),
        ('F507',  'PC',     'F',     40),
        ('F508',  'PC',     'F',     40),
        ('F509',  'CISCO',  'F',     40),
        ('G201',  'BYOD',   'G',     65),
        ('G202',  'BYOD',   'G',     65),
        ('G203',  'BYOD',   'G',     65),
        ('G204',  'BYOD',   'G',     65)
)
SELECT
    e."MaPhong" AS "PhongMongDoi",
    p."MaPhong" AS "PhongThucTe",
    p."LoaiPhong",
    p."Cum",
    p."SucChua",
    CASE
        WHEN p."MaPhong" IS NULL THEN 'THIEU PHONG'
        WHEN p."LoaiPhong" <> e."LoaiPhong"
          OR p."Cum" <> e."Cum"
          OR p."SucChua" <> e."SucChua" THEN 'SAI THONG TIN'
        ELSE 'OK'
    END AS "KetQua"
FROM expected e
LEFT JOIN public."Phong" p ON p."MaPhong" = e."MaPhong"
ORDER BY e."MaPhong";

-- 3. Phat hien ma phong cu/ngoai danh muc; khong tu dong xoa.
SELECT "MaPhong", "LoaiPhong", "Cum", "SucChua"
FROM public."Phong"
WHERE "MaPhong" IN ('AILAB','G205','G206','G207','G208','G209')
ORDER BY "MaPhong";

-- 4. Kiem tra PK Id va UNIQUE (MaPhong, MaThietBi).
SELECT
    COUNT(*) AS "TongThietBi",
    COUNT(DISTINCT "Id") AS "SoIdDuyNhat",
    COUNT(*) - COUNT(DISTINCT ("MaPhong", "MaThietBi")) AS "SoCapPhongMaBiTrung"
FROM public."ThietBi";

SELECT "MaPhong", "MaThietBi", COUNT(*) AS "SoLan"
FROM public."ThietBi"
GROUP BY "MaPhong", "MaThietBi"
HAVING COUNT(*) > 1;

-- 5. So luong thiet bi theo phong; mong doi:
-- F507/F508/F509 = 50; G201-G204 = 3; AIHUB/AIBOT = 3.
SELECT
    p."MaPhong",
    COUNT(d."Id") AS "SoThietBi",
    CASE
        WHEN p."MaPhong" IN ('F507','F508','F509') THEN 50
        WHEN p."MaPhong" IN ('G201','G202','G203','G204') THEN 3
        WHEN p."MaPhong" IN ('AIHUB','AIBOT') THEN 3
    END AS "SoLuongMongDoi"
FROM public."Phong" p
LEFT JOIN public."ThietBi" d ON d."MaPhong" = p."MaPhong"
WHERE p."MaPhong" IN (
    'AIHUB','AIBOT','F507','F508','F509',
    'G201','G202','G203','G204'
)
GROUP BY p."MaPhong"
ORDER BY p."MaPhong";

-- 6. Kiem tra 3 KIT o tung phong AI; MaThietBi duoc phep trung giua hai phong.
SELECT "MaPhong", "MaThietBi", "Id", "TrangThai"
FROM public."ThietBi"
WHERE "MaPhong" IN ('AIHUB','AIBOT')
  AND "MaThietBi" IN ('AI-KIT01','AI-KIT02','AI-KIT03')
ORDER BY "MaPhong", "MaThietBi";

-- 7. Tai khoan demo (khong hien thi MatKhauHash).
SELECT "TenDangNhap", "HoTen", "VaiTro", "HoatDong"
FROM public."NguoiDung"
WHERE lower("TenDangNhap") IN ('gv01','gv02','ktv01','ql01')
ORDER BY lower("TenDangNhap");

-- 8. Lich day GV01/GV02 trong khoang seed.
SELECT
    nd."TenDangNhap",
    COUNT(ld."Id") AS "TongCa",
    COUNT(DISTINCT ld."Ngay") AS "SoNgayCoLich"
FROM public."NguoiDung" nd
LEFT JOIN public."LichDay" ld
    ON ld."GiangVienId" = nd."Id"
   AND ld."Ngay" BETWEEN DATE '2026-10-20' AND DATE '2026-11-30'
WHERE lower(nd."TenDangNhap") IN ('gv01','gv02')
GROUP BY nd."TenDangNhap"
ORDER BY nd."TenDangNhap";

-- 9. Ticket phai lien ket bang ThietBiId; mong doi 0 orphan.
SELECT COUNT(*) AS "TicketKhongCoThietBi"
FROM public."TicketSuCo" t
LEFT JOIN public."ThietBi" d ON d."Id" = t."ThietBiId"
WHERE d."Id" IS NULL;

-- 10. Kiem tra moi thiet bi chi co toi da 1 Ticket chua khac phuc.
-- Mong doi: 0 dong.
SELECT "ThietBiId", COUNT(*) AS "SoTicketDangMo"
FROM public."TicketSuCo"
WHERE "TrangThai" <> 'Đã khắc phục'
GROUP BY "ThietBiId"
HAVING COUNT(*) > 1;

-- 11. Xac nhan migration quan trong.
SELECT "MigrationId", "ProductVersion"
FROM public."__EFMigrationsHistory"
WHERE "MigrationId" IN (
    '20261110072048_InitialPostgreSql',
    '20261123060000_DeviceSurrogateKey',
    '20261123130000_TicketUndoOncePerDevice',
    '20261123135000_RemoveTemporaryIncidentNotes'
)
ORDER BY "MigrationId";

-- 12. Kiem tra bang GhiNhanTam da duoc go bo.
-- TRUE = khong con bang; FALSE = bang van con.
SELECT to_regclass('public."GhiNhanTam"') IS NULL AS "DaBoBangGhiNhanTam";
