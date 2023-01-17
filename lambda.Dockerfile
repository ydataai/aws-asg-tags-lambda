# ================================
# Build image
# ================================
FROM swift:5.6-focal as builder

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

# Compile with optimizations
RUN swift build -c release --static-swift-stdlib --product CloudFormation


# ================================
# Run image
# ================================
FROM swift:5.6-amazonlinux2-slim

LABEL org.opencontainers.image.source https://github.com/ydataai/aws-asg-tags-lambda

# copy executables
COPY --from=builder /build/.build/release /

ENTRYPOINT ["./CloudFormation"]
