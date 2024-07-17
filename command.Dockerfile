# ================================
# Build image
# ================================
FROM swift:5.9-jammy as builder

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

# Build everything, with optimizations
RUN swift build -c release --static-swift-stdlib --product Command

# Create workdir to place files
WORKDIR /workspace

# Copy main executable to workspace area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/Command" ./

# Copy resources bundled by SPM to workspace area
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;


# ================================
# Run image
# ================================
FROM swift:5.9-jammy-slim

LABEL org.opencontainers.image.source https://github.com/ydataai/aws-asg-tags-lambda

WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=builder /workspace /app

ENTRYPOINT ["./Command"]
