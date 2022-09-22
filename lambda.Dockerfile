# ================================
# Build image
# ================================
FROM swift:5.6 as builder

WORKDIR /workspace

COPY ./Package.* ./

# Resolve Swift dependencies
RUN swift package resolve

# Copy entire repo into container
# This copy the build folder to improve package resolve
COPY Sources Sources

# Compile with optimizations
RUN swift build -c release --product CloudFormation


# ================================
# Run image
# ================================
FROM swift:5.6-amazonlinux2-slim

LABEL org.opencontainers.image.source https://github.com/ydataai/aws-asg-tags-lambda

# copy executables
COPY --from=builder /workspace/.build/release /

ENTRYPOINT ["./CloudFormation"]
