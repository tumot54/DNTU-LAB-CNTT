
using System.ComponentModel.DataAnnotations;

namespace DntuLab.Api.DTOs;

public class TaoGhiNhanTamRequest
{
    [Range(1, int.MaxValue)]
    public int LichDayId { get; set; }

    [Range(1, int.MaxValue)]
    public int ThietBiId { get; set; }

    [Required, StringLength(1000)]
    public string MoTa { get; set; } = string.Empty;
}
