-- DNTU Lab - Verify sau migration DeviceSurrogateKey
-- Chi SELECT, khong thay doi du lieu.

-- 1. Kiem tra khoa chinh va unique theo phong
SELECT
    COUNT(*) AS "TongThietBi",
    COUNT(DISTINCT "Id") AS "SoIdDuyNhat",
    COUNT(*) - COUNT(DISTINCT ("MaPhong", "MaThietBi")) AS "SoCapPhongMaBiTrung"
FROM public."ThietBi";

-- 2. Kiem tra TicketSuCo khong bi mo coi
SELECT COUNT(*) AS "TicketKhongCoThietBi"
FROM public."TicketSuCo" t
LEFT JOIN public."ThietBi" d ON d."Id" = t."ThietBiId"
WHERE d."Id" IS NULL;


-- 3. Kiem tra 6 KIT AI theo danh muc da chot
SELECT
    d."MaPhong",
    d."MaThietBi",
    d."Id",
    d."TrangThai"
FROM public."ThietBi" d
WHERE d."MaPhong" IN ('AIHUB', 'AILAB')
  AND d."MaThietBi" IN ('AI-KIT01', 'AI-KIT02', 'AI-KIT03')
ORDER BY d."MaPhong", d."MaThietBi";

-- 4. Kiem tra ma phong AI
SELECT COUNT(*) AS "SoPhongAILAB"
FROM public."Phong"
WHERE "MaPhong" = 'AILAB';
