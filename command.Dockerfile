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
RUN swift build -c release --static-swift-stdlib --product Command

# Create workdir to place files
WORKDIR /workspace

# Copy main executable to workspace area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/Run" ./

# Copy resources bundled by SPM to staging area
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;


# ================================
# Run image
# ================================
FROM gcr.io/distroless/cc-debian11:nonroot

LABEL org.opencontainers.image.source https://github.com/ydataai/aws-asg-tags-lambda

COPY --from=builder /lib/x86_64-linux-gnu/libz*so* /lib/x86_64-linux-gnu/

# copy executables
COPY --from=builder /workspace /
# copy Swift's dynamic libraries dependencies
COPY --from=builder /usr/lib/swift/linux/lib*so* /

ENTRYPOINT ["/Command"]
