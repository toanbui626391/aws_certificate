from confluent_kafka import Producer, KafkaError
import time
import json

# Define a callback for delivery reports
def delivery_report(err, msg):
    if err is not None:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()}")

# Configuration for the Kafka producer
conf = {
    'bootstrap.servers': 'localhost:9092',  # Replace with your Kafka broker(s)
    'enable.idempotence': True,               # Enable idempotence for exactly-once delivery
    'acks': 'all',                            # Wait for all replicas to acknowledge
    'transactional.id': 'my-transactional-id', # Unique ID for the producer's transactions
    'compression.type': 'lz4',                # Use LZ4 compression (can also use 'gzip', 'snappy', etc.)
    'retries': 5,                             # Number of retries before giving up on message delivery
    'linger.ms': 5                            # Wait for 5 ms to batch messages
}

# Create a producer instance
producer = Producer(conf)

# Initialize transactions
producer.init_transactions()

try:
    # Start a transaction
    producer.begin_transaction()

    for i in range(10):
        # Create a message
        message = {
            'id': i,
            'content': f'Message {i}'
        }

        # Produce messages, specifying the key for partitioning
        producer.produce('my_topic', key=str(i), value=json.dumps(message), callback=delivery_report)

        # Optionally, you can flush periodically or after a certain number of messages
        # Can remove this when we have set linger.ms
        if i % 5 == 0:
            producer.flush()

    # Commit the transaction after all messages have been produced
    producer.commit_transaction()
    print("Transaction committed successfully.")

except Exception as e:
    # Abort the transaction on error
    producer.abort_transaction()
    print(f"Transaction aborted: {e}")

finally:
    # Clean up
    producer.flush()
