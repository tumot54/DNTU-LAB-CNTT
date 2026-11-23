using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Infrastructure;
using DntuLab.Api.Data;

#nullable disable

namespace DntuLab.Api.Migrations;

[DbContext(typeof(LabDbContext))]
[Migration("20261123130000_TicketUndoOncePerDevice")]
public partial class TicketUndoOncePerDevice : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<bool>(
            name: "DaSuDungQuyenHoanTac",
            table: "ThietBi",
            type: "boolean",
            nullable: false,
            defaultValue: false);

        migrationBuilder.CreateIndex(
            name: "UX_Ticket_ThietBi_DangMo",
            table: "TicketSuCo",
            column: "ThietBiId",
            unique: true,
            filter: "\"TrangThai\" <> 'Đã khắc phục'");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(name: "UX_Ticket_ThietBi_DangMo", table: "TicketSuCo");
        migrationBuilder.DropColumn(name: "DaSuDungQuyenHoanTac", table: "ThietBi");
    }
}
