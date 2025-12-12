"""
Example of how to integrate goal tracking with transaction creation.
Add this call wherever transactions are created in your system.
"""
from sqlalchemy.orm import Session
from app.models.transactions import Transaction
from app.services.goal_service import GoalService


async def create_transaction_with_goal_tracking(db: Session, transaction_data: dict) -> Transaction:
    """
    Create a transaction and automatically contribute to active goals.
    This should be integrated into your existing transaction creation logic.
    """
    # Create the transaction (your existing logic)
    transaction = Transaction(**transaction_data)
    db.add(transaction)
    db.commit()
    db.refresh(transaction)
    
    # Process transaction for active goals
    try:
        await GoalService.process_transaction_for_goals(db, transaction)
    except Exception as e:
        # Log error but don't fail transaction creation
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Error processing transaction {transaction.id} for goals: {str(e)}")
    
    return transaction