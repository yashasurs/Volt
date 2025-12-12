"""merge_heads_before_lean_week_update

Revision ID: d1dde8fc86bb
Revises: f849767fe6ee, fea53fdbdb6d
Create Date: 2025-12-13 03:52:26.343180

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'd1dde8fc86bb'
down_revision: Union[str, Sequence[str], None] = ('f849767fe6ee', 'fea53fdbdb6d')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
