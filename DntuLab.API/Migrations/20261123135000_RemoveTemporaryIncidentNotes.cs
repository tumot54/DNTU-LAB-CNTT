using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Infrastructure;
using DntuLab.Api.Data;

#nullable disable

namespace DntuLab.API.Migrations;

/// <summary>Loại bỏ bảng ghi nhận sự cố tạm; luồng báo sự cố tạo Ticket trực tiếp.</summary>
[DbContext(typeof(LabDbContext))]
[Migration("20261123135000_RemoveTemporaryIncidentNotes")]
public partial class RemoveTemporaryIncidentNotes : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql("DROP TABLE IF EXISTS public.\"GhiNhanTam\";");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        // Chỉ khôi phục cấu trúc; dữ liệu GN00x đã xóa không thể tự khôi phục.
        migrationBuilder.CreateTable(
            name: "GhiNhanTam",
            schema: "public",
            columns: table => new
            {
                Id = table.Column<int>(type: "integer", nullable: false)
                    .Annotation("Npgsql:ValueGenerationStrategy", Npgsql.EntityFrameworkCore.PostgreSQL.Metadata.NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                LichDayId = table.Column<int>(type: "integer", nullable: false),
                ThietBiId = table.Column<int>(type: "integer", nullable: false),
                MoTa = table.Column<string>(type: "text", nullable: false),
                NguoiGhiId = table.Column<int>(type: "integer", nullable: false),
                ThoiGian = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                TicketId = table.Column<int>(type: "integer", nullable: true),
                TrangThai = table.Column<string>(type: "text", nullable: false),
                MaGhiNhan = table.Column<string>(type: "text", nullable: true, computedColumnSql: "('GN' || CASE WHEN \"Id\" < 1000 THEN lpad(\"Id\"::text, 3, '0') ELSE \"Id\"::text END)", stored: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_GhiNhanTam", x => x.Id);
                table.CheckConstraint("CK_GhiNhan_TrangThai", "\"TrangThai\" IN ('Chưa tổng hợp', 'Đã tạo Ticket')");
                table.ForeignKey("FK_GhiNhanTam_ThietBi_ThietBiId", x => x.ThietBiId, "ThietBi", "Id", principalSchema: "public", onDelete: ReferentialAction.Restrict);
            });
        migrationBuilder.CreateIndex(name: "IX_GhiNhanTam_ThietBiId", schema: "public", table: "GhiNhanTam", column: "ThietBiId");
    }
}
