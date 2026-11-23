using DntuLab.Api.Data;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DntuLab.API.Migrations;

[DbContext(typeof(LabDbContext))]
[Migration("20261123060000_DeviceSurrogateKey")]
public partial class DeviceSurrogateKey
{
}
