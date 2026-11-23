-- DNTULAB PostgreSQL - 4 tai khoan demo
-- Chi seed tai khoan neu chua ton tai; KHONG ghi de mat khau tai khoan da co.
-- Tai khoan demo: gv01 / Gv@123456; gv02 / Gv@123456;
--                 ktv01 / Ktv@123456; ql01 / Ql@123456.
-- Chi su dung tai khoan demo trong moi truong demo/kiem thu.

BEGIN;

INSERT INTO public."NguoiDung"
    ("TenDangNhap", "MatKhauHash", "HoTen", "VaiTro", "HoatDong")
VALUES
('gv01',  'AQAAAAIAAYagAAAAEGuSWbbqd6eD0jAwLW8Yiow7fiSjTB3l4aDNw6S1xHcnmkYtU61gdZspPD+QhTt5MQ==', 'Giảng viên 01', 'GV', TRUE),
('gv02',  'AQAAAAIAAYagAAAAEJwjzBDiRtCeBwifoHrRP0NtkIItcBjG6HSTZCcETG2NpTW3w6mr3s1not9P+FPzJg==', 'Giảng viên 02', 'GV', TRUE),
('ktv01', 'AQAAAAIAAYagAAAAECkq2k/MA5Cni9uET14dhnRaWQmCuhOeYh6wO7nViqttDLVca4EOsfbgWusz/or7sw==', 'Kỹ thuật viên 01', 'KTV', TRUE),
('ql01',  'AQAAAAIAAYagAAAAEGt0PEVLvx3J8+biII/pSLXtSLA7Qd+kEMEQF83PoIeX8kXc7LzGaejCEFCZ2Z3GxQ==', 'Quản lý LAB', 'QL', TRUE)
ON CONFLICT ("TenDangNhap") DO NOTHING;

COMMIT;

SELECT "Id", "TenDangNhap", "HoTen", "VaiTro", "HoatDong"
FROM public."NguoiDung"
WHERE lower("TenDangNhap") IN ('gv01', 'gv02', 'ktv01', 'ql01')
ORDER BY CASE lower("TenDangNhap")
    WHEN 'gv01' THEN 1
    WHEN 'gv02' THEN 2
    WHEN 'ktv01' THEN 3
    WHEN 'ql01' THEN 4
END;
