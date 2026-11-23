
-- ============================================================
-- DNTU LAB - SEED LICH DAY POSTGRESQL
-- Thoi gian: 20/10/2026 - 30/11/2026
-- 42 ngay x 4 ca/ngay = 168 lich
-- GV01: 84 ca | GV02: 84 ca
--
-- Phong AI chuan: AIBOT.
-- Khong su dung ma cu AILAB.
--
-- An toan:
--   - Khong xoa du lieu hien co
--   - Bo qua lich da ton tai
--   - Kiem tra trung phong
--   - Kiem tra trung gio giang vien
-- ============================================================

DO $$
DECLARE
    v_gv01 INTEGER;
    v_gv02 INTEGER;
    v_phong_ai VARCHAR(50);
    v_phong_thieu TEXT;
    r RECORD;
BEGIN
    -- --------------------------------------------------------
    -- 1. Kiem tra tai khoan giang vien
    -- --------------------------------------------------------

    SELECT "Id"
    INTO v_gv01
    FROM public."NguoiDung"
    WHERE LOWER("TenDangNhap") = 'gv01'
    LIMIT 1;

    SELECT "Id"
    INTO v_gv02
    FROM public."NguoiDung"
    WHERE LOWER("TenDangNhap") = 'gv02'
    LIMIT 1;

    IF v_gv01 IS NULL OR v_gv02 IS NULL THEN
        RAISE EXCEPTION
            'Khong tim thay gv01 va/hoac gv02. Hay chay 03_SeedAccounts_PostgreSQL.sql truoc.';
    END IF;

    -- --------------------------------------------------------
    -- 2. Tu nhan dien ma phong AI dang ton tai
    -- --------------------------------------------------------

    IF EXISTS (
        SELECT 1
        FROM public."Phong"
        WHERE "MaPhong" = 'AIBOT'
    ) THEN
        v_phong_ai := 'AIBOT';
    ELSE
        RAISE EXCEPTION
            'Khong tim thay phong AIBOT trong bang Phong. Hay chay 01A_Rename_AILAB_to_AIBOT.sql (neu co du lieu cu), sau do chay 02_SeedData_PostgreSQL.sql.';
    END IF;

    RAISE NOTICE 'Phong AI duoc su dung: %', v_phong_ai;

    -- --------------------------------------------------------
    -- 3. Kiem tra danh muc phong
    -- --------------------------------------------------------

    SELECT STRING_AGG(x."MaPhong", ', ')
    INTO v_phong_thieu
    FROM UNNEST(ARRAY[
        'F507',
        'F508',
        'F509',
        'G201',
        'G202',
        'G203',
        'G204'
    ]) AS x("MaPhong")
    WHERE NOT EXISTS (
        SELECT 1
        FROM public."Phong" p
        WHERE p."MaPhong" = x."MaPhong"
    );

    IF v_phong_thieu IS NOT NULL THEN
        RAISE EXCEPTION
            'Thieu phong trong danh muc lich day: %. Hay kiem tra 02_SeedData_PostgreSQL.sql.',
            v_phong_thieu;
    END IF;

    -- --------------------------------------------------------
    -- 4. Tao lich day
    -- --------------------------------------------------------

    FOR r IN
        WITH days AS (
            SELECT
                d::DATE AS ngay,
                (d::DATE - DATE '2026-10-20')::INTEGER AS idx
            FROM GENERATE_SERIES(
                DATE '2026-10-20',
                DATE '2026-11-30',
                INTERVAL '1 day'
            ) AS d
        ),

        sessions AS (

            -- CA 1 - GV01
            SELECT
                ngay,
                'Ca 1'::VARCHAR(10) AS ca,
                v_gv01 AS gv_id,
                TIME '07:00' AS bat_dau,
                TIME '09:00' AS ket_thuc,

                (ARRAY[
                    'Lập trình Web API',
                    'An toàn thông tin',
                    'Phát triển ứng dụng di động',
                    'Học máy ứng dụng',
                    'Trí tuệ nhân tạo và Robotics'
                ])[(idx % 5) + 1] AS mon_hoc,

                (ARRAY[
                    'F507',
                    'F509',
                    'F508',
                    'G203',
                    v_phong_ai
                ])[(idx % 5) + 1] AS ma_phong

            FROM days

            UNION ALL

            -- CA 2 - GV02
            SELECT
                ngay,
                'Ca 2',
                v_gv02,
                TIME '09:30',
                TIME '11:30',

                (ARRAY[
                    'Cơ sở dữ liệu',
                    'Trí tuệ nhân tạo và Robotics',
                    'Mạng máy tính',
                    'Cơ sở dữ liệu nâng cao',
                    'Phân tích thiết kế hệ thống'
                ])[(idx % 5) + 1],

                (ARRAY[
                    'G201',
                    v_phong_ai,
                    'G202',
                    'F508',
                    'G204'
                ])[(idx % 5) + 1]

            FROM days

            UNION ALL

            -- CA 3 - GV01
            SELECT
                ngay,
                'Ca 3',
                v_gv01,
                TIME '13:00',
                TIME '15:00',

                (ARRAY[
                    'Lập trình Web API',
                    'An toàn thông tin',
                    'Phát triển ứng dụng di động',
                    'Học máy ứng dụng',
                    'Trí tuệ nhân tạo và Robotics'
                ])[((idx + 1) % 5) + 1],

                (ARRAY[
                    'F507',
                    'F509',
                    'F508',
                    'G203',
                    v_phong_ai
                ])[((idx + 1) % 5) + 1]

            FROM days

            UNION ALL

            -- CA 4 - GV02
            SELECT
                ngay,
                'Ca 4',
                v_gv02,
                TIME '15:30',
                TIME '17:30',

                (ARRAY[
                    'Cơ sở dữ liệu',
                    'Trí tuệ nhân tạo và Robotics',
                    'Mạng máy tính',
                    'Cơ sở dữ liệu nâng cao',
                    'Phân tích thiết kế hệ thống'
                ])[((idx + 1) % 5) + 1],

                (ARRAY[
                    'G201',
                    v_phong_ai,
                    'G202',
                    'F508',
                    'G204'
                ])[((idx + 1) % 5) + 1]

            FROM days
        )

        SELECT *
        FROM sessions
        ORDER BY ngay, bat_dau

    LOOP

        -- ----------------------------------------------------
        -- 5. Bo qua lich da ton tai
        -- ----------------------------------------------------

        IF EXISTS (
            SELECT 1
            FROM public."LichDay"
            WHERE "Ngay" = r.ngay
              AND "Ca" = r.ca
              AND "GiangVienId" = r.gv_id
        ) THEN
            CONTINUE;
        END IF;

        -- ----------------------------------------------------
        -- 6. Kiem tra phong co ton tai
        -- ----------------------------------------------------

        IF NOT EXISTS (
            SELECT 1
            FROM public."Phong"
            WHERE "MaPhong" = r.ma_phong
        ) THEN
            RAISE EXCEPTION
                'Phong % khong ton tai. Ngay %, ca %.',
                r.ma_phong,
                r.ngay,
                r.ca;
        END IF;

        -- ----------------------------------------------------
        -- 7. Kiem tra trung phong
        -- ----------------------------------------------------

        IF EXISTS (
            SELECT 1
            FROM public."LichDay" l
            WHERE l."Ngay" = r.ngay
              AND l."MaPhong" = r.ma_phong
              AND l."BatDau" < r.ket_thuc
              AND l."KetThuc" > r.bat_dau
        ) THEN
            RAISE EXCEPTION
                'Xung dot phong % ngay % ca %. Kiem tra lich hien co.',
                r.ma_phong,
                r.ngay,
                r.ca;
        END IF;

        -- ----------------------------------------------------
        -- 8. Kiem tra trung gio giang vien
        -- ----------------------------------------------------

        IF EXISTS (
            SELECT 1
            FROM public."LichDay" l
            WHERE l."Ngay" = r.ngay
              AND l."GiangVienId" = r.gv_id
              AND l."BatDau" < r.ket_thuc
              AND l."KetThuc" > r.bat_dau
        ) THEN
            RAISE EXCEPTION
                'Giang vien ID % bi trung gio ngay % ca %.',
                r.gv_id,
                r.ngay,
                r.ca;
        END IF;

        -- ----------------------------------------------------
        -- 9. Them lich day
        -- ----------------------------------------------------

        INSERT INTO public."LichDay" (
            "Ngay",
            "Ca",
            "BatDau",
            "KetThuc",
            "MonHoc",
            "MaPhong",
            "GiangVienId",
            "TrangThai",
            "SoBuoi"
        )
        VALUES (
            r.ngay,
            r.ca,
            r.bat_dau,
            r.ket_thuc,
            r.mon_hoc,
            r.ma_phong,
            r.gv_id,
            'Chưa check-in',
            1
        );

    END LOOP;

    RAISE NOTICE 'Hoan tat seed lich day.';

END $$;


-- ============================================================
-- 10. KIEM TRA KET QUA
-- ============================================================

SELECT
    nd."TenDangNhap",
    COUNT(*) AS "TongCa",
    COUNT(DISTINCT ld."Ngay") AS "SoNgayCoLich",
    COUNT(*) * 2 AS "TongTiet"
FROM public."LichDay" ld
JOIN public."NguoiDung" nd
    ON nd."Id" = ld."GiangVienId"
WHERE LOWER(nd."TenDangNhap") IN ('gv01', 'gv02')
  AND ld."Ngay" BETWEEN DATE '2026-10-20'
                    AND DATE '2026-11-30'
GROUP BY nd."TenDangNhap"
ORDER BY nd."TenDangNhap";


-- Tong lich trong khoang thoi gian
SELECT
    COUNT(*) AS "TongLichDay",
    COUNT(DISTINCT "Ngay") AS "TongNgayCoLich"
FROM public."LichDay"
WHERE "Ngay" BETWEEN DATE '2026-10-20'
                 AND DATE '2026-11-30';
