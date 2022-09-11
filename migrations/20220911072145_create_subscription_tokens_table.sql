CREATE TABLE subscription_tokens(
    subscription_token text NOT NULL,
    PRIMARY KEY (subscription_token),
    subscriber_id uuid NOT NULL
        REFERENCES subscriptions (id)
)
