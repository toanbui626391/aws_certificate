from confluent_kafka import Producer, KafkaError
import time

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
    'transactional.id': 'my-transactional-id' # Unique ID for the producer's transactions
}

# Create a producer instance
producer = Producer(conf)

# Initialize transactions
producer.init_transactions()

try:
    # Start a transaction
    producer.begin_transaction()

    for i in range(10):
        try:
            # Produce messages
            producer.produce('my_topic', key=str(i), value=f'Message {i}', callback=delivery_report)
            # Flush the producer to ensure messages are sent
            # can flush in batch and still archive exactly one delivery 
            producer.flush()
            print(f"Produced: Message {i}")

        except Exception as e:
            print(f"Failed to produce message {i}: {e}")
            # If there's an error producing, abort the transaction
            producer.abort_transaction()
            break

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
