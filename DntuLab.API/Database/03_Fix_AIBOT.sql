-- Kiem tra danh muc phong AI sau khi chuyen AILAB -> AIBOT.
SELECT d."Id", d."MaPhong", d."MaThietBi", d."Loai", d."Ten", d."TrangThai"
FROM public."ThietBi" d
WHERE d."MaPhong" IN ('AIHUB', 'AIBOT')
ORDER BY d."MaPhong", d."MaThietBi";

-- Ky vong: 3 KIT tai AIHUB va 3 KIT tai AIBOT (neu dung du lieu demo hien tai).
