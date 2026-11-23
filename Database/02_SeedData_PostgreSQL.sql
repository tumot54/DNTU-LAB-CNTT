
-- DNTULAB PostgreSQL
-- 02_SeedData_PostgreSQL.sql
-- Seed danh muc 9 phong va thiet bi demo.
--
-- Yeu cau:
-- Da ap dung 5 EF Core migrations.
-- Ma phong AI chuan la AIHUB va AIBOT.
-- Cum AI giu gia tri 'AI' theo CHECK constraint hien tai.
-- Khong xoa du lieu hien co.
--
-- Danh muc 9 phong:
-- AIHUB (30), AIBOT (80),
-- F507-F509 (40/phong),
-- G201-G204 (65/phong).
--
-- Tong thiet bi du kien:
-- 150 PC + 12 thiet bi G + 6 KIT = 168.

BEGIN;

-- =====================================================
-- 1. UPSERT DANH MUC 9 PHONG
-- =====================================================

INSERT INTO public."Phong"
    ("MaPhong", "LoaiPhong", "Cum", "SucChua")
VALUES
    ('AIHUB', 'Lab AI', 'AI', 30),
    ('AIBOT', 'Lab AI', 'AI', 80),

    ('F507', 'PC', 'F', 40),
    ('F508', 'PC', 'F', 40),
    ('F509', 'CISCO', 'F', 40),

    ('G201', 'BYOD', 'G', 65),
    ('G202', 'BYOD', 'G', 65),
    ('G203', 'BYOD', 'G', 65),
    ('G204', 'BYOD', 'G', 65)

ON CONFLICT ("MaPhong") DO UPDATE SET
    "LoaiPhong" = EXCLUDED."LoaiPhong",
    "Cum" = EXCLUDED."Cum",
    "SucChua" = EXCLUDED."SucChua";


-- =====================================================
-- 2. CUM F: 150 MAY TINH
-- 50 PC MOI PHONG F507-F509
-- =====================================================

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


-- =====================================================
-- 3. CUM G: 12 THIET BI
-- 4 PHONG, MOI PHONG CO 3 THIET BI
-- =====================================================

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
        ('-TV01', 'TV', 'Man hinh Tivi trinh chieu'),
        ('-WIFI', 'WIFI', 'He thong mang khong day'),
        ('-TUSAC01', 'TUSAC', 'Tu sac laptop')
) AS v("Hau", "Loai", "Ten")
WHERE p."MaPhong" IN ('G201', 'G202', 'G203', 'G204')
ON CONFLICT ("MaPhong", "MaThietBi") DO NOTHING;


-- =====================================================
-- 4. HAI PHONG AI: 6 BO KIT
-- AIHUB VA AIBOT, MOI PHONG 3 KIT
-- MaThietBi DUOC LAP LAI GIUA HAI PHONG
-- =====================================================

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


-- =====================================================
-- 5. KIEM TRA SO LUONG THIET BI THEO PHONG
-- =====================================================

SELECT
    p."MaPhong",
    p."Cum",
    p."LoaiPhong",
    p."SucChua",
    COUNT(t."Id") AS "SoThietBi"
FROM public."Phong" p
LEFT JOIN public."ThietBi" t
    ON t."MaPhong" = p."MaPhong"
WHERE p."MaPhong" IN (
    'AIHUB', 'AIBOT',
    'F507', 'F508', 'F509',
    'G201', 'G202', 'G203', 'G204'
)
GROUP BY
    p."MaPhong",
    p."Cum",
    p."LoaiPhong",
    p."SucChua"
ORDER BY p."MaPhong";


-- =====================================================
-- 6. TONG HOP SO LUONG
-- =====================================================

SELECT
    COUNT(*) AS "TongSoPhong"
FROM public."Phong"
WHERE "MaPhong" IN (
    'AIHUB', 'AIBOT',
    'F507', 'F508', 'F509',
    'G201', 'G202', 'G203', 'G204'
);

SELECT
    COUNT(*) AS "TongThietBi"
FROM public."ThietBi"
WHERE "MaPhong" IN (
    'AIHUB', 'AIBOT',
    'F507', 'F508', 'F509',
    'G201', 'G202', 'G203', 'G204'
);
