FROM lukemathwalker/cargo-chef:latest-rust-1.63.0 as chef
WORKDIR /app
# Install the required system dependencies for our linking configuration
RUN apt update && apt install lld clang -y

FROM chef as planner
COPY . .
# Compute a lock-like file for our project
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
# Build our project dependencies, not our application!
RUN cargo chef cook --release --recipe-path recipe.json

COPY . .
ENV SQLX_OFFLINE true
RUN cargo build --release --bin zero2prod

FROM debian:bullseye-slim AS runtime

WORKDIR /app
RUN apt-get update -y \
		# Install OpenSSL - it is dynamically linked by some of our dependencies
		# Install ca-certificates - it is needed to verify TLS certificates
		# when establishing HTTPS connections
    && apt-get install -y --no-install-recommends openssl ca-certificates \
		# Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/zero2prod zero2prod
COPY configuration configuration
ENV APP_ENVIRONMENT production
ENTRYPOINT ["./zero2prod"]