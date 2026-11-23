-- DNTU LAB - DOI MA PHONG AILAB CU THANH AIBOT
-- Chay sau 01_CreateSchema_PostgreSQL.ps1 va truoc 02_SeedData_PostgreSQL.sql.
-- An toan: khong xoa phong, khong xoa du lieu; cap nhat cac FK truoc khi doi PK.
-- Neu ca AILAB va AIBOT cung ton tai, script DUNG de tranh tu dong tron du lieu.

BEGIN;

DO $$
DECLARE
    v_old_exists boolean;
    v_new_exists boolean;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM public."Phong" WHERE "MaPhong" = 'AILAB'
    ) INTO v_old_exists;

    SELECT EXISTS (
        SELECT 1 FROM public."Phong" WHERE "MaPhong" = 'AIBOT'
    ) INTO v_new_exists;

    IF v_old_exists AND v_new_exists THEN
        RAISE EXCEPTION
            'Ca AILAB va AIBOT deu ton tai. Dung lai de doi chieu du lieu, khong tu dong gop hai phong.';
    ELSIF NOT v_old_exists AND NOT v_new_exists THEN
        RAISE EXCEPTION
            'Khong tim thay AILAB hoac AIBOT trong Phong. Kiem tra database truoc khi tiep tuc.';
    ELSIF v_old_exists AND NOT v_new_exists THEN
        UPDATE public."ThietBi"
           SET "MaPhong" = 'AIBOT'
         WHERE "MaPhong" = 'AILAB';

        UPDATE public."LichDay"
           SET "MaPhong" = 'AIBOT'
         WHERE "MaPhong" = 'AILAB';

        UPDATE public."YeuCauDoiPhong"
           SET "PhongCu" = CASE WHEN "PhongCu" = 'AILAB' THEN 'AIBOT' ELSE "PhongCu" END,
               "PhongMoi" = CASE WHEN "PhongMoi" = 'AILAB' THEN 'AIBOT' ELSE "PhongMoi" END
         WHERE "PhongCu" = 'AILAB' OR "PhongMoi" = 'AILAB';

        UPDATE public."Phong"
           SET "MaPhong" = 'AIBOT',
               "LoaiPhong" = 'Lab AI',
               "Cum" = 'AIBOT',
               "SucChua" = 80
         WHERE "MaPhong" = 'AILAB';
    END IF;
END $$;

COMMIT;

-- Kiem tra ket qua; mong doi chi con AIBOT, khong con AILAB.
SELECT "MaPhong", "LoaiPhong", "Cum", "SucChua"
FROM public."Phong"
WHERE "MaPhong" IN ('AIHUB', 'AILAB', 'AIBOT')
ORDER BY "MaPhong";
