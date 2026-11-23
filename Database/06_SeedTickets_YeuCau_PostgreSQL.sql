-- DNTULAB PostgreSQL - seed Ticket su co va yeu cau doi phong demo
-- Dieu kien:
--   1. Da ap dung migration DeviceSurrogateKey va TicketUndoOncePerDevice.
--   2. Da ap dung RemoveTemporaryIncidentNotes (khong con GhiNhanTam).
--   3. Da chay 02_SeedData, 03_SeedAccounts va 04_SeedLichDay.
-- An toan chay lai:
--   - Khong tao Ticket dang mo trung ThietBiId.
--   - Khong ghi de trang thai thiet bi dang co Ticket that.
--   - Chi tao nhom YeuCau DEMO-POSTGRESQL mot lan.
--   - Khong tao GN00x / khong truy cap GhiNhanTam.

BEGIN;

DO $$
DECLARE
    v_gv01 integer;
    v_gv02 integer;
    v_ktv integer;
    v_ql integer;
BEGIN
    SELECT "Id" INTO v_gv01 FROM public."NguoiDung" WHERE lower("TenDangNhap") = 'gv01';
    SELECT "Id" INTO v_gv02 FROM public."NguoiDung" WHERE lower("TenDangNhap") = 'gv02';
    SELECT "Id" INTO v_ktv FROM public."NguoiDung" WHERE lower("TenDangNhap") = 'ktv01';
    SELECT "Id" INTO v_ql FROM public."NguoiDung" WHERE lower("TenDangNhap") = 'ql01';

    IF v_gv01 IS NULL OR v_gv02 IS NULL OR v_ktv IS NULL OR v_ql IS NULL THEN
        RAISE EXCEPTION 'Thieu tai khoan demo. Hay chay 03_SeedAccounts_PostgreSQL.sql truoc.';
    END IF;

    -- Xac nhan dung thiet bi theo cap (MaPhong, MaThietBi).
    IF EXISTS (
        SELECT 1
        FROM (VALUES
            ('F507','F507-PC01'),
            ('F507','F507-PC02'),
            ('F508','F508-PC01'),
            ('F509','F509-PC01'),
            ('G201','G201-TV01'),
            ('G202','G202-WIFI'),
            ('AIBOT','AI-KIT01')
        ) AS x(ma_phong, ma_thiet_bi)
        WHERE NOT EXISTS (
            SELECT 1
            FROM public."ThietBi" d
            WHERE d."MaPhong" = x.ma_phong
              AND d."MaThietBi" = x.ma_thiet_bi
        )
    ) THEN
        RAISE EXCEPTION 'Thieu thiet bi demo. Hay kiem tra/chay 02_SeedData_PostgreSQL.sql truoc.';
    END IF;

    -- Thiet bi hong: khong ghi de trang thai neu dang co Ticket that chua hoan tat.
    UPDATE public."ThietBi" d
       SET "TrangThai" = 'Hỏng'
      FROM (VALUES
        ('F507','F507-PC01'),
        ('F507','F507-PC02'),
        ('F508','F508-PC01'),
        ('G201','G201-TV01')
      ) AS x(ma_phong, ma_thiet_bi)
     WHERE d."MaPhong" = x.ma_phong
       AND d."MaThietBi" = x.ma_thiet_bi
       AND NOT EXISTS (
           SELECT 1
           FROM public."TicketSuCo" t
           WHERE t."ThietBiId" = d."Id"
             AND t."TrangThai" <> 'Đã khắc phục'
             AND COALESCE(t."GhiChu", '') NOT LIKE 'DEMO-POSTGRESQL:%'
       );

    -- Tao Ticket chinh thuc ngay; FK su dung ThietBiId.
    INSERT INTO public."TicketSuCo"
        ("ThietBiId", "LoaiLoi", "GhiChu", "NguoiBaoId", "ThoiGianTao", "TrangThai")
    SELECT d."Id", x.loai_loi, x.ghi_chu, x.nguoi_bao_id,
           now() - x.tu_luc, 'Chờ xử lý'
    FROM (VALUES
        ('F507','F507-PC01', 'Không khởi động', 'DEMO-POSTGRESQL: Máy không lên nguồn, cần kiểm tra bộ nguồn.', v_gv01, interval '3 hours'),
        ('F507','F507-PC02', 'Lỗi màn hình', 'DEMO-POSTGRESQL: Màn hình không hiển thị tín hiệu.', v_gv02, interval '2 hours'),
        ('F508','F508-PC01', 'Lỗi phần cứng', 'DEMO-POSTGRESQL: Máy thường xuyên tự khởi động lại.', v_gv01, interval '90 minutes'),
        ('G201','G201-TV01', 'Lỗi trình chiếu', 'DEMO-POSTGRESQL: TV không nhận tín hiệu HDMI.', v_gv02, interval '45 minutes')
    ) AS x(ma_phong, ma_thiet_bi, loai_loi, ghi_chu, nguoi_bao_id, tu_luc)
    JOIN public."ThietBi" d
      ON d."MaPhong" = x.ma_phong
     AND d."MaThietBi" = x.ma_thiet_bi
    WHERE NOT EXISTS (
        SELECT 1
        FROM public."TicketSuCo" t
        WHERE t."ThietBiId" = d."Id"
          AND t."TrangThai" <> 'Đã khắc phục'
    );

    -- Thiet bi dang bao tri: chon ro AIBOT/AI-KIT01, khong nham voi AIHUB/AI-KIT01.
    UPDATE public."ThietBi" d
       SET "TrangThai" = 'Đang bảo trì'
      FROM (VALUES
        ('F509','F509-PC01'),
        ('G202','G202-WIFI'),
        ('AIBOT','AI-KIT01')
      ) AS x(ma_phong, ma_thiet_bi)
     WHERE d."MaPhong" = x.ma_phong
       AND d."MaThietBi" = x.ma_thiet_bi
       AND NOT EXISTS (
           SELECT 1
           FROM public."TicketSuCo" t
           WHERE t."ThietBiId" = d."Id"
             AND t."TrangThai" <> 'Đã khắc phục'
             AND COALESCE(t."GhiChu", '') NOT LIKE 'DEMO-POSTGRESQL:%'
       );

    INSERT INTO public."TicketSuCo"
        ("ThietBiId", "LoaiLoi", "GhiChu", "NguoiBaoId", "ThoiGianTao",
         "TrangThai", "KtvXuLyId", "ThoiGianCapNhat")
    SELECT d."Id", x.loai_loi, x.ghi_chu, x.nguoi_bao_id,
           now() - x.tu_luc, 'Đang sửa chữa', v_ktv, now() - interval '20 minutes'
    FROM (VALUES
        ('F509','F509-PC01', 'Bảo trì máy tính', 'DEMO-POSTGRESQL: Đã tiếp nhận, đang kiểm tra ổ cứng và RAM.', v_gv01, interval '5 hours'),
        ('G202','G202-WIFI', 'Mạng Wi-Fi chập chờn', 'DEMO-POSTGRESQL: KTV đang kiểm tra access point và kết nối mạng.', v_gv02, interval '4 hours'),
        ('AIBOT','AI-KIT01', 'Lỗi bộ Kit Robot', 'DEMO-POSTGRESQL: Đang kiểm tra bộ điều khiển và cảm biến.', v_gv01, interval '1 day')
    ) AS x(ma_phong, ma_thiet_bi, loai_loi, ghi_chu, nguoi_bao_id, tu_luc)
    JOIN public."ThietBi" d
      ON d."MaPhong" = x.ma_phong
     AND d."MaThietBi" = x.ma_thiet_bi
    WHERE NOT EXISTS (
        SELECT 1
        FROM public."TicketSuCo" t
        WHERE t."ThietBiId" = d."Id"
          AND t."TrangThai" <> 'Đã khắc phục'
    );

    -- Tao 4 yeu cau doi phong demo neu chua co nhom demo.
    -- Chi su dung phong F/G; uu tien phong khac Cum de co ca doi toa F <-> G.
    -- Khong chon AIHUB/AIBOT.
    IF NOT EXISTS (
        SELECT 1
        FROM public."YeuCauDoiPhong"
        WHERE "LyDo" LIKE 'DEMO-POSTGRESQL:%'
    ) THEN
        WITH candidates AS (
            SELECT
                l."Id" AS lich_day_id,
                l."GiangVienId" AS giang_vien_id,
                l."MaPhong" AS phong_cu,
                target."MaPhong" AS phong_moi,
                row_number() OVER (ORDER BY l."Ngay", l."BatDau", l."Id") AS rn
            FROM public."LichDay" l
            JOIN public."Phong" current_room ON current_room."MaPhong" = l."MaPhong"
            CROSS JOIN LATERAL (
                SELECT p2."MaPhong"
                FROM public."Phong" p2
                WHERE p2."Cum" IN ('F','G')
                  AND p2."Cum" <> current_room."Cum"
                  AND p2."MaPhong" <> l."MaPhong"
                  AND NOT EXISTS (
                      SELECT 1
                      FROM public."LichDay" other_lesson
                      WHERE other_lesson."Ngay" = l."Ngay"
                        AND other_lesson."MaPhong" = p2."MaPhong"
                        AND other_lesson."Id" <> l."Id"
                        AND other_lesson."BatDau" < (
                            SELECT l2."KetThuc" FROM public."LichDay" l2 WHERE l2."Id" = l."Id"
                        )
                        AND other_lesson."KetThuc" > (
                            SELECT l3."BatDau" FROM public."LichDay" l3 WHERE l3."Id" = l."Id"
                        )
                  )
                ORDER BY p2."MaPhong"
                LIMIT 1
            ) target
            WHERE l."Ngay" BETWEEN DATE '2026-11-24' AND DATE '2026-11-30'
              AND current_room."Cum" IN ('F','G')
              AND NOT EXISTS (
                  SELECT 1
                  FROM public."YeuCauDoiPhong" y
                  WHERE y."LichDayId" = l."Id"
              )
            ORDER BY l."Ngay", l."BatDau", l."Id"
            LIMIT 4
        )
        INSERT INTO public."YeuCauDoiPhong"
            ("LichDayId", "GiangVienId", "PhongCu", "PhongMoi", "LyDo",
             "Loai", "TrangThai", "ThoiGianTao", "NguoiDuyetId",
             "ThoiGianDuyet", "GhiChuDuyet")
        SELECT
            c.lich_day_id,
            c.giang_vien_id,
            c.phong_cu,
            c.phong_moi,
            CASE WHEN c.rn = 4
                 THEN 'DEMO-POSTGRESQL: Đề nghị đổi phòng do cần bố trí lại thiết bị giảng dạy.'
                 ELSE 'DEMO-POSTGRESQL: Đề nghị đổi phòng để thuận tiện cho buổi thực hành.'
            END,
            'Có kế hoạch',
            CASE WHEN c.rn = 4 THEN 'Từ chối' ELSE 'Chờ duyệt' END,
            now() - interval '10 minutes' * c.rn,
            CASE WHEN c.rn = 4 THEN v_ql ELSE NULL END,
            CASE WHEN c.rn = 4 THEN now() - interval '5 minutes' ELSE NULL END,
            CASE WHEN c.rn = 4
                 THEN 'DEMO: Phòng đề xuất chưa phù hợp với kế hoạch sử dụng.'
                 ELSE NULL
            END
        FROM candidates c;
    END IF;
END $$;

COMMIT;

-- Bao cao Ticket demo; khong truy van GhiNhanTam/GN00x.
SELECT
    t."TrangThai" AS "TrangThaiTicket",
    COUNT(*) AS "SoTicket"
FROM public."TicketSuCo" t
WHERE t."GhiChu" LIKE 'DEMO-POSTGRESQL:%'
GROUP BY t."TrangThai"
ORDER BY t."TrangThai";

SELECT
    y."TrangThai" AS "TrangThaiYeuCau",
    COUNT(*) AS "SoYeuCau"
FROM public."YeuCauDoiPhong" y
WHERE y."LyDo" LIKE 'DEMO-POSTGRESQL:%'
GROUP BY y."TrangThai"
ORDER BY y."TrangThai";
