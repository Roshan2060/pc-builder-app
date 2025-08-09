from django.apps import AppConfig


def _connect_post_migrate_seed(app_config: AppConfig):
    # Lazy import to avoid early settings/db initialization
    from django.conf import settings
    from django.db import connection, transaction
    from django.db.models.signals import post_migrate
    from pathlib import Path

    sql_path = Path(getattr(settings, 'BASE_DIR'))
    # settings.BASE_DIR points to backend/ per this project; SQL files sit at repo root
    repo_root = sql_path.parent
    # Use default filenames
    schema_sql_file = repo_root / 'database_schema.sql'
    sample_sql_file = repo_root / 'sample_data.sql'
    compat_sql_file = repo_root / 'compatibility_functions.sql'

    def seed_sample_data(sender, app_config=None, **kwargs):
        # Only run when pcbuilder app finishes migrating
        if app_config and app_config.name != 'pcbuilder':
            return
        # Abort if sample file is missing
        if not sample_sql_file.exists():
            return
        try:
            with connection.cursor() as cursor:
                # Ensure schema exists; if vendors table is missing, try to create schema first
                cursor.execute(
                    """
                    SELECT COUNT(*)
                    FROM information_schema.tables
                    WHERE table_schema = 'public' AND table_name = 'vendors'
                    """
                )
                vendors_table_exists = bool(cursor.fetchone()[0])

            if not vendors_table_exists and schema_sql_file.exists():
                try:
                    schema_sql_text = schema_sql_file.read_text(encoding='utf-8')
                    if schema_sql_text.strip():
                        with transaction.atomic():
                            with connection.cursor() as cursor:
                                cursor.execute(schema_sql_text)
                except Exception:
                    # If schema creation fails, skip seeding silently
                    return

            # Optionally load compatibility functions (safe if already present)
            if compat_sql_file.exists():
                try:
                    compat_sql_text = compat_sql_file.read_text(encoding='utf-8')
                    if compat_sql_text.strip():
                        with transaction.atomic():
                            with connection.cursor() as cursor:
                                cursor.execute(compat_sql_text)
                except Exception:
                    pass

            # If vendors already has rows, assume seeded and skip
            with connection.cursor() as cursor:
                try:
                    cursor.execute('SELECT COUNT(*) FROM vendors;')
                    count = cursor.fetchone()[0]
                    if count and int(count) > 0:
                        return
                except Exception:
                    return

            # Load and execute the SQL in a transaction
            sql_text = sample_sql_file.read_text(encoding='utf-8')
            if not sql_text.strip():
                return
            with transaction.atomic():
                with connection.cursor() as cursor:
                    cursor.execute(sql_text)
        except Exception:
            # Swallow errors to avoid breaking migrations; admin can load manually if needed
            return

    # Connect once
    post_migrate.connect(seed_sample_data, dispatch_uid='pcbuilder_seed_sample_data')


class PcbuilderConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'pcbuilder'

    def ready(self):
        _connect_post_migrate_seed(self)
