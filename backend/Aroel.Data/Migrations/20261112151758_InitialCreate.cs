using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Aroel.Data.Migrations;

/// <inheritdoc />
public partial class _20261112151758_InitialCreate : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateSequence(
            name: "sync_seq");

        migrationBuilder.CreateTable(
            name: "aspnet_roles",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                name = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                normalized_name = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                concurrency_stamp = table.Column<string>(type: "text", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_aspnet_roles", x => x.id);
            });

        migrationBuilder.CreateTable(
            name: "emotions",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                slug = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                label = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                family = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                valence_bias = table.Column<decimal>(type: "numeric(3,2)", precision: 3, scale: 2, nullable: false),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_emotions", x => x.id);
            });

        migrationBuilder.CreateTable(
            name: "users",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                display_name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                timezone = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                locale = table.Column<string>(type: "character varying(35)", maxLength: 35, nullable: false),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_users", x => x.id);
            });

        migrationBuilder.CreateTable(
            name: "aspnet_role_claims",
            columns: table => new
            {
                id = table.Column<int>(type: "integer", nullable: false)
                    .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                role_id = table.Column<Guid>(type: "uuid", nullable: false),
                claim_type = table.Column<string>(type: "text", nullable: true),
                claim_value = table.Column<string>(type: "text", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_aspnet_role_claims", x => x.id);
                table.ForeignKey(
                    name: "FK_aspnet_role_claims_aspnet_roles_role_id",
                    column: x => x.role_id,
                    principalTable: "aspnet_roles",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "aspnet_users",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_name = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                normalized_user_name = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                email = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                normalized_email = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: true),
                email_confirmed = table.Column<bool>(type: "boolean", nullable: false),
                password_hash = table.Column<string>(type: "text", nullable: true),
                security_stamp = table.Column<string>(type: "text", nullable: true),
                concurrency_stamp = table.Column<string>(type: "text", nullable: true),
                phone_number = table.Column<string>(type: "text", nullable: true),
                phone_number_confirmed = table.Column<bool>(type: "boolean", nullable: false),
                two_factor_enabled = table.Column<bool>(type: "boolean", nullable: false),
                lockout_end = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                lockout_enabled = table.Column<bool>(type: "boolean", nullable: false),
                access_failed_count = table.Column<int>(type: "integer", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_aspnet_users", x => x.id);
                table.ForeignKey(
                    name: "FK_aspnet_users_users_id",
                    column: x => x.id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "days",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                local_date = table.Column<DateOnly>(type: "date", nullable: false),
                rating_half = table.Column<short>(type: "smallint", nullable: true),
                note = table.Column<string>(type: "character varying(280)", maxLength: 280, nullable: true),
                rated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                sync_seq = table.Column<long>(type: "bigint", nullable: false, defaultValueSql: "nextval('sync_seq'::regclass)")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_days", x => x.id);
                table.ForeignKey(
                    name: "FK_days_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "devices",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                platform = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                push_token = table.Column<string>(type: "character varying(512)", maxLength: 512, nullable: true),
                app_version = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                last_seen_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_devices", x => x.id);
                table.ForeignKey(
                    name: "FK_devices_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "notes",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                body_md = table.Column<string>(type: "text", nullable: false),
                word_count = table.Column<int>(type: "integer", nullable: false),
                pinned = table.Column<bool>(type: "boolean", nullable: false),
                deleted_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                sync_seq = table.Column<long>(type: "bigint", nullable: false, defaultValueSql: "nextval('sync_seq'::regclass)")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_notes", x => x.id);
                table.ForeignKey(
                    name: "FK_notes_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "refresh_tokens",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                token_hash = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                device_id = table.Column<Guid>(type: "uuid", nullable: true),
                expires_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                revoked_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                rotated_from_id = table.Column<Guid>(type: "uuid", nullable: true),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_refresh_tokens", x => x.id);
                table.ForeignKey(
                    name: "FK_refresh_tokens_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "streak_states",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                current_streak = table.Column<int>(type: "integer", nullable: false),
                longest_streak = table.Column<int>(type: "integer", nullable: false),
                grace_remaining = table.Column<int>(type: "integer", nullable: false),
                last_kept_date = table.Column<DateOnly>(type: "date", nullable: true),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_streak_states", x => x.id);
                table.ForeignKey(
                    name: "FK_streak_states_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "tags",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                label = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
                color = table.Column<string>(type: "character varying(7)", maxLength: 7, nullable: true),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                sync_seq = table.Column<long>(type: "bigint", nullable: false, defaultValueSql: "nextval('sync_seq'::regclass)")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_tags", x => x.id);
                table.ForeignKey(
                    name: "FK_tags_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "aspnet_user_claims",
            columns: table => new
            {
                id = table.Column<int>(type: "integer", nullable: false)
                    .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                claim_type = table.Column<string>(type: "text", nullable: true),
                claim_value = table.Column<string>(type: "text", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_aspnet_user_claims", x => x.id);
                table.ForeignKey(
                    name: "FK_aspnet_user_claims_aspnet_users_user_id",
                    column: x => x.user_id,
                    principalTable: "aspnet_users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "aspnet_user_logins",
            columns: table => new
            {
                login_provider = table.Column<string>(type: "text", nullable: false),
                provider_key = table.Column<string>(type: "text", nullable: false),
                provider_display_name = table.Column<string>(type: "text", nullable: true),
                user_id = table.Column<Guid>(type: "uuid", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_aspnet_user_logins", x => new { x.login_provider, x.provider_key });
                table.ForeignKey(
                    name: "FK_aspnet_user_logins_aspnet_users_user_id",
                    column: x => x.user_id,
                    principalTable: "aspnet_users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "aspnet_user_roles",
            columns: table => new
            {
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                role_id = table.Column<Guid>(type: "uuid", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_aspnet_user_roles", x => new { x.user_id, x.role_id });
                table.ForeignKey(
                    name: "FK_aspnet_user_roles_aspnet_roles_role_id",
                    column: x => x.role_id,
                    principalTable: "aspnet_roles",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_aspnet_user_roles_aspnet_users_user_id",
                    column: x => x.user_id,
                    principalTable: "aspnet_users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "aspnet_user_tokens",
            columns: table => new
            {
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                login_provider = table.Column<string>(type: "text", nullable: false),
                name = table.Column<string>(type: "text", nullable: false),
                value = table.Column<string>(type: "text", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_aspnet_user_tokens", x => new { x.user_id, x.login_provider, x.name });
                table.ForeignKey(
                    name: "FK_aspnet_user_tokens_aspnet_users_user_id",
                    column: x => x.user_id,
                    principalTable: "aspnet_users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "day_sentiment",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                day_id = table.Column<Guid>(type: "uuid", nullable: false),
                rating_half = table.Column<short>(type: "smallint", nullable: true),
                emotion_id = table.Column<Guid>(type: "uuid", nullable: true),
                source = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                recorded_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                sync_seq = table.Column<long>(type: "bigint", nullable: false, defaultValueSql: "nextval('sync_seq'::regclass)")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_day_sentiment", x => x.id);
                table.ForeignKey(
                    name: "FK_day_sentiment_days_day_id",
                    column: x => x.day_id,
                    principalTable: "days",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_day_sentiment_emotions_emotion_id",
                    column: x => x.emotion_id,
                    principalTable: "emotions",
                    principalColumn: "id",
                    onDelete: ReferentialAction.SetNull);
                table.ForeignKey(
                    name: "FK_day_sentiment_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "entries",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                day_id = table.Column<Guid>(type: "uuid", nullable: false),
                kind = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                body_md = table.Column<string>(type: "text", nullable: false),
                word_count = table.Column<int>(type: "integer", nullable: false),
                opened_count = table.Column<int>(type: "integer", nullable: false),
                last_opened_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                pinned = table.Column<bool>(type: "boolean", nullable: false),
                deleted_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                sync_seq = table.Column<long>(type: "bigint", nullable: false, defaultValueSql: "nextval('sync_seq'::regclass)")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_entries", x => x.id);
                table.ForeignKey(
                    name: "FK_entries_days_day_id",
                    column: x => x.day_id,
                    principalTable: "days",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_entries_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "gratitude_items",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                day_id = table.Column<Guid>(type: "uuid", nullable: false),
                position = table.Column<int>(type: "integer", nullable: false),
                text = table.Column<string>(type: "character varying(140)", maxLength: 140, nullable: false),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                sync_seq = table.Column<long>(type: "bigint", nullable: false, defaultValueSql: "nextval('sync_seq'::regclass)")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_gratitude_items", x => x.id);
                table.ForeignKey(
                    name: "FK_gratitude_items_days_day_id",
                    column: x => x.day_id,
                    principalTable: "days",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "streak_restorations",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                user_id = table.Column<Guid>(type: "uuid", nullable: false),
                local_date = table.Column<DateOnly>(type: "date", nullable: false),
                streak_state_id = table.Column<Guid>(type: "uuid", nullable: false),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_streak_restorations", x => x.id);
                table.ForeignKey(
                    name: "FK_streak_restorations_streak_states_streak_state_id",
                    column: x => x.streak_state_id,
                    principalTable: "streak_states",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_streak_restorations_users_user_id",
                    column: x => x.user_id,
                    principalTable: "users",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "day_tags",
            columns: table => new
            {
                id = table.Column<Guid>(type: "uuid", nullable: false),
                day_id = table.Column<Guid>(type: "uuid", nullable: false),
                tag_id = table.Column<Guid>(type: "uuid", nullable: false),
                created_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                updated_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                sync_seq = table.Column<long>(type: "bigint", nullable: false, defaultValueSql: "nextval('sync_seq'::regclass)")
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_day_tags", x => x.id);
                table.ForeignKey(
                    name: "FK_day_tags_days_day_id",
                    column: x => x.day_id,
                    principalTable: "days",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_day_tags_tags_tag_id",
                    column: x => x.tag_id,
                    principalTable: "tags",
                    principalColumn: "id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_aspnet_role_claims_role_id",
            table: "aspnet_role_claims",
            column: "role_id");

        migrationBuilder.CreateIndex(
            name: "RoleNameIndex",
            table: "aspnet_roles",
            column: "normalized_name",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_aspnet_user_claims_user_id",
            table: "aspnet_user_claims",
            column: "user_id");

        migrationBuilder.CreateIndex(
            name: "IX_aspnet_user_logins_user_id",
            table: "aspnet_user_logins",
            column: "user_id");

        migrationBuilder.CreateIndex(
            name: "IX_aspnet_user_roles_role_id",
            table: "aspnet_user_roles",
            column: "role_id");

        migrationBuilder.CreateIndex(
            name: "EmailIndex",
            table: "aspnet_users",
            column: "normalized_email");

        migrationBuilder.CreateIndex(
            name: "UserNameIndex",
            table: "aspnet_users",
            column: "normalized_user_name",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_day_sentiment_day_id",
            table: "day_sentiment",
            column: "day_id",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_day_sentiment_emotion_id",
            table: "day_sentiment",
            column: "emotion_id");

        migrationBuilder.CreateIndex(
            name: "IX_day_sentiment_user_id_day_id",
            table: "day_sentiment",
            columns: new[] { "user_id", "day_id" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_day_tags_day_id_tag_id",
            table: "day_tags",
            columns: new[] { "day_id", "tag_id" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_day_tags_tag_id",
            table: "day_tags",
            column: "tag_id");

        migrationBuilder.CreateIndex(
            name: "IX_days_user_id_local_date",
            table: "days",
            columns: new[] { "user_id", "local_date" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_devices_user_id",
            table: "devices",
            column: "user_id");

        migrationBuilder.CreateIndex(
            name: "IX_emotions_slug",
            table: "emotions",
            column: "slug",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_entries_day_id",
            table: "entries",
            column: "day_id");

        migrationBuilder.CreateIndex(
            name: "IX_entries_user_id_created_at",
            table: "entries",
            columns: new[] { "user_id", "created_at" });

        migrationBuilder.CreateIndex(
            name: "IX_gratitude_items_day_id_position",
            table: "gratitude_items",
            columns: new[] { "day_id", "position" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_notes_user_id_created_at",
            table: "notes",
            columns: new[] { "user_id", "created_at" });

        migrationBuilder.CreateIndex(
            name: "IX_refresh_tokens_token_hash",
            table: "refresh_tokens",
            column: "token_hash",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_refresh_tokens_user_id",
            table: "refresh_tokens",
            column: "user_id");

        migrationBuilder.CreateIndex(
            name: "IX_streak_restorations_streak_state_id",
            table: "streak_restorations",
            column: "streak_state_id");

        migrationBuilder.CreateIndex(
            name: "IX_streak_restorations_user_id_local_date",
            table: "streak_restorations",
            columns: new[] { "user_id", "local_date" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_streak_states_user_id",
            table: "streak_states",
            column: "user_id",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_tags_user_id_label",
            table: "tags",
            columns: new[] { "user_id", "label" },
            unique: true);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "aspnet_role_claims");

        migrationBuilder.DropTable(
            name: "aspnet_user_claims");

        migrationBuilder.DropTable(
            name: "aspnet_user_logins");

        migrationBuilder.DropTable(
            name: "aspnet_user_roles");

        migrationBuilder.DropTable(
            name: "aspnet_user_tokens");

        migrationBuilder.DropTable(
            name: "day_sentiment");

        migrationBuilder.DropTable(
            name: "day_tags");

        migrationBuilder.DropTable(
            name: "devices");

        migrationBuilder.DropTable(
            name: "entries");

        migrationBuilder.DropTable(
            name: "gratitude_items");

        migrationBuilder.DropTable(
            name: "notes");

        migrationBuilder.DropTable(
            name: "refresh_tokens");

        migrationBuilder.DropTable(
            name: "streak_restorations");

        migrationBuilder.DropTable(
            name: "aspnet_roles");

        migrationBuilder.DropTable(
            name: "aspnet_users");

        migrationBuilder.DropTable(
            name: "emotions");

        migrationBuilder.DropTable(
            name: "tags");

        migrationBuilder.DropTable(
            name: "days");

        migrationBuilder.DropTable(
            name: "streak_states");

        migrationBuilder.DropTable(
            name: "users");

        migrationBuilder.DropSequence(
            name: "sync_seq");
    }
}
