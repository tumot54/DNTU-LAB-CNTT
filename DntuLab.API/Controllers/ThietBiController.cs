
using DntuLab.Api.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using DntuLab.Api.Domain;
using System.Security.Claims;

namespace DntuLab.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ThietBiController : ControllerBase
{
    private readonly LabDbContext _context;

    public ThietBiController(LabDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var thietBis = await _context.ThietBis
            .AsNoTracking()
            .OrderBy(x => x.MaPhong)
            .ThenBy(x => x.MaThietBi)
            .ToListAsync();

        return Ok(new
        {
            success = true,
            count = thietBis.Count,
            data = thietBis
        });
    }

    [HttpPut("{id:int}/trang-thai")]
    [Authorize(Roles = "KTV,QL")]
    public async Task<IActionResult> CapNhatTrangThai(
        int id,
        [FromBody] CapNhatThietBiRequest request)
    {
        var trangThaiHopLe = new[]
        {
            TrangThaiThietBi.SanSang,
            TrangThaiThietBi.Hong,
            TrangThaiThietBi.DangBaoTri
        };

        if (!trangThaiHopLe.Contains(request.TrangThai))
        {
            return BadRequest(new
            {
                success = false,
                message = "Trạng thái thiết bị không hợp lệ."
            });
        }

        var userIdValue = User.FindFirstValue(
            ClaimTypes.NameIdentifier);

        if (!int.TryParse(userIdValue, out var userId))
            return Unauthorized();

        // Execution Strategy hỗ trợ EnableRetryOnFailure.
        var strategy = _context.Database.CreateExecutionStrategy();

        return await strategy.ExecuteAsync<IActionResult>(async () =>
        {
            await using var tx =
                await _context.Database.BeginTransactionAsync();

            try
            {
                var device = await _context.ThietBis
                    .FirstOrDefaultAsync(x => x.Id == id);

                if (device == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "Không tìm thấy thiết bị."
                    });
                }

                // KTV chỉ được chuyển:
                // Đỏ (Hỏng) -> Vàng (Đang bảo trì)
                // Vàng (Đang bảo trì) -> Xanh (Sẵn sàng)
                if (User.IsInRole(Roles.KTV))
                {
                    var transitionAllowed =
                        (device.TrangThai == TrangThaiThietBi.Hong
                            && request.TrangThai == TrangThaiThietBi.DangBaoTri)
                        ||
                        (device.TrangThai == TrangThaiThietBi.DangBaoTri
                            && request.TrangThai == TrangThaiThietBi.SanSang);

                    if (!transitionAllowed)
                    {
                        return Conflict(new
                        {
                            success = false,
                            message = device.TrangThai == TrangThaiThietBi.SanSang
                                ? "KTV chỉ được thao tác trên thiết bị màu đỏ hoặc màu vàng. Thiết bị màu xanh không thể chọn."
                                : "Thao tác không hợp lệ. KTV chỉ được chuyển Đỏ -> Vàng hoặc Vàng -> Xanh."
                        });
                    }
                }

                var now = DateTime.Now;

                // Tìm Ticket chưa khắc phục gần nhất.
                var ticket = await _context.Tickets
                    .Where(x =>
                        x.ThietBiId == id &&
                        x.TrangThai != TrangThaiTicket.DaKhacPhuc)
                    .OrderByDescending(x => x.ThoiGianTao)
                    .FirstOrDefaultAsync();

                // Cập nhật trạng thái thiết bị.
                device.TrangThai = request.TrangThai;

                if (request.TrangThai == TrangThaiThietBi.SanSang)
                {
                    // Vàng -> Xanh: hoàn tất Ticket.
                    if (ticket != null)
                    {
                        ticket.TrangThai = TrangThaiTicket.DaKhacPhuc;
                        ticket.KtvXuLyId = userId;
                        ticket.ThoiGianCapNhat = now;
                        ticket.ThoiGianHoanTat = now;
                    }
                }
                else
                {
                    var targetStatus =
                        request.TrangThai == TrangThaiThietBi.Hong
                            ? TrangThaiTicket.ChoXuLy
                            : TrangThaiTicket.DangSuaChua;

                    if (ticket == null)
                    {
                        // Chưa có Ticket đang hoạt động: tạo mới.
                        ticket = new TicketSuCo
                        {
                            ThietBiId = device.Id,
                            LoaiLoi = request.TrangThai == TrangThaiThietBi.Hong
                                ? "Thiết bị hỏng"
                                : "Bảo trì thiết bị",

                            GhiChu = request.GhiChu,
                            NguoiBaoId = userId,
                            ThoiGianTao = now,
                            TrangThai = targetStatus,

                            KtvXuLyId =
                                targetStatus == TrangThaiTicket.DangSuaChua
                                    ? userId
                                    : null,

                            ThoiGianCapNhat =
                                targetStatus == TrangThaiTicket.DangSuaChua
                                    ? now
                                    : null
                        };

                        _context.Tickets.Add(ticket);
                    }
                    else
                    {
                        // Đã có Ticket: cập nhật Ticket hiện tại.
                        ticket.TrangThai = targetStatus;

                        ticket.KtvXuLyId =
                            targetStatus == TrangThaiTicket.DangSuaChua
                                ? userId
                                : null;

                        ticket.ThoiGianCapNhat = now;
                        ticket.ThoiGianHoanTat = null;
                    }
                }

                await _context.SaveChangesAsync();
                await tx.CommitAsync();

                return Ok(new
                {
                    success = true,
                    message = "Đã đồng bộ trạng thái thiết bị và Ticket.",
                    data = new
                    {
                        device.Id,
                        device.MaThietBi,
                        device.MaPhong,
                        device.TrangThai,
                        ticketId = ticket?.Id,
                        ticketStatus = ticket?.TrangThai
                    }
                });
            }
            catch
            {
                await tx.RollbackAsync();
                throw;
            }
        });
    }
}

public class CapNhatThietBiRequest
{
    public string TrangThai { get; set; } = string.Empty;
    public string? GhiChu { get; set; }
}
