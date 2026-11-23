
using System.ComponentModel.DataAnnotations;

namespace DntuLab.Api.DTOs;

public class TaoTicketRequest
{
    [Range(1, int.MaxValue)]
    public int ThietBiId { get; set; }

    [Required, StringLength(100)]
    public string LoaiLoi { get; set; } = string.Empty;

    [StringLength(1000)]
    public string? GhiChu { get; set; }
}
