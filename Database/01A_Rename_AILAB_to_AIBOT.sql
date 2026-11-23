-- DNTU LAB - CHUAN HOA MA PHONG AI: AILAB -> AIBOT
-- Chay sau 01_CreateSchema_PostgreSQL.ps1 va truoc 02_SeedData_PostgreSQL.sql.
--
-- Database hien tai su dung Cum = 'AI' (theo CHECK constraint da kiem tra).
-- Ma phong chuan la AIBOT; Cum la mot truong rieng, khong doi thanh AIBOT.
--
-- An toan:
--   * Neu chua co AILAB va AIBOT: bo qua, 02 se tao AIBOT.
--   * Neu chi co AIBOT: bo qua.
--   * Neu chi co AILAB: tao AIBOT tam thoi, chuyen FK, sau do xoa dong ma cu.
--   * Neu ca hai cung ton tai: dung va rollback, khong tu dong tron du lieu.
--   * Khong xoa ThietBi, LichDay, TicketSuCo hay YeuCauDoiPhong.

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
        RAISE NOTICE
            'Khong co phong cu AILAB. Bo qua buoc doi ma; 02_SeedData_PostgreSQL.sql se tao AIBOT.';

    ELSIF NOT v_old_exists AND v_new_exists THEN
        RAISE NOTICE 'Phong AIBOT da dung ma chuan. Khong can doi ma.';

    ELSE
        -- Tao dong Phong AIBOT truoc de cac FK RESTRICT co dich hop le.
        -- Giu Cum = AI theo CHECK constraint cua database hien tai.
        INSERT INTO public."Phong"
            ("MaPhong", "LoaiPhong", "Cum", "SucChua")
        SELECT
            'AIBOT',
            'Lab AI',
            "Cum",
            80
        FROM public."Phong"
        WHERE "MaPhong" = 'AILAB';

        -- Chuyen cac FK sang ma phong moi; cac Id thiet bi/ticket/lich khong doi.
        UPDATE public."ThietBi"
           SET "MaPhong" = 'AIBOT'
         WHERE "MaPhong" = 'AILAB';

        UPDATE public."LichDay"
           SET "MaPhong" = 'AIBOT'
         WHERE "MaPhong" = 'AILAB';

        UPDATE public."YeuCauDoiPhong"
           SET "PhongCu" = CASE
                               WHEN "PhongCu" = 'AILAB' THEN 'AIBOT'
                               ELSE "PhongCu"
                           END,
               "PhongMoi" = CASE
                                WHEN "PhongMoi" = 'AILAB' THEN 'AIBOT'
                                ELSE "PhongMoi"
                            END
         WHERE "PhongCu" = 'AILAB'
            OR "PhongMoi" = 'AILAB';

        -- Xoa dong ma cu sau khi da chuyen het FK.
        -- Day la buoc hoan tat thao tac rename, khong xoa cac ban ghi nghiep vu.
        DELETE FROM public."Phong"
         WHERE "MaPhong" = 'AILAB';

        RAISE NOTICE 'Da chuyen AILAB thanh AIBOT; giu nguyen cac ban ghi thiet bi/lich/ticket.';
    END IF;
END $$;

COMMIT;

-- Kiem tra: AILAB chi con xuat hien trong truong hop can dieu tra rieng.
SELECT "MaPhong", "LoaiPhong", "Cum", "SucChua"
FROM public."Phong"
WHERE "MaPhong" IN ('AIHUB', 'AILAB', 'AIBOT')
ORDER BY "MaPhong";
