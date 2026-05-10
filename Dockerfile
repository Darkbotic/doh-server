# Stage 1: Build
FROM rust:1.87-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy source
COPY . .

# Build release binary
RUN cargo build --release

# Stage 2: Runtime
FROM debian:trixie-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -r -s /bin/false -u 1000 doh

COPY --from=builder /build/target/release/doh-proxy /usr/local/bin/doh-proxy

RUN chmod +x /usr/local/bin/doh-proxy

USER doh

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/doh-proxy"]
