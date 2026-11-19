using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Aroel.Data.Migrations;

/// <inheritdoc />
public partial class _20261118190000_SyncTombstones : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "sync_tombstones",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                table_name = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                row_id = table.Column<Guid>(type: "uuid", nullable: false),
                deleted_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                sync_seq = table.Column<long>(type: "bigint", nullable: false, defaultValueSql: "nextval('sync_seq'::regclass)")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_sync_tombstones", x => x.id);
                table.ForeignKey(
                    name: "FK_sync_tombstones_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_sync_tombstones_row_id",
            table: "sync_tombstones",
            column: "row_id");

        migrationBuilder.CreateIndex(
            name: "IX_sync_tombstones_user_id_sync_seq",
            table: "sync_tombstones",
            columns: new[] { "user_id", "sync_seq" });
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "sync_tombstones");
    }
}
