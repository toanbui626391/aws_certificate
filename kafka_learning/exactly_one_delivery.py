from confluent_kafka import Consumer, Producer, KafkaError

# Function to process messages
def process_message(message):
    print(f"Processing message: {message.value().decode('utf-8')}")
    # Simulate some processing logic, e.g., inserting into a database

# Configuration for the Kafka consumer
consumer_conf = {
    'bootstrap.servers': 'localhost:9092',  # Replace with your Kafka broker(s)
    'group.id': 'my-consumer-group',         # Consumer group ID
    'auto.offset.reset': 'earliest',         # Start reading at the earliest message
    'enable.auto.commit': False               # Disable automatic offset commits
}

# Configuration for the Kafka producer
producer_conf = {
    'bootstrap.servers': 'localhost:9092',  # Replace with your Kafka broker(s)
    'enable.idempotence': True,               # Enable idempotence
    'acks': 'all',                            # Wait for all replicas to acknowledge
    'transactional.id': 'my-transactional-id' # Unique ID for the producer's transactions
}

# Create a Kafka consumer
consumer = Consumer(consumer_conf)

# Create a Kafka producer
producer = Producer(producer_conf)

# Initialize the producer for transactions
producer.init_transactions()

try:
    # Subscribe to the topic
    consumer.subscribe(['my_topic'])

    while True:
        # Poll for new messages
        msg = consumer.poll(timeout=1.0)

        if msg is None:
            continue
        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                continue
            else:
                print(f"Consumer error: {msg.error()}")
                break

        # Start a transaction
        producer.begin_transaction()

        try:
            # Process the message
            process_message(msg)

            # Optionally produce an output message
            producer.produce('my_output_topic', key=msg.key(), value=msg.value(), callback=None)

            # Commit the transaction
            producer.commit_transaction()
            print("Transaction committed successfully.")

            # Manually commit the offset only after the transaction is committed
            consumer.commit(message=msg)

        except Exception as e:
            # Abort the transaction on error
            producer.abort_transaction()
            print(f"Transaction aborted: {e}")

finally:
    # Cleanup
    consumer.close()
    producer.flush()
                    