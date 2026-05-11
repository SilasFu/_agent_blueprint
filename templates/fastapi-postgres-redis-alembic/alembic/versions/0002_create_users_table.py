"""create users table

Revision ID: 0002_create_users_table
Revises: 0001_create_items_table
Create Date: 2026-05-10 00:10:00
"""

from alembic import op
import sqlalchemy as sa


revision = "0002_create_users_table"
down_revision = "0001_create_items_table"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("username", sa.String(length=50), nullable=False, unique=True),
        sa.Column("email", sa.String(length=255), nullable=False, unique=True),
        sa.Column("password_hash", sa.String(length=255), nullable=False),
        sa.Column("full_name", sa.String(length=255), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
    )


def downgrade() -> None:
    op.drop_table("users")
