"""create items table

Revision ID: 0001_create_items_table
Revises:
Create Date: 2026-05-10 00:00:00
"""

from alembic import op
import sqlalchemy as sa


revision = "0001_create_items_table"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "items",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(length=255), nullable=False, unique=True),
        sa.Column("description", sa.Text(), nullable=True),
    )


def downgrade() -> None:
    op.drop_table("items")