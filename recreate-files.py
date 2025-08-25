#!/usr/bin/env python3
"""
Redis Stream Event Creator

This script queries PostgreSQL for OUTPUT_FILE_FAILED events,
then creates Redis stream events for corresponding ALCHEMY_READY payloads.
"""

import psycopg2
import redis
import json
from datetime import datetime
from typing import List, Optional, Dict, Any
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class RedisStreamEventCreator:
    def __init__(self, postgres_config: Dict[str, str], redis_config: Dict[str, Any], stream_key: str = "events"):
        """
        Initialize the Redis Stream Event Creator
        
        Args:
            postgres_config: PostgreSQL connection parameters
            redis_config: Redis connection parameters
            stream_key: Redis stream key name
        """
        self.postgres_config = postgres_config
        self.redis_config = redis_config
        self.stream_key = stream_key
        self.pg_conn = None
        self.redis_conn = None
        
    def connect_postgres(self):
        """Establish PostgreSQL connection"""
        try:
            self.pg_conn = psycopg2.connect(**self.postgres_config)
            logger.info("Connected to PostgreSQL")
        except Exception as e:
            logger.error(f"Failed to connect to PostgreSQL: {e}")
            raise
            
    def connect_redis(self):
        """Establish Redis connection"""
        try:
            self.redis_conn = redis.Redis(**self.redis_config)
            # Test connection
            self.redis_conn.ping()
            logger.info("Connected to Redis")
        except Exception as e:
            logger.error(f"Failed to connect to Redis: {e}")
            raise
    
    def get_failed_aggregate_ids(self) -> List[str]:
        """
        Query PostgreSQL to get all aggregate_ids where event = 'OUTPUT_FILE_FAILED'
        
        Returns:
            List of aggregate IDs
        """
        try:
            cursor = self.pg_conn.cursor()
            query = """
                SELECT DISTINCT aggregate_id 
                FROM event_logs 
                WHERE event = 'OUTPUT_FILE_FAILED'
            """
            cursor.execute(query)
            aggregate_ids = [row[0] for row in cursor.fetchall()]
            cursor.close()
            
            logger.info(f"Found {len(aggregate_ids)} failed aggregate IDs")
            return aggregate_ids
            
        except Exception as e:
            logger.error(f"Error querying failed aggregate IDs: {e}")
            raise
    
    def get_alchemy_ready_payload(self, aggregate_id: str) -> Optional[str]:
        """
        Get the payload for ALCHEMY_READY event for a specific aggregate_id
        
        Args:
            aggregate_id: The aggregate ID to query
            
        Returns:
            Payload string or None if not found
        """
        try:
            cursor = self.pg_conn.cursor()
            query = """
                SELECT payload 
                FROM event_logs 
                WHERE aggregate_id = %s AND event = 'ALCHEMY_READY'
                LIMIT 1
            """
            cursor.execute(query, (aggregate_id,))
            result = cursor.fetchone()
            cursor.close()
            
            if result:
                return result[0]
            else:
                logger.warning(f"No ALCHEMY_READY event found for aggregate_id: {aggregate_id}")
                return None
                
        except Exception as e:
            logger.error(f"Error querying ALCHEMY_READY payload for {aggregate_id}: {e}")
            return None
    
    def add_to_stream(self, event: str, aggregate_id: str, payload: str):
        """
        Add event to Redis stream
        
        Args:
            event: Event name
            aggregate_id: Aggregate ID
            payload: Event payload
        """
        try:
            timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
            stream_data = {
                b"event": event.encode('utf-8'),
                b"aggregateId": aggregate_id.encode('utf-8'),
                b"timestamp": timestamp.encode('utf-8'),
                b"payload": payload.encode('utf-8')
            }
            
            message_id = self.redis_conn.xadd(self.stream_key, stream_data)
            logger.info(f"Added event to stream: {message_id} for aggregate_id: {aggregate_id}")
            
        except Exception as e:
            logger.error(f"Error adding event to stream for {aggregate_id}: {e}")
            raise
    
    def process_events(self, target_event: str = "ALCHEMY_READY_RETRY"):
        """
        Main processing function that orchestrates the entire workflow
        
        Args:
            target_event: The event name to use when creating Redis stream events
        """
        try:
            # Connect to both databases
            self.connect_postgres()
            self.connect_redis()
            
            # Get all failed aggregate IDs
            failed_aggregate_ids = self.get_failed_aggregate_ids()
            
            if not failed_aggregate_ids:
                logger.info("No failed aggregate IDs found")
                return
            
            # Process each aggregate ID
            processed_count = 0
            for aggregate_id in failed_aggregate_ids:
                logger.info(f"Processing aggregate_id: {aggregate_id}")
                
                # Get ALCHEMY_READY payload
                payload = self.get_alchemy_ready_payload(aggregate_id)
                
                if payload:
                    # Create Redis stream event
                    self.add_to_stream(target_event, aggregate_id, payload)
                    processed_count += 1
                else:
                    logger.warning(f"Skipping aggregate_id {aggregate_id} - no ALCHEMY_READY payload found")
            
            logger.info(f"Processing complete. Created {processed_count} Redis stream events")
            
        except Exception as e:
            logger.error(f"Processing failed: {e}")
            raise
        finally:
            self.cleanup()
    
    def cleanup(self):
        """Close database connections"""
        if self.pg_conn:
            self.pg_conn.close()
            logger.info("PostgreSQL connection closed")
        if self.redis_conn:
            self.redis_conn.close()
            logger.info("Redis connection closed")


def main():
    """Main function with configuration"""
    
    # PostgreSQL configuration
    postgres_config = {
        'host': 'localhost',
        'database': 'your_database',
        'user': 'your_username',
        'password': 'your_password',
        'port': 5432
    }
    
    # Redis configuration
    redis_config = {
        'host': 'localhost',
        'port': 6379,
        'decode_responses': False,  # We want bytes for stream data
        'db': 0
    }
    
    # Stream configuration
    stream_key = "events"
    target_event = "ALCHEMY_READY_RETRY"
    
    # Create and run the processor
    processor = RedisStreamEventCreator(
        postgres_config=postgres_config,
        redis_config=redis_config,
        stream_key=stream_key
    )
    
    try:
        processor.process_events(target_event)
    except Exception as e:
        logger.error(f"Script execution failed: {e}")
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())
