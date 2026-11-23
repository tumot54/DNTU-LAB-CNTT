-- DNTULAB PostgreSQL - Seed danh muc phong va thiet bi demo
-- Dieu kien: da ap dung EF Core migration va chay 01A_Rename_AILAB_to_AIBOT.sql.
-- Khong xoa du lieu. Upsert thong tin 9 phong da chot; bo qua thiet bi da ton tai
-- theo UNIQUE (MaPhong, MaThietBi).
--
-- Danh muc 9 phong:
-- AIHUB (30), AIBOT (80), F507-F509 (40/phong), G201-G204 (65/phong).
-- Cum AI duoc luu la AIBOT de khop CHECK constraint trong Backend hien tai:
-- CK_Phong_Cum IN ('F','G','AIBOT').
-- F507-F509 van seed 50 PC/phong; day la so thiet bi, khong phai suc chua.

BEGIN;

-- 1. Upsert dung 9 phong da chot. Khong tao G205-G209.
INSERT INTO public."Phong" ("MaPhong", "LoaiPhong", "Cum", "SucChua")
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
ON CONFLICT ("MaPhong") DO UPDATE SET
    "LoaiPhong" = EXCLUDED."LoaiPhong",
    "Cum" = EXCLUDED."Cum",
    "SucChua" = EXCLUDED."SucChua";

-- 2. Cum F: 50 PC moi phong, tong 150 PC.
INSERT INTO public."ThietBi"
    ("MaThietBi", "MaPhong", "Loai", "Ten", "TrangThai")
SELECT
    p."MaPhong" || '-PC' || lpad(n.i::text, 2, '0'),
    p."MaPhong",
    'PC',
    'May tinh ' || lpad(n.i::text, 2, '0'),
    'Sẵn sàng'
FROM public."Phong" p
CROSS JOIN generate_series(1, 50) AS n(i)
WHERE p."MaPhong" IN ('F507', 'F508', 'F509')
ON CONFLICT ("MaPhong", "MaThietBi") DO NOTHING;

-- 3. Cum G: moi phong co TV, Wi-Fi va tu sac laptop, tong 12 thiet bi.
INSERT INTO public."ThietBi"
    ("MaThietBi", "MaPhong", "Loai", "Ten", "TrangThai")
SELECT
    p."MaPhong" || v."Hau",
    p."MaPhong",
    v."Loai",
    v."Ten",
    'Sẵn sàng'
FROM public."Phong" p
CROSS JOIN (
    VALUES
        ('-TV01',    'TV',    'Man hinh Tivi trinh chieu'),
        ('-WIFI',    'WIFI',  'He thong mang khong day'),
        ('-TUSAC01', 'TUSAC', 'Tu sac laptop')
) AS v("Hau", "Loai", "Ten")
WHERE p."MaPhong" IN ('G201', 'G202', 'G203', 'G204')
ON CONFLICT ("MaPhong", "MaThietBi") DO NOTHING;

-- 4. Hai phong AI: moi phong co AI-KIT01 den AI-KIT03, tong 6 KIT.
-- MaThietBi duoc phep lap lai giua AIHUB va AIBOT.
INSERT INTO public."ThietBi"
    ("MaThietBi", "MaPhong", "Loai", "Ten", "TrangThai")
SELECT
    'AI-KIT' || lpad(n.i::text, 2, '0'),
    p."MaPhong",
    'KIT',
    'Bo Kit Robot va mo hinh STEM ' || lpad(n.i::text, 2, '0'),
    'Sẵn sàng'
FROM public."Phong" p
CROSS JOIN generate_series(1, 3) AS n(i)
WHERE p."MaPhong" IN ('AIHUB', 'AIBOT')
ON CONFLICT ("MaPhong", "MaThietBi") DO NOTHING;

COMMIT;

-- 5. Bao cao so luong sau seed (du kien 168 thiet bi neu database chua co them du lieu).
SELECT
    "MaPhong",
    COUNT(*) AS "SoThietBi"
FROM public."ThietBi"
WHERE "MaPhong" IN (
    'AIHUB', 'AIBOT', 'F507', 'F508', 'F509',
    'G201', 'G202', 'G203', 'G204'
)
GROUP BY "MaPhong"
ORDER BY "MaPhong";

SELECT
    COUNT(*) AS "TongThietBiTrongDanhMuc9Phong"
FROM public."ThietBi"
WHERE "MaPhong" IN (
    'AIHUB', 'AIBOT', 'F507', 'F508', 'F509',
    'G201', 'G202', 'G203', 'G204'
);
