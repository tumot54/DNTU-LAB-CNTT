namespace DntuLab.Api.Services;

/// <summary>
/// Tương thích với các nơi còn đăng ký service cũ.
/// Phòng AIBOT được quản lý như một phòng độc lập trong bảng Phong.
/// Không tự tạo dữ liệu phòng/thiết bị; dữ liệu được quản lý bằng SQL seed và import.
/// </summary>
public sealed class AibotProvisioningService
{
    public Task EnsureAsync(CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        return Task.CompletedTask;
    }
}
