# ================================
# Build image
# ================================
FROM swift:5.6-focal as builder

WORKDIR /workspace

COPY ./Package.* ./

# Resolve Swift dependencies
RUN swift package resolve

# Copy entire repo into container
# This copy the build folder to improve package resolve
COPY Sources Sources

# Compile with optimizations
RUN swift build -c release --product Command


# ================================
# Run image
# ================================
FROM gcr.io/distroless/cc:nonroot

LABEL org.opencontainers.image.source https://github.com/ydataai/aws-asg-tags-lambda

COPY --from=builder /lib/x86_64-linux-gnu/libz*so* /lib/x86_64-linux-gnu/

# copy executables
COPY --from=builder /workspace/.build/release /
# copy Swift's dynamic libraries dependencies
COPY --from=builder /usr/lib/swift/linux/lib*so* /

ENTRYPOINT ["/Command"]
